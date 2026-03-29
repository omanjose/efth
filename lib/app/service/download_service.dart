import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Persisted metadata so a download can resume after a crash or network loss.
class _DownloadMeta {
  final String url;
  final int totalBytes;       // 0 = unknown
  final int downloadedBytes;
  final bool supportsRange;   // server returned Accept-Ranges: bytes

  const _DownloadMeta({
    required this.url,
    required this.totalBytes,
    required this.downloadedBytes,
    required this.supportsRange,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'totalBytes': totalBytes,
        'downloadedBytes': downloadedBytes,
        'supportsRange': supportsRange,
      };

  factory _DownloadMeta.fromJson(Map<String, dynamic> j) => _DownloadMeta(
        url: j['url'] as String,
        totalBytes: j['totalBytes'] as int,
        downloadedBytes: j['downloadedBytes'] as int,
        supportsRange: j['supportsRange'] as bool,
      );
}

enum _ChunkResult { done, networkError, fatalError }

class DownloadService {
  static const String fileId = "1EUy2rKZA4kbmtYj4E7QVPisH-9jGzjuk";

  // Flush partial file to disk every 512 KB so progress survives a crash
  static const int _flushThreshold = 512 * 1024;

  static const Map<String, String> _headers = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 '
            '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.9',
  };

  // ─── Public API ─────────────────────────────────────────────────────────────

  /// Download (or resume) the audio ZIP and extract it.
  /// [onProgress] receives a value in [0.0, 1.0].
  static Future<bool> downloadAndExtract({
    required Function(double progress) onProgress,
    Function(String message)? onLog,
  }) async {
    try {
      final paths = await _getPaths();
      final tmpFile = File(paths['tmp']!);
      final metaFile = File(paths['meta']!);

      // ── 1. Resolve URL (reuse cached URL if resuming) ──────────────────────
      _DownloadMeta? meta = await _loadMeta(metaFile, onLog);

      String? url;
      if (meta != null) {
        _log(onLog,
            '🔄 Resuming — ${_mb(meta.downloadedBytes)} MB already saved');
        url = meta.url;
      } else {
        _log(onLog, '📥 Starting new download...');
        url = await _resolveDownloadUrl(fileId, onLog);
        if (url == null) {
          _log(onLog, '❌ Could not obtain a valid download URL.');
          _log(onLog, '   Ensure the file is shared as "Anyone with the link".');
          return false;
        }
      }

      // ── 2. Probe URL for size + range support (only on fresh start) ─────────
      if (meta == null) {
        meta = await _probeUrl(url, onLog);
        if (meta == null) return false;
        await _saveMeta(metaFile, meta);
      }

      // ── 3. Download with automatic resume on network error ─────────────────
      final ok = await _resumableDownload(
        meta: meta,
        tmpFile: tmpFile,
        metaFile: metaFile,
        onProgress: onProgress,
        onLog: onLog,
      );
      if (!ok) return false;

      // ── 4. Guard: reject HTML error pages ──────────────────────────────────
      final header = await _readFirstBytes(tmpFile, 600);
      if (_isHtml(header)) {
        _log(onLog, '❌ File is an HTML page, not a ZIP.');
        _log(onLog, '   ${String.fromCharCodes(header.take(300))}');
        await _cleanup(tmpFile, metaFile);
        return false;
      }

      // ── 5. Extract ─────────────────────────────────────────────────────────
      final extracted = await _extractZip(tmpFile, onLog);
      if (extracted) await _cleanup(tmpFile, metaFile);
      return extracted;
    } catch (e, st) {
      _log(onLog, '❌ Fatal: $e');
      if (kDebugMode) print(st);
      return false;
    }
  }

  /// Wipe any partial download so the next call starts fresh.
  static Future<void> cancelDownload() async {
    final paths = await _getPaths();
    await _cleanup(File(paths['tmp']!), File(paths['meta']!));
  }

