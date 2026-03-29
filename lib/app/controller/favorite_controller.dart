import 'dart:io';

import 'package:efth/app/model/hymn_model.dart';
import 'package:efth/app/service/db_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class FavouriteController extends GetxController {
  final favourites = <String>[].obs;
  final favouriteHymns = <HymnModel>[].obs;
  final filteredFavorites = <HymnModel>[].obs;

  /// Unique key per hymn — language + id
  String _key(HymnModel h) => '${h.language}_${h.id}';

  /// Audio files are named FTH0001.opus (same as HymnController)
  static String _audioStem(int id) => 'FTH${id.toString().padLeft(4, '0')}';

  @override
  void onInit() {
    load();
    super.onInit();
  }

  Future<void> load() async {
    try {
      final db = await DBService.db;
      final rows = await db.query('fav');
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/audio_tune');

      // Build stem→path map once (same approach as HymnController)
      final fileMap = <String, String>{};
      if (await audioDir.exists()) {
        for (final entity in audioDir.listSync()) {
          if (entity is File) {
            final name = entity.path.split('/').last;
            final stem = name.contains('.')
                ? name.substring(0, name.lastIndexOf('.'))
                : name;
            fileMap[stem] = entity.path;
          }
        }
      }

      final List<HymnModel> loaded = [];

      for (final row in rows) {
        final hymn = HymnModel(
          id: row['id'] as int,
          title: row['title'] as String,
          lyrics: row['lyrics'] as String,
          language: row['language'] as String?,
        );

        // Match audio using FTH-prefixed naming
        final stem = _audioStem(hymn.id);

        if (fileMap.containsKey(stem)) {
          hymn.hasAudio = true;
          hymn.audioPath = fileMap[stem];
        } else {
          // Two-part hymns: FTH0134A + FTH0134B
          final stemA = '${stem}A';
          final stemB = '${stem}B';
          if (fileMap.containsKey(stemA) && fileMap.containsKey(stemB)) {
            hymn.hasAudio = true;
            hymn.audioPath = fileMap[stemA]!.replaceAll('A.opus', '.opus');
          } else {
            hymn.hasAudio = false;
            hymn.audioPath = null;
          }
        }

        loaded.add(hymn);
      }

      favouriteHymns.value = loaded;
      favourites.value = loaded.map((h) => _key(h)).toList();
      filteredFavorites.value = loaded;

      if (kDebugMode) print('⭐ Favourites loaded: ${loaded.length}');
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ FavouriteController.load: $e');
        print(st);
      }
    }
  }

  bool isFavourite(HymnModel hymn) => favourites.contains(_key(hymn));

  Future<void> toggle(HymnModel hymn) async {
    try {
      final db = await DBService.db;
      final key = _key(hymn);

      if (isFavourite(hymn)) {
        await db.delete('fav', where: 'key = ?', whereArgs: [key]);
        Get.snackbar(
          'Removed',
          '${hymn.title} removed from favorites',
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(8),
        );
      } else {
        await db.insert('fav', {
          'key': key,
          'id': hymn.id,
          'title': hymn.title,
          'language': hymn.language,
          'lyrics': hymn.lyrics,
        });
        Get.snackbar(
          'Added',
          '${hymn.title} added to favorites',
          colorText: Colors.white,
          backgroundColor: Colors.green,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(8),
        );
      }

      await load();
    } catch (e) {
      if (kDebugMode) print('❌ toggle: $e');
    }
  }

  Future<void> removeFavorite(HymnModel hymn) async {
    try {
      final db = await DBService.db;
      await db.delete('fav', where: 'key = ?', whereArgs: [_key(hymn)]);
      Get.snackbar(
        'Removed',
        '${hymn.title} removed from favorites',
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(8),
      );
      await load();
    } catch (e) {
      if (kDebugMode) print('❌ removeFavorite: $e');
    }
  }

  void filterFavorites(String query) {
    if (query.isEmpty) {
      filteredFavorites.value = favouriteHymns;
      return;
    }
    final q = query.toLowerCase();
    filteredFavorites.value = favouriteHymns.where((h) {
      return h.title.toLowerCase().contains(q) ||
          h.id.toString().contains(q) ||
          h.lyrics.toLowerCase().contains(q);
    }).toList();
  }

  void clearFilter() => filteredFavorites.value = favouriteHymns;
}