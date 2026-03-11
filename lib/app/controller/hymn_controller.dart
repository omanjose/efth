import 'package:efth/app/service/storage_service.dart';
import 'package:get/get.dart';

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
    // _checkFavoriteStatus();
    super.onInit();
  }
bool get isLoading => _isLoading.value;
double get fontSize => _fontSize.value;
bool get isFavorite => _isFavorite.value;
String get selectedHymnLanguage => selectedLanguage.value;

  Future<void> load() async {
    allHymns.value = await HymnService.loadAll();
  }


  void _loadFontSize() {
    _fontSize.value = StorageService.getFontSize();
  }

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


  List<HymnModel> get hymns =>
      allHymns.where((h) => h.language == language.value).toList();


  void changeLanguage(String lang) => language.value = lang;

}