  static Future<bool> deleteAudio() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/audio_tune');
      if (await audioDir.exists()) {
        await audioDir.delete(recursive: true);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ deleteAudio: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getDownloadStatus() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/audio_tune');
      if (!await audioDir.exists()) {
        return {'downloaded': false, 'fileCount': 0, 'totalSize': 0};
      }
      final files = audioDir.listSync();
      int totalSize = 0;
      for (var f in files) {
        if (f is File) totalSize += await f.length();
      }
      return {
        'downloaded': files.isNotEmpty,
        'fileCount': files.length,
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / 1048576).toStringAsFixed(2),
        'path': audioDir.path,
      };
    } catch (e) {
      return {'downloaded': false, 'error': e.toString()};
    }
  }

  // ─── Resumable core ─────────────────────────────────────────────────────────

  static Future<bool> _resumableDownload({
    required _DownloadMeta meta,
    required File tmpFile,
    required File metaFile,
    required Function(double) onProgress,
    Function(String)? onLog,
  }) async {
    // How many bytes we already have on disk
    int onDisk = await tmpFile.exists() ? await tmpFile.length() : 0;

    // Sanity check — if disk has way more bytes than recorded, restart
    if (onDisk > meta.downloadedBytes + _flushThreshold * 2) {
      _log(onLog, '⚠️ Temp file inconsistency — restarting from 0');
      await tmpFile.delete();
      onDisk = 0;
    }

    // Nothing left to download
    if (meta.totalBytes > 0 && onDisk >= meta.totalBytes) {
      _log(onLog, '✅ Already fully downloaded');
      onProgress(1.0);
      return true;
    }

    if (!meta.supportsRange && onDisk > 0) {
      _log(onLog, '⚠️ Server does not support resume — restarting from 0');
      await tmpFile.delete();
      onDisk = 0;
    }

    const maxRetries = 6;
    int attempt = 0;

    while (attempt < maxRetries) {
      attempt++;
      _log(onLog, attempt == 1
          ? (onDisk > 0 ? '⏩ Resuming from ${_mb(onDisk)} MB' : '📡 Downloading...')
          : '🔁 Retry $attempt/$maxRetries (from ${_mb(onDisk)} MB)');

      final result = await _downloadFrom(
        url: meta.url,
        startByte: onDisk,
        tmpFile: tmpFile,
        totalBytes: meta.totalBytes,
        supportsRange: meta.supportsRange,
        onProgress: (received) {
          final done = onDisk + received;
          final total = meta.totalBytes;
          onProgress(total > 0
              ? (done / total).clamp(0.0, 1.0)
              : 0.05 + (received % 10000000) / 10000000 * 0.9);
        },
        onLog: onLog,
      );

      if (result == _ChunkResult.done) {
        onProgress(1.0);
        return true;
      }

      if (result == _ChunkResult.fatalError) return false;

      // Network error — update onDisk and persist before sleeping
      onDisk = await tmpFile.exists() ? await tmpFile.length() : onDisk;
      await _saveMeta(
          metaFile,
          _DownloadMeta(
            url: meta.url,
            totalBytes: meta.totalBytes,
            downloadedBytes: onDisk,
            supportsRange: meta.supportsRange,
          ));

      final wait = Duration(seconds: attempt * 3);
      _log(onLog, '   Waiting ${wait.inSeconds}s before retry...');
      await Future<void>.delayed(wait);
    }

    _log(onLog, '❌ Max retries reached. Progress saved — tap Download to continue.');
    return false;
  }

  static Future<_ChunkResult> _downloadFrom({
    required String url,
    required int startByte,
    required File tmpFile,
    required int totalBytes,
    required bool supportsRange,
    required Function(int received) onProgress,
    Function(String)? onLog,
  }) async {
    try {
      final request = http.Request('GET', Uri.parse(url))
        ..headers.addAll({..._headers, 'Accept': '*/*'})
        ..followRedirects = true
        ..maxRedirects = 5;

      if (supportsRange && startByte > 0) {
        request.headers['Range'] = 'bytes=$startByte-';
        _log(onLog, '   Range: bytes=$startByte-');
      }

      final response =
          await request.send().timeout(const Duration(minutes: 15));

      _log(onLog,
          '   HTTP ${response.statusCode}  type=${response.headers['content-type']}');

      if (response.statusCode != 200 && response.statusCode != 206) {
        await response.stream.drain<void>();
        return response.statusCode >= 400 && response.statusCode < 500
            ? _ChunkResult.fatalError
            : _ChunkResult.networkError;
      }

      // Append if server honoured Range (206), overwrite if it sent 200 anyway
      final mode = (response.statusCode == 206 && startByte > 0)
          ? FileMode.writeOnlyAppend
          : FileMode.writeOnly;

      final sink = tmpFile.openWrite(mode: mode);
      int received = 0;
      final buf = <int>[];

      try {
        await for (final chunk
            in response.stream.timeout(const Duration(seconds: 30))) {
          buf.addAll(chunk);
          received += chunk.length;

          if (buf.length >= _flushThreshold) {
            sink.add(buf);
            await sink.flush();
            buf.clear();
          }

          onProgress(received);
        }
        if (buf.isNotEmpty) {
          sink.add(buf);
          await sink.flush();
        }
      } finally {
        await sink.close();
      }

      _log(onLog,
          '✅ Done — total on disk: ${_mb(await tmpFile.length())} MB');
      return _ChunkResult.done;
    } on TimeoutException {
      _log(onLog, '⏱️ Timeout');
      return _ChunkResult.networkError;
    } on SocketException catch (e) {
      _log(onLog, '📵 Socket: $e');
      return _ChunkResult.networkError;
    } on HttpException catch (e) {
      _log(onLog, '🌐 HTTP: $e');
      return _ChunkResult.networkError;
    }
  }

  // ─── URL resolution ─────────────────────────────────────────────────────────

  static Future<String?> _resolveDownloadUrl(
      String id, Function(String)? onLog) async {
    final scraped = await _scrapeConfirmUrl(id, onLog);
    if (scraped != null) return scraped;

    final direct =
        'https://drive.usercontent.google.com/download?id=$id&export=download&confirm=t';
    _log(onLog, '🔍 Trying usercontent direct...');
    if (await _urlServesFile(direct, onLog)) return direct;

    final classic =
        'https://drive.google.com/uc?export=download&id=$id&confirm=t';
    _log(onLog, '🔍 Trying classic uc...');
    if (await _urlServesFile(classic, onLog)) return classic;

    return null;
  }

  static Future<String?> _scrapeConfirmUrl(
      String id, Function(String)? onLog) async {
    try {
      _log(onLog, '🔍 Fetching Drive download page...');
      final pageUrl = 'https://drive.google.com/uc?export=download&id=$id';
      final resp = await http
          .get(Uri.parse(pageUrl), headers: _headers)
          .timeout(const Duration(seconds: 20));
      _log(onLog, '   Page status: ${resp.statusCode}');
      final body = resp.body;

      // Form action URL (full URL, HTML-encoded ampersands)
      final actionMatch = RegExp(
        r'''action=['"]'''
        r'''(https://drive\.usercontent\.google\.com/download[^'"]+)'''
        r'''['"]''',
        caseSensitive: false,
      ).firstMatch(body);
      if (actionMatch != null) {
        final url = actionMatch.group(1)!.replaceAll('&amp;', '&');
        _log(onLog, '✅ form action: $url');
        return url;
      }

      // href with usercontent link
      final hrefMatch = RegExp(
        r'''href=['"]'''
        r'''(https://drive\.usercontent\.google\.com/download[^'"]+)'''
        r'''['"]''',
        caseSensitive: false,
      ).firstMatch(body);
      if (hrefMatch != null) {
        final url = hrefMatch.group(1)!.replaceAll('&amp;', '&');
        _log(onLog, '✅ usercontent href: $url');
        return url;
      }

      // Classic confirm= token
      final confirmMatch =
          RegExp(r'[?&]confirm=([0-9A-Za-z_\-]+)').firstMatch(body);
      final uuidMatch =
          RegExp(r'[?&]uuid=([0-9A-Za-z_\-]+)').firstMatch(body);
      if (confirmMatch != null) {
        final confirm = confirmMatch.group(1)!;
        final uuid = uuidMatch?.group(1) ?? '';
        final uuidPart = uuid.isNotEmpty ? '&uuid=$uuid' : '';
        final url =
            'https://drive.google.com/uc?export=download&id=$id&confirm=$confirm$uuidPart';
        _log(onLog, '✅ confirm token: $url');
        return url;
      }

      _log(onLog, '   ⚠️ No link found in Drive page');
      if (kDebugMode) {
        print('--- Drive page snippet ---');
        print(body.substring(0, body.length.clamp(0, 1000)));
        print('--------------------------');
      }
      return null;
    } catch (e) {
      _log(onLog, '   ⚠️ Scrape failed: $e');
      return null;
    }
  }

  static Future<_DownloadMeta?> _probeUrl(
      String url, Function(String)? onLog) async {
    try {
      _log(onLog, '🔍 Probing URL for size + range support...');
      final resp = await http
          .head(Uri.parse(url),
              headers: {..._headers, 'Accept': '*/*', 'Range': 'bytes=0-0'})
          .timeout(const Duration(seconds: 15));

      // Content-Range: bytes 0-0/TOTAL — extract total from here when status=206
      int total = 0;
      final cr = resp.headers['content-range'];
      if (cr != null) {
        final m = RegExp(r'/(\d+)$').firstMatch(cr);
        if (m != null) total = int.tryParse(m.group(1)!) ?? 0;
      }
      if (total == 0) {
        total = int.tryParse(resp.headers['content-length'] ?? '') ?? 0;
      }

      final supportsRange =
          resp.headers['accept-ranges']?.contains('bytes') == true ||
              resp.statusCode == 206;

      _log(onLog,
          '   size=${_mb(total)} MB  resumable=$supportsRange');

      if (resp.statusCode >= 400) {
        _log(onLog, '❌ Probe returned ${resp.statusCode}');
        return null;
      }

      return _DownloadMeta(
        url: url,
        totalBytes: total,
        downloadedBytes: 0,
        supportsRange: supportsRange,
      );
    } catch (e) {
      _log(onLog, '   ⚠️ Probe failed ($e) — will attempt download anyway');
      return _DownloadMeta(
          url: url, totalBytes: 0, downloadedBytes: 0, supportsRange: false);
    }
  }

  static Future<bool> _urlServesFile(
      String url, Function(String)? onLog) async {
    try {
      final resp = await http
          .head(Uri.parse(url), headers: {..._headers, 'Accept': '*/*'})
          .timeout(const Duration(seconds: 10));
      final ct = resp.headers['content-type'] ?? '';
      final cl = int.tryParse(resp.headers['content-length'] ?? '') ?? 0;
      final ok = resp.statusCode == 200 &&
          !ct.contains('text/html') &&
          (cl == 0 || cl > 50000);
      _log(onLog,
          '   ${resp.statusCode} $ct ${_mb(cl)} MB → ${ok ? "✅" : "❌"}');
      return ok;
    } catch (e) {
      _log(onLog, '   ⚠️ $e');
      return false;
    }
  }

  // ─── Extraction ─────────────────────────────────────────────────────────────

  static Future<bool> _extractZip(
      File zipFile, Function(String)? onLog) async {
    _log(onLog, '📦 Extracting ZIP...');
    final bytes = await zipFile.readAsBytes();

    Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (e) {
      _log(onLog, '❌ ZIP decode failed: $e');
      return false;
    }

    if (archive.isEmpty) {
      _log(onLog, '❌ Archive is empty');
      return false;
    }

    _log(onLog, '📁 ${archive.length} entries');

    final dir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${dir.path}/audio_tune');
    if (!audioDir.existsSync()) audioDir.createSync(recursive: true);

    int extracted = 0;
    int failed = 0;

    for (final file in archive) {
      if (!file.isFile) continue;
      final name = file.name.split('/').last;
      if (name.isEmpty) continue;
      try {
        await File('${audioDir.path}/$name')
            .writeAsBytes(file.content as List<int>);
        extracted++;
      } catch (e) {
        _log(onLog, '   ✗ $name: $e');
        failed++;
      }
    }

    _log(onLog,
        '✅ $extracted files extracted${failed > 0 ? " ($failed failed)" : ""}');
    return extracted > 0;
  }

  // ─── Meta helpers ────────────────────────────────────────────────────────────

  static Future<_DownloadMeta?> _loadMeta(
      File metaFile, Function(String)? onLog) async {
    try {
      if (!await metaFile.exists()) return null;
      final json =
          jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>;
      final meta = _DownloadMeta.fromJson(json);
      _log(onLog,
          '📋 Resume meta: ${_mb(meta.downloadedBytes)} / ${_mb(meta.totalBytes)} MB');
      return meta;
    } catch (e) {
      _log(onLog, '   ⚠️ Could not load meta: $e');
      return null;
    }
  }

  static Future<void> _saveMeta(File metaFile, _DownloadMeta meta) async {
    try {
      await metaFile.writeAsString(jsonEncode(meta.toJson()));
    } catch (e) {
      if (kDebugMode) print('⚠️ saveMeta: $e');
    }
  }

  // ─── Utilities ───────────────────────────────────────────────────────────────

  static Future<Map<String, String>> _getPaths() async {
    final dir = await getApplicationDocumentsDirectory();
    return {
      'tmp': '${dir.path}/audio_download.zip.part',
      'meta': '${dir.path}/audio_download.meta.json',
    };
  }

  static Future<List<int>> _readFirstBytes(File f, int count) async {
    if (!await f.exists()) return [];
    final raf = await f.open();
    try {
      return await raf.read(count);
    } finally {
      await raf.close();
    }
  }

  static Future<void> _cleanup(File tmp, File meta) async {
    for (final f in [tmp, meta]) {
      try {
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }

  static bool _isHtml(List<int> bytes) {
    if (bytes.length < 50) return true;
    final head = String.fromCharCodes(bytes.take(600));
    return head.contains('<!DOCTYPE') ||
        head.contains('<html') ||
        head.contains('<HTML');
  }

  static String _mb(int bytes) => (bytes / 1048576).toStringAsFixed(1);

  static void _log(Function(String)? onLog, String msg) {
    if (kDebugMode) print(msg);
    onLog?.call(msg);
  }
}