import 'dart:io';
import 'dart:convert';
import 'package:efth/app/controller/hymn_controller.dart';
import 'package:efth/utils/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../service/download_service.dart';

class SettingsController extends GetxController {
  final ThemeService themeService = Get.find<ThemeService>();
  final HymnController hymnController = Get.find<HymnController>();

  final isDownloading = false.obs;
  final downloaded = false.obs;
  final progress = 0.0.obs;
  final isCheckingAudio = true.obs;

  /// True when a partial download exists on disk (can be resumed)
  final hasPartialDownload = false.obs;

  /// Bytes already saved for a partial download (shown in UI)
  final partialBytes = 0.obs;

  @override
  void onInit() {
    super.onInit();
    checkAudioAvailability();
  }

  // ─── Audio status ────────────────────────────────────────────────────────────

  Future<void> checkAudioAvailability() async {
    try {
      isCheckingAudio.value = true;

      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/audio_tune');

      if (!await audioDir.exists()) {
        downloaded.value = false;
      } else {
        final files = audioDir
            .listSync()
            .where((f) =>
                f is File &&
                (f.path.endsWith('.opus') || f.path.endsWith('.mp3')))
            .toList();
        downloaded.value = files.isNotEmpty;

        if (kDebugMode && downloaded.value) {
          final size = files.fold<int>(
              0, (s, f) => s + (f as File).lengthSync());
          print('✅ Audio: ${files.length} files, '
              '${(size / 1048576).toStringAsFixed(1)} MB');
        }
      }

      // Check for a partial download
      await _checkPartialDownload(dir);
    } catch (e) {
      if (kDebugMode) print('❌ checkAudioAvailability: $e');
      downloaded.value = false;
    } finally {
      isCheckingAudio.value = false;
    }
  }

  Future<void> _checkPartialDownload(Directory dir) async {
    try {
      final tmpFile = File('${dir.path}/audio_download.zip.part');
      final metaFile = File('${dir.path}/audio_download.meta.json');

      if (await tmpFile.exists() && await metaFile.exists()) {
        final bytes = await tmpFile.length();
        if (bytes > 0) {
          hasPartialDownload.value = true;
          partialBytes.value = bytes;
          if (kDebugMode) {
            print('📋 Partial download found: '
                '${(bytes / 1048576).toStringAsFixed(1)} MB');
          }
          return;
        }
      }
      hasPartialDownload.value = false;
      partialBytes.value = 0;
    } catch (_) {
      hasPartialDownload.value = false;
    }
  }

  // ─── Download / Resume ───────────────────────────────────────────────────────

  Future<void> downloadAudio() async {
    try {
      isDownloading.value = true;
      progress.value = 0.0;

      final success = await DownloadService.downloadAndExtract(
        onProgress: (p) => progress.value = p,
        onLog: (msg) {
          if (kDebugMode) print(msg);
        },
      );

      if (success) {
        await checkAudioAvailability();
        await hymnController.refreshAudioStatus();
        Get.snackbar(
          '✅ Download Complete',
          'Audio files are ready for offline playback.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        // Not a full failure if there's a partial file — show resume message
        await checkAudioAvailability();
        final partial = hasPartialDownload.value;
        Get.snackbar(
          partial ? '📶 Download Paused' : '❌ Download Failed',
          partial
              ? 'Progress saved. Tap Download again to resume.'
              : 'Could not download audio files. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ downloadAudio: $e');
      Get.snackbar(
        '❌ Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isDownloading.value = false;
      progress.value = 0.0;
    }
  }

  /// Discard partial download and start fresh.
  Future<void> cancelAndReset() async {
    await DownloadService.cancelDownload();
    hasPartialDownload.value = false;
    partialBytes.value = 0;
  }

  // ─── Delete ──────────────────────────────────────────────────────────────────

  Future<void> deleteAudioFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/audio_tune');

      if (await audioDir.exists()) {
        await audioDir.delete(recursive: true);
        downloaded.value = false;
        await hymnController.refreshAudioStatus();
        Get.snackbar(
          '✅ Deleted',
          'Audio files deleted successfully.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ deleteAudioFiles: $e');
      Get.snackbar(
        '❌ Error',
        'Could not delete audio files: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ─── Theme ───────────────────────────────────────────────────────────────────

  void changeTheme(ThemeMode mode) => themeService.setThemeMode(mode);

  String getThemeModeString() {
    switch (themeService.themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      default:
        return 'System';
    }
  }
}