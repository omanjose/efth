import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../service/audio_service.dart';

class AudioController extends GetxController with WidgetsBindingObserver {
  final AudioService service = Get.put(AudioService());

  final isPlaying = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    service.player1.playerStateStream.listen((state){
      if (state.playing &&
          state.processingState != ProcessingState.completed) {
        isPlaying.value = true;
      } else {
        isPlaying.value = false;
      }
    });
    service.player2.playerStateStream.listen((state){
      if (state.playing &&
          state.processingState != ProcessingState.completed) {
        isPlaying.value = true;
      } else {
        isPlaying.value = false;
      }
    });
  }

  Future<void> playOne(String asset) async {
    await service.playOne(asset);
  }

  Future<void> playTwo(String a, String b) async {
    await service.playTwo(a, b);
  }

  void pause() {
    service.pause();
  }

  void stop() {
    service.stop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      stop();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    stop();
    super.onClose();
  }
}
