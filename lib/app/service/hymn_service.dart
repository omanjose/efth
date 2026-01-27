import 'dart:convert';
import 'package:flutter/services.dart';

import '../model/hymn_model.dart';


class HymnService {
  static Future<List<HymnModel>> loadAll() async {
    final langs = ['english', 'igbo', 'efik'];
    List<HymnModel> all = [];


    for (final lang in langs) {
      final data = await rootBundle.loadString('assets/hymns/$lang.json');
      final list = json.decode(data) as List;
      all.addAll(list.map((e) => HymnModel.fromJson(e, lang)));
    }
    return all;
  }
}