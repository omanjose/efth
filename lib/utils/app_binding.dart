import 'package:efth/app/service/audio_service.dart';
import 'package:get/get.dart';

import '../app/controller/audio_controller.dart';
import '../app/controller/favorite_controller.dart';
import '../app/controller/hymn_controller.dart';
import '../app/controller/search_controller.dart';


class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HymnController());
    Get.put(AudioController());
    Get.put(AudioService());
    Get.put(FavouriteController());
    Get.put(SearchQueryController());
  }
}