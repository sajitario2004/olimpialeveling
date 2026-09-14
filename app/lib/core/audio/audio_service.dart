import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();
  final AudioPlayer _player = AudioPlayer();

  AudioService._internal() {
    _player.setVolume(1.0);
  }

  Future<void> playLevelUp() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/system_level_up.wav'));
    } catch (e) {
      debugPrint('AudioService: Error playing level up sound: $e');
    }
  }

  Future<void> playPenaltyAlert() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/penalty_alert.wav'));
    } catch (e) {
      debugPrint('AudioService: Error playing penalty sound: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
