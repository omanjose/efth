import 'dart:io';
import 'package:efth/app/service/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../model/hymn_model.dart';
import '../service/hymn_service.dart';

class HymnController extends GetxController {
  final allHymns = <HymnModel>[].obs;
  final language = 'english'.obs;
  final _isLoading = false.obs;
  final selectedLanguage = 'English'.obs;
  final _fontSize = 8.0.obs;
  final _isFavorite = false.obs;

  @override
  void onInit() {
    load();
    _loadFontSize();
    super.onInit();
  }

  bool get isLoading => _isLoading.value;
  double get fontSize => _fontSize.value;
  bool get isFavorite => _isFavorite.value;
  String get selectedHymnLanguage => selectedLanguage.value;

  Future<void> load() async {
    _isLoading.value = true;
    try {
      final loadedHymns = await HymnService.loadAll();

      // ── DIAGNOSTIC ──────────────────────────────────────────────────────
      if (kDebugMode) {
        print('📚 HymnService returned ${loadedHymns.length} hymns total');

        if (loadedHymns.isEmpty) {
          print('❌ EMPTY — HymnService.loadAll() returned no hymns');
        } else {
          // Show unique language values actually present in the data
          final langs = loadedHymns.map((h) => h.language).toSet().toList();
          print('🌍 Languages found in data: $langs');

          // Count per language
          for (final lang in langs) {
            final count = loadedHymns.where((h) => h.language == lang).length;
            print('   "$lang" → $count hymns');
          }

          // Show first 3 hymns so we can see the shape
          print('📋 First 3 hymns:');
          for (final h in loadedHymns.take(3)) {
            print('   id=${h.id} lang="${h.language}" title="${h.title}"');
          }

          // Check if 'english' (lowercase) exists — that's what language.value defaults to
          final englishCount =
              loadedHymns.where((h) => h.language == 'english').length;
          print(
              '🔍 Hymns matching language=="english": $englishCount');
          if (englishCount == 0) {
            print(
                '⚠️  MISMATCH — default language is "english" but no hymns have that value');
            print(
                '   Fix: either change language.value default OR fix HymnService language strings');
          }
        }
      }
      // ── END DIAGNOSTIC ──────────────────────────────────────────────────

      await _checkAudioFiles(loadedHymns);

      // Assign list then clear loading flag in the same microtask batch
      allHymns.value = loadedHymns;
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ load() error: $e');
        print(st);
      }
    } finally {
      _isLoading.value = false;
    }
  }

  static String _stem(int id) => 'FTH${id.toString().padLeft(4, '0')}';

  Future<void> _checkAudioFiles(List<HymnModel> hymns) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/audio_tune');

      if (!await audioDir.exists()) {
        for (final h in hymns) {
          h.hasAudio = false;
          h.audioPath = null;
        }
        return;
      }

      final fileMap = <String, String>{};
      for (final entity in audioDir.listSync()) {
        if (entity is File) {
          final name = entity.path.split('/').last;
          final stem = name.contains('.')
              ? name.substring(0, name.lastIndexOf('.'))
              : name;
          fileMap[stem] = entity.path;
        }
      }

      int found = 0;
      for (final hymn in hymns) {
        final stem = _stem(hymn.id);
        if (fileMap.containsKey(stem)) {
          hymn.hasAudio = true;
          hymn.audioPath = fileMap[stem];
          found++;
          continue;
        }
        final stemA = '${stem}A';
        final stemB = '${stem}B';
        if (fileMap.containsKey(stemA) && fileMap.containsKey(stemB)) {
          hymn.hasAudio = true;
          hymn.audioPath = fileMap[stemA]!.replaceAll('A.opus', '.opus');
          found++;
          continue;
        }
        hymn.hasAudio = false;
        hymn.audioPath = null;
      }

      if (kDebugMode) print('🎵 Audio matched: $found / ${hymns.length}');
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ _checkAudioFiles: $e');
        print(st);
      }
    }
  }

  Future<void> refreshAudioStatus() async {
    if (kDebugMode) print('🔄 Refreshing audio status...');
    await _checkAudioFiles(allHymns);
    allHymns.refresh();
    if (kDebugMode) print('✅ Refresh complete');
  }

  List<HymnModel> get hymns =>
      allHymns.where((h) => h.language == language.value).toList();

  void _loadFontSize() => _fontSize.value = StorageService.getFontSize();

  void increaseFontSize() {
    if (_fontSize.value < 30) {
      _fontSize.value += 1;
      StorageService.setFontSize(_fontSize.value);
    }
  }

  void decreaseFontSize() {
    if (_fontSize.value > 10) {
      _fontSize.value -= 1;
      StorageService.setFontSize(_fontSize.value);
    }
  }

  void resetFontSize() {
    _fontSize.value = 10;
    StorageService.setFontSize(_fontSize.value);
  }

  void changeLanguage(String lang) => language.value = lang;
}