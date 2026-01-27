import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AudioService extends GetxController {
  final player1 = AudioPlayer();
  final player2 = AudioPlayer();

  Future<void> playOne(String asset) async {
    await stop();
    await player1.setAsset(asset);
    await player1.play();
  }

  Future<void> playTwo(String a, String b) async {
    await stop();

    await player1.setAsset(a);
    await player2.setAsset(b);

    await player1.play();
    await player2.play();
  }

  Future<void> pause() async {
    await player1.pause();
    await player2.pause();
  }

  Future<void> stop() async {
    await player1.stop();
    await player2.stop();
  }

  @override
  void onClose() {
    player1.dispose();
    player2.dispose();
    super.onClose();
  }
}
