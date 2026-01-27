class HymnModel {
  final int id;
  final String title;
  final String lyrics;
  final String audio;
  final String language;


  HymnModel({
    required this.id,
    required this.title,
    required this.lyrics,
    required this.audio,
    required this.language,
  });


  factory HymnModel.fromJson(Map<String, dynamic> json, String lang) {
    return HymnModel(
      id: json['id'],
      title: json['title'],
      lyrics: json['lyrics'],
      audio: json['audio'],
      language: lang,
    );
  }
}