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
    _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });
    _player.durationStream.listen((d) {
      duration.value = d ?? Duration.zero;
    });
    _player.positionStream.listen((p) {
      position.value = p;
    });
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        isPlaying.value = false;
      }
    });
  }

  /// Play a single downloaded file from disk.
  /// [filePath] is an absolute path e.g. /data/.../audio_tune/FTH0001.opus
  Future<void> playOne(String filePath) async {
    try {
      await stop();

      final file = File(filePath);
      if (!file.existsSync()) {
        if (kDebugMode) print('❌ Audio file not found: $filePath');
        return;
      }

      if (kDebugMode) print('🎵 Playing file: $filePath');
      await _player.setFilePath(filePath);
      await _player.play();
    } catch (e) {
      if (kDebugMode) print('❌ playOne error: $e');
    }
  }

  /// Play two downloaded files in sequence (for two-part hymns).
  /// Paths are absolute disk paths, e.g. FTH0134A.opus and FTH0134B.opus.
  Future<void> playTwo(String filePathA, String filePathB) async {
    try {
      await stop();

      final fileA = File(filePathA);
      final fileB = File(filePathB);

      if (!fileA.existsSync()) {
        if (kDebugMode) print('❌ Part A not found: $filePathA');
        // Fall back to part A only if B is missing, or just return
        return;
      }
      if (!fileB.existsSync()) {
        if (kDebugMode) print('⚠️ Part B not found — playing part A only');
        await playOne(filePathA);
        return;
      }

      if (kDebugMode) {
        print('🎵 Playing 2-part: $filePathA | $filePathB');
      }

      final playlist = ConcatenatingAudioSource(
        children: [
          AudioSource.file(filePathA),
          AudioSource.file(filePathB),
        ],
      );

      await _player.setAudioSource(playlist);
      await _player.play();
    } catch (e) {
      if (kDebugMode) print('❌ playTwo error: $e');
    }
  }

  void pause() {
    try {
      _player.pause();
    } catch (e) {
      if (kDebugMode) print('❌ pause error: $e');
    }
  }

  Future<void> resume() async {
    try {
      await _player.play();
    } catch (e) {
      if (kDebugMode) print('❌ resume error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      isPlaying.value = false;
      position.value = Duration.zero;
    } catch (e) {
      if (kDebugMode) print('❌ stop error: $e');
    }
  }

  Future<void> seek(Duration pos) async {
    try {
      await _player.seek(pos);
    } catch (e) {
      if (kDebugMode) print('❌ seek error: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      if (kDebugMode) print('❌ setVolume error: $e');
    }
  }

  bool get hasAudio => _player.audioSource != null;

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
  }
}