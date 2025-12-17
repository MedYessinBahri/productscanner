import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  // Play success sound (scan successful)
  static Future<void> playSuccessSound() async {
    try {
      // Play system click sound
      await SystemSound.play(SystemSoundType.click);
      
      // Also play a pleasant beep sound
      // Note: You can add custom sound files to assets/sounds/ for better feedback
      // For now, using system sounds
    } catch (e) {
      // Silently fail if sound can't be played
      print('Error playing success sound: $e');
    }
  }

  // Play error sound and vibrate (scan failed)
  static Future<void> playErrorSound() async {
    try {
      // Vibrate the device for error feedback
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // Pattern: wait 0ms, vibrate 200ms, wait 100ms, vibrate 200ms
        await Vibration.vibrate(
          pattern: [0, 200, 100, 200],
          intensities: [0, 128, 0, 255],
        );
      }
      
      // Also play alert sound
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      // Silently fail if vibration/sound can't be played
      print('Error playing error feedback: $e');
    }
  }

  // Play scanning sound (when starting to scan)
  static Future<void> playScanningSound() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silently fail if sound can't be played
      print('Error playing scanning sound: $e');
    }
  }

  // Cancel any ongoing vibration
  static Future<void> cancelVibration() async {
    try {
      await Vibration.cancel();
    } catch (e) {
      print('Error canceling vibration: $e');
    }
  }

  // Dispose audio player resources
  static Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      print('Error disposing audio player: $e');
    }
  }
}