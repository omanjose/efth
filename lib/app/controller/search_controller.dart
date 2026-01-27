import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../model/hymn_model.dart';

class SearchQueryController extends GetxController {
  final query = ''.obs;
  final TextEditingController queryController = TextEditingController();

  List<HymnModel> filter(List<HymnModel> hymns) {
    if (query.isEmpty) return hymns;
    return hymns.where((h) {
      return h.title.toLowerCase().contains(query.value.toLowerCase()) ||
          h.id.toString().contains(query.value);
    }).toList();
  }
}
