import 'dart:io';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class AudioController extends GetxController {
  final AudioPlayer _player1 = AudioPlayer();
  final AudioPlayer _player2 = AudioPlayer();

  final isPlaying = false.obs;
  final duration = Duration.zero.obs;
  final position = Duration.zero.obs;

  @override
  void onInit() {
    super.onInit();
    _initializePlayer();
  }

  void _initializePlayer() {
    // Listen to player state changes
    _player1.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    // Listen to duration changes
    _player1.durationStream.listen((d) {
      duration.value = d ?? Duration.zero;
    });

    // Listen to position changes
    _player1.positionStream.listen((p) {
      position.value = p;
    });

    // Listen for completion
    _player1.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        isPlaying.value = false;
      }
    });
  }

  /// Play single audio from asset path
  Future<void> playOne(String assetPath) async {
    try {
      if (kDebugMode) {
        print('🎵 Playing audio from asset: $assetPath');
      }

      await stop();
      await _player1.setAsset(assetPath);
      await _player1.play();

      if (kDebugMode) {
        print('✅ Playback started from asset');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error playing from asset: $e');
      }
      rethrow;
    }
  }

  /// Play single audio from file path
  Future<void> playOneFromFile(File file) async {
    try {
      if (kDebugMode) {
        print('🎵 Playing audio from file: ${file.path}');
      }

      await stop();

      // Verify file exists
      if (!await file.exists()) {
        throw Exception('Audio file does not exist: ${file.path}');
      }

      final fileSize = await file.length();
      if (kDebugMode) {
        print('📦 File size: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      }

      await _player1.setFilePath(file.path);
      await _player1.play();

      if (kDebugMode) {
        print('✅ Playback started from file');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error playing from file: $e');
      }
      rethrow;
    }
  }

  /// Play two audio files in sequence (from asset paths)
  Future<void> playTwo(String assetPathA, String assetPathB) async {
    try {
      if (kDebugMode) {
        print('🎵 Playing two-part audio from assets:');
        print('   Part A: $assetPathA');
        print('   Part B: $assetPathB');
      }

      await stop();

      // Create concatenating audio source from assets
      final playlist = ConcatenatingAudioSource(
        children: [
          AudioSource.asset(assetPathA),
          AudioSource.asset(assetPathB),
        ],
      );

      await _player1.setAudioSource(playlist);
      await _player1.play();

      if (kDebugMode) {
        print('✅ Two-part playback started from assets');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error playing two-part from assets: $e');
      }
      rethrow;
    }
  }

  /// Play two audio files in sequence (from file paths)
  Future<void> playTwoFromFiles(File fileA, File fileB) async {
    try {
      if (kDebugMode) {
        print('🎵 Playing two-part audio from files:');
        print('   Part A: ${fileA.path}');
        print('   Part B: ${fileB.path}');
      }

      await stop();

      // Verify both files exist
      if (!await fileA.exists()) {
        throw Exception('Audio file A does not exist: ${fileA.path}');
      }
      if (!await fileB.exists()) {
        throw Exception('Audio file B does not exist: ${fileB.path}');
      }

      if (kDebugMode) {
        final sizeA = await fileA.length();
        final sizeB = await fileB.length();
        print('📦 Part A size: ${(sizeA / 1024).toStringAsFixed(2)} KB');
        print('📦 Part B size: ${(sizeB / 1024).toStringAsFixed(2)} KB');
      }

      // Create concatenating audio source from file paths
      final playlist = ConcatenatingAudioSource(
        children: [
          AudioSource.file(fileA.path),
          AudioSource.file(fileB.path),
        ],
      );

      await _player1.setAudioSource(playlist);
      await _player1.play();

      if (kDebugMode) {
        print('✅ Two-part playback started from files');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error playing two-part from files: $e');
      }
      rethrow;
    }
  }

  /// Pause playback
  void pause() {
    try {
      if (kDebugMode) {
        print('⏸️ Pausing playback');
      }
      _player1.pause();
      _player2.pause();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error pausing: $e');
      }
    }
  }

  /// Resume playback
  Future<void> resume() async {
    try {
      if (kDebugMode) {
        print('▶️ Resuming playback');
      }
      await _player1.play();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error resuming: $e');
      }
    }
  }

  /// Stop all playback
  Future<void> stop() async {
    try {
      if (kDebugMode) {
        print('⏹️ Stopping playback');
      }
      await _player1.stop();
      await _player2.stop();
      isPlaying.value = false;
      position.value = Duration.zero;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error stopping: $e');
      }
    }
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    try {
      if (kDebugMode) {
        print('⏩ Seeking to ${position.inSeconds}s');
      }
      await _player1.seek(position);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error seeking: $e');
      }
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _player1.setVolume(volume.clamp(0.0, 1.0));
      await _player2.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error setting volume: $e');
      }
    }
  }

  /// Get current playback state
  String get playbackState {
    final state = _player1.processingState;
    switch (state) {
      case ProcessingState.idle:
        return 'Idle';
      case ProcessingState.loading:
        return 'Loading';
      case ProcessingState.buffering:
        return 'Buffering';
      case ProcessingState.ready:
        return isPlaying.value ? 'Playing' : 'Paused';
      case ProcessingState.completed:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  /// Check if audio is loaded
  bool get hasAudio => _player1.audioSource != null;

  @override
  void onClose() {
    if (kDebugMode) {
      print('🔇 Disposing audio players');
    }
    _player1.dispose();
    _player2.dispose();
    super.onClose();
  }
}