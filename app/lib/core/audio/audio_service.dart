import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();
  AudioPlayer? _player;
  bool _initFailed = false;

  AudioService._internal();

  void _ensurePlayer() {
    if (_player == null && !_initFailed) {
      try {
        _player = AudioPlayer();
        _player!.setVolume(1.0);
      } catch (e) {
        _initFailed = true;
        debugPrint('AudioService: Native audio channel not available: $e');
      }
    }
  }

  Future<void> playLevelUp() async {
    try {
      _ensurePlayer();
      if (_player != null) {
        await _player!.stop();
        await _player!.play(AssetSource('sounds/system_level_up.wav'));
      }
    } catch (e) {
      debugPrint('AudioService: Error playing level up sound: $e');
    }
  }

  Future<void> playPenaltyAlert() async {
    try {
      _ensurePlayer();
      if (_player != null) {
        await _player!.stop();
        await _player!.play(AssetSource('sounds/penalty_alert.wav'));
      }
    } catch (e) {
      debugPrint('AudioService: Error playing penalty sound: $e');
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
