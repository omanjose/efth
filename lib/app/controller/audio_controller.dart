import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AudioController extends GetxController {
  final AudioPlayer _player = AudioPlayer();

  final isPlaying = false.obs;
  final duration = Duration.zero.obs;
  final position = Duration.zero.obs;

  @override
  void onInit() {
    super.onInit();

    // Derive isPlaying from the combined playerState stream.
    // PlayerState carries both playing flag AND processingState, so we
    // can set isPlaying=false the moment the track completes or is stopped
    // without two listeners racing each other.
    _player.playerStateStream.listen((state) {
      final completed = state.processingState == ProcessingState.completed;
      final idle      = state.processingState == ProcessingState.idle;
      isPlaying.value = state.playing && !completed && !idle;
    });

    _player.durationStream.listen((d) {
      duration.value = d ?? Duration.zero;
    });

    _player.positionStream.listen((p) {
      position.value = p;
    });
  }

  /// Play a single downloaded file from disk.
  Future<void> playOne(String filePath) async {
    try {
      await stop();
      final file = File(filePath);
      if (!file.existsSync()) {
        if (kDebugMode) print('❌ File not found: $filePath');
        return;
      }
      if (kDebugMode) print('🎵 Playing: $filePath');
      await _player.setFilePath(filePath);
      await _player.play();
    } catch (e) {
      if (kDebugMode) print('❌ playOne: $e');
    }
  }

  /// Play two downloaded files in sequence (two-part hymns).
  Future<void> playTwo(String filePathA, String filePathB) async {
    try {
      await stop();

      final fileA = File(filePathA);
      final fileB = File(filePathB);

      if (!fileA.existsSync()) {
        if (kDebugMode) print('❌ Part A not found: $filePathA');
        return;
      }
      if (!fileB.existsSync()) {
        if (kDebugMode) print('⚠️ Part B not found — playing part A only');
        await playOne(filePathA);
        return;
      }

      if (kDebugMode) print('🎵 2-part: $filePathA | $filePathB');

      await _player.setAudioSource(ConcatenatingAudioSource(
        children: [
          AudioSource.file(filePathA),
          AudioSource.file(filePathB),
        ],
      ));
      await _player.play();
    } catch (e) {
      if (kDebugMode) print('❌ playTwo: $e');
    }
  }

  void pause() {
    try {
      _player.pause();
    } catch (e) {
      if (kDebugMode) print('❌ pause: $e');
    }
  }

  Future<void> resume() async {
    try {
      await _player.play();
    } catch (e) {
      if (kDebugMode) print('❌ resume: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      // stop() puts the player in idle — playerStateStream will fire and
      // set isPlaying=false, but we also set it here immediately so the
      // UI updates without waiting for the stream event.
      isPlaying.value = false;
      position.value = Duration.zero;
    } catch (e) {
      if (kDebugMode) print('❌ stop: $e');
    }
  }

  Future<void> seek(Duration pos) async {
    try {
      await _player.seek(pos);
    } catch (e) {
      if (kDebugMode) print('❌ seek: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      if (kDebugMode) print('❌ setVolume: $e');
    }
  }

  bool get hasAudio => _player.audioSource != null;

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}