import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _useCustomSounds = true;

  /// Initialize audio service and check for custom sound files
  static Future<void> initialize() async {
    try {
      // Check if custom sound files exist
      await rootBundle.load('assets/sounds/success.mp3');
      _useCustomSounds = true;
      print('✅ Custom sound files loaded successfully');
    } catch (e) {
      _useCustomSounds = false;
      print('⚠️ Custom sounds not found, using system sounds as fallback');
    }
  }

  /// Play success sound (scan successful)
  static Future<void> playSuccessSound() async {
    try {
      if (_useCustomSounds) {
        // Play custom success sound from assets
        await _audioPlayer.play(AssetSource('sounds/success.mp3'));
      } else {
        // Fallback to system sound
        await SystemSound.play(SystemSoundType.click);
      }
    } catch (e) {
      print('Error playing success sound: $e');
      // Final fallback to system sound
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  /// Play error sound and vibrate (scan failed)
  static Future<void> playErrorSound() async {
    try {
      // Vibrate the device for error feedback
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // Pattern: vibrate 200ms, wait 100ms, vibrate 200ms
        await Vibration.vibrate(
          pattern: [0, 200, 100, 200],
          intensities: [0, 128, 0, 255],
        );
      }

      // Play error sound
      if (_useCustomSounds) {
        // Play custom error sound from assets
        await _audioPlayer.play(AssetSource('sounds/error.mp3'));
      } else {
        // Fallback to system alert sound
        await SystemSound.play(SystemSoundType.alert);
      }
    } catch (e) {
      print('Error playing error feedback: $e');
      // Final fallback to system alert
      try {
        await SystemSound.play(SystemSoundType.alert);
      } catch (_) {}
    }
  }

  /// Play scanning sound (when starting to scan)
  static Future<void> playScanningSound() async {
    try {
      if (_useCustomSounds) {
        // Play custom scanning sound from assets
        await _audioPlayer.play(AssetSource('sounds/scanning.mp3'));
      } else {
        // Fallback to system click
        await SystemSound.play(SystemSoundType.click);
      }
    } catch (e) {
      print('Error playing scanning sound: $e');
      // Final fallback to system click
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  /// Cancel any ongoing vibration
  static Future<void> cancelVibration() async {
    try {
      await Vibration.cancel();
    } catch (e) {
      print('Error canceling vibration: $e');
    }
  }

  /// Stop currently playing audio
  static Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }

  /// Dispose audio player resources
  static Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      print('Error disposing audio player: $e');
    }
  }

  /// Check if custom sounds are being used
  static bool isUsingCustomSounds() {
    return _useCustomSounds;
  }
}