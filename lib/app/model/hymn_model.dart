import 'package:get/get.dart';

class HymnModel {
  final int id;
  final String title;
  final String lyrics;

  // Mutable — HymnService sets this after fromJson since the JSON files
  // don't contain a language field.
  String? language;

  // Reactive audio fields so any Obx reading them rebuilds automatically
  // when refreshAudioStatus() writes new values after a download.
  final RxnBool _hasAudio = RxnBool(false);
  final RxnString _audioPath = RxnString(null);

  bool get hasAudio => _hasAudio.value ?? false;
  set hasAudio(bool v) => _hasAudio.value = v;

  String? get audioPath => _audioPath.value;
  set audioPath(String? v) => _audioPath.value = v;

  HymnModel({
    required this.id,
    required this.title,
    required this.lyrics,
    this.language,
    bool hasAudio = false,
    String? audioPath,
  }) {
    _hasAudio.value = hasAudio;
    _audioPath.value = audioPath;
  }

  factory HymnModel.fromJson(Map<String, dynamic> json) => HymnModel(
    id: json['id'] as int,
    title: json['title'] as String,
    lyrics: json['lyrics'] as String,
    // language intentionally omitted — HymnService injects it
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'lyrics': lyrics,
    'language': language,
    'hasAudio': hasAudio,
    'audioPath': audioPath,
  };
}