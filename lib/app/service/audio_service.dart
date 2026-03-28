import 'dart:io';
import 'package:just_audio/just_audio.dart';

class AudioService {
  final player1 = AudioPlayer();
  final player2 = AudioPlayer();

  /// Play single asset audio
  Future<void> playOne(String assetPath) async {
    await stop();
    await player1.setAsset(assetPath);
    await player1.play();
  }

  /// Play single file audio
  Future<void> playOneFromFile(File file) async {
    await stop();
    await player1.setFilePath(file.path);
    await player1.play();
  }

  /// Play two assets in sequence
  Future<void> playTwo(String assetA, String assetB) async {
    await stop();

    // Set up concatenating audio source
    final playlist = ConcatenatingAudioSource(
      children: [
        AudioSource.asset(assetA),
        AudioSource.asset(assetB),
      ],
    );

    await player1.setAudioSource(playlist);
    await player1.play();
  }

  /// Play two files in sequence
  Future<void> playTwoFromFiles(File fileA, File fileB) async {
    await stop();

    // Set up concatenating audio source from files
    final playlist = ConcatenatingAudioSource(
      children: [
        AudioSource.file(fileA.path),
        AudioSource.file(fileB.path),
      ],
    );

    await player1.setAudioSource(playlist);
    await player1.play();
  }

  /// Pause playback
  void pause() {
    player1.pause();
    player2.pause();
  }

  /// Stop all playback
  Future<void> stop() async {
    await player1.stop();
    await player2.stop();
  }

  /// Dispose players
  void dispose() {
    player1.dispose();
    player2.dispose();
  }
}