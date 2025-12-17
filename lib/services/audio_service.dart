import 'package:flutter/services.dart';

class AudioService {
  // Play success sound (scan successful)
  static Future<void> playSuccessSound() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silently fail if sound can't be played
    }
  }

  // Play error sound (scan failed)
  static Future<void> playErrorSound() async {
    try {
      // Using alert sound for errors
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      // Silently fail if sound can't be played
    }
  }

  // Play scanning sound (when starting to scan)
  static Future<void> playScanningSound() async {
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silently fail if sound can't be played
    }
  }
}