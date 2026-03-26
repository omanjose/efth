import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AudioService extends GetxController {
  final player1 = AudioPlayer();
  final player2 = AudioPlayer();

  // final AudioDownloadService _downloadService = Get.find<AudioDownloadService>();

  final isPlaying = false.obs;
  final duration = Duration.zero.obs;
  final position = Duration.zero.obs;
  final currentHymnId = ''.obs;
  final isAudioAvailable = false.obs;


  // Future<bool> loadAudio(String audioId) async {
  //   try {
  //     currentHymnId.value = audioId;
  //
  //     // Check if audio file is downloaded
  //     final audioPath = await _downloadService.getAudioPath(audioId);
  //
  //     if (audioPath == null) {
  //       isAudioAvailable.value = false;
  //       return false;
  //     }
  //
  //     await player1.setFilePath(audioPath);
  //     isAudioAvailable.value = true;
  //     return true;
  //   } catch (e) {
  //     debugPrint('Error loading audio: $e');
  //     isAudioAvailable.value = false;
  //     return false;
  //   }
  // }

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
