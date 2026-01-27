import 'package:efth/app/model/hymn_model.dart';
import 'package:efth/app/service/db_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavouriteController extends GetxController {
  final favourites = <String>[].obs;
  final favouriteHymns = <HymnModel>[].obs;
  final _searchController = TextEditingController();
  final _filteredFavorites = <HymnModel>[].obs;

  String _key(HymnModel h) => '${h.language}_${h.id}';

  @override
  void onInit() {
    load();
    super.onInit();
  }

  Future<void> load() async {
    final db = await DBService.db;
    final res = await db.query('fav');

    favouriteHymns.value = res
        .map(
          (e) => HymnModel(
            id: e['id'] as int,
            title: e['title'] as String,
            lyrics: e['lyrics'] as String,
            audio: e['audio'] as String,
            language: e['language'] as String,
          ),
        )
        .toList();

    favourites.value = favouriteHymns.map((h) => _key(h)).toList();
  }

  bool isFavourite(HymnModel hymn) {
    return favourites.contains(_key(hymn));
  }

  Future<void> toggle(HymnModel hymn) async {
    final db = await DBService.db;
    final key = _key(hymn);

    if (isFavourite(hymn)) {
      await db.delete('fav', where: 'key = ?', whereArgs: [key]);
      
    } else {
      await db.insert('fav', {
        'key': key,
        'id': hymn.id,
        'title': hymn.title,
        'language': hymn.language,
        'lyrics': hymn.lyrics,
        'audio': hymn.audio,
      });
    }

    await load();
  }

  Future<void> removeFavorite(HymnModel hymn) async {
    final db = await DBService.db;
    final key = _key(hymn);
    await db.delete('fav', where: 'key = ?', whereArgs: [key]);
    Get.snackbar(
      'Removed',
      '${hymn.title} removed from favorites',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

}
