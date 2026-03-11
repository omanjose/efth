import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../model/hymn_model.dart';

class SearchQueryController extends GetxController {
  final query = ''.obs;
  final TextEditingController queryController = TextEditingController();

  // Simple filter with lyrics search
  List<HymnModel> filter(List<HymnModel> hymns) {
    if (query.isEmpty) return hymns;

    final searchTerm = query.value.toLowerCase().trim();

    return hymns.where((hymn) {
      // Search in ID
      if (hymn.id.toString().contains(query.value)) {
        return true;
      }

      // Search in title
      if (hymn.title.toLowerCase().contains(searchTerm)) {
        return true;
      }

      // Search in lyrics ← NEW!
      if (hymn.lyrics.toLowerCase().contains(searchTerm)) {
        return true;
      }

      return false;
    }).toList();
  }

  // Clear search
  void clear() {
    query.value = '';
    queryController.clear();
  }

  @override
  void onClose() {
    queryController.dispose();
    super.onClose();
  }
}