import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_assets.dart';

/// Centralized Sound & Audio Service for Mocco (V7, V8, V14, V31, V34)
class SoundPlayer {
  SoundPlayer._();
  static final SoundPlayer instance = SoundPlayer._();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _voicePlayer = AudioPlayer();

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _sfxPlayer.stop();
      _voicePlayer.stop();
    }
  }

  void setMuted(bool muted) {
    _isMuted = muted;
    if (_isMuted) {
      _sfxPlayer.stop();
      _voicePlayer.stop();
    }
  }

  /// Plays tactile pop sound for button clicks (V8)
  Future<void> playPop() async {
    if (_isMuted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(AppAssets.sfxPopWood.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('SFX playPop error (mock asset fallback): $e');
    }
  }

  /// Plays squish sound when dragging an object (V16)
  Future<void> playSquish() async {
    if (_isMuted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(AppAssets.sfxSquish.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('SFX playSquish error (mock asset fallback): $e');
    }
  }

  /// Plays success celebration chime (V14)
  Future<void> playSuccess() async {
    if (_isMuted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(AppAssets.sfxChimeSuccess.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('SFX playSuccess error (mock asset fallback): $e');
    }
  }

  /// Plays soft gentle retry sound (V0.4, no harsh buzzer)
  Future<void> playSoftRetry() async {
    if (_isMuted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(AppAssets.sfxSoftRetry.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('SFX playSoftRetry error (mock asset fallback): $e');
    }
  }

  /// Plays voice instruction or number/letter pronunciation (V31, V32)
  Future<void> playVoice(String assetPath) async {
    if (_isMuted) return;
    try {
      await _voicePlayer.stop();
      await _voicePlayer.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('Voice play error for $assetPath (mock asset fallback): $e');
    }
  }

  /// Synthesizes or plays word / syllable pronunciation
  Future<void> playTts(String text) async {
    if (_isMuted) return;
    debugPrint('SoundPlayer playing word/syllable pronunciation: $text');
    await playVoice('assets/audio/voice/$text.mp3');
  }

  /// Speaks the pronounced number in Indonesian (e.g. 1 -> "Satu")
  Future<void> playNumber(int number) async {
    await playVoice(AppAssets.numberVoice(number));
  }

  /// Speaks the name of a letter (e.g. 'A', 'B')
  Future<void> playLetterName(String letter) async {
    await playVoice(AppAssets.letterNameVoice(letter));
  }

  /// Speaks the phonic sound of a letter (e.g. /a/, /beh/)
  Future<void> playLetterPhonic(String letter) async {
    await playVoice(AppAssets.letterPhonicVoice(letter));
  }

  /// Speaks a complete word in Indonesian (e.g. "Buku")
  Future<void> playWord(String word) async {
    await playVoice(AppAssets.wordVoice(word));
  }

  /// Speaks a single syllable (e.g. "bu", "ku")
  Future<void> playSyllable(String syllable) async {
    await playVoice(AppAssets.syllableVoice(syllable));
  }

  /// Plays randomized positive praise voice ("Hebat!", "Pintar sekali!", "Bagus!")
  Future<void> playPraise() async {
    final praises = [AppAssets.voiceHebat, AppAssets.voicePintar, AppAssets.voiceBagus];
    final selected = (praises..shuffle()).first;
    await playVoice(selected);
  }

  /// Plays gentle anti-frustration encouragement ("Yuk, coba lagi!")
  Future<void> playEncouragement() async {
    await playVoice(AppAssets.voiceCobaLagi);
  }

  /// Speaks counting prompt ("Ayo hitung buahnya!")
  Future<void> playPromptCount() async {
    await playVoice(AppAssets.voiceHitung);
  }

  void dispose() {
    _sfxPlayer.dispose();
    _voicePlayer.dispose();
  }
}
