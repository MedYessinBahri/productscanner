# Sound Assets

This directory contains audio files for scan feedback.

## Required Sound Files

Place the following sound files in this directory:

### 1. success.mp3
**Purpose**: Played when scan is successful
**Recommended**: Short, pleasant "ding" or "chime" sound (0.5-1 second)
**Download Options**:
- [Free success sound 1](https://freesound.org/people/grunz/sounds/109662/) - Classic success beep
- [Mixkit success sounds](https://mixkit.co/free-sound-effects/success/) - Various success tones
- [Barcode scanner beep](https://orangefreesounds.com/barcode-scanner-beep-sound/) - Authentic scanner beep

### 2. error.mp3
**Purpose**: Played when scan fails or no results found
**Recommended**: Short "buzz" or low-pitched beep (0.5-1 second)
**Download Options**:
- [Error beep sounds](https://mixkit.co/free-sound-effects/beep/) - Various error beeps
- [Wrong answer sounds](https://elevenlabs.io/sound-effects/wrong-answer) - Error tones

### 3. scanning.mp3
**Purpose**: Played when starting to scan
**Recommended**: Quick "beep" or "click" sound (0.2-0.5 seconds)
**Download Options**:
- [Scanner beep](https://bigsoundbank.com/beep-of-a-cash-register-s1417.html) - Cash register beep
- [Short beeps](https://www.soundjay.com/beep-sounds-1.html) - Various beep sounds

## File Specifications

- **Format**: MP3 or WAV
- **Duration**: 0.2 - 1.5 seconds
- **Sample Rate**: 44.1 kHz or 48 kHz
- **Bit Depth**: 16 bit
- **Channels**: Mono or Stereo

## Quick Download Suggestions

For a professional scanner experience, I recommend:

1. **success.mp3**: Use a classic barcode scanner beep from [Orange Free Sounds](https://orangefreesounds.com/barcode-scanner-beep-sound/)
2. **error.mp3**: Use a low buzz/error tone from [Mixkit](https://mixkit.co/free-sound-effects/beep/)
3. **scanning.mp3**: Use a short click from [FreeSounds](https://freesound.org/)

## License Note

Make sure to check the license of any sound effect you download. Most free sound libraries offer:
- CC0 (Public Domain) - No attribution required
- CC BY - Attribution required
- CC BY-NC - Non-commercial use only

## After Downloading

1. Place the 3 sound files (success.mp3, error.mp3, scanning.mp3) in this directory
2. Make sure the filenames match exactly
3. Run `flutter pub get` if not already done
4. The app will automatically use these sounds for feedback