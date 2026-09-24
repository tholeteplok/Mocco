import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_assets.dart';

/// Centralized Sound & Audio Service for Mocco (V7, V8, V14, V31, V34)
/// Supports 4 dedicated audio channels: SFX, Fast SFX, Voice (with BGM ducking), and BGM Loop.
class SoundPlayer {
  SoundPlayer._() {
    _initAudioContext();
  }
  static final SoundPlayer instance = SoundPlayer._();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _sfxFastPlayer = AudioPlayer();
  final AudioPlayer _celebrationPlayer = AudioPlayer();
  final AudioPlayer _voicePlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();

  bool _isMuted = false;
  bool get isMuted => _isMuted;
  bool _isBgmActive = false;
  bool get isBgmActive => _isBgmActive;

  void _initAudioContext() {
    try {
      AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
        ),
      );
      // Fail-safe auto-loop listener jika native platform menyelesaikan playback
      _bgmPlayer.onPlayerComplete.listen((_) {
        if (!_isMuted && _isBgmActive) {
          playBgmMap();
        }
      });
      // Pulihkan volume BGM setelah voice instruction/praise selesai berbicara
      _voicePlayer.onPlayerComplete.listen((_) {
        duckBgm(false);
      });
    } catch (e) {
      debugPrint('Error configuring global audio context: $e');
    }
  }

  Future<void> init({bool muted = false}) async {
    _isMuted = muted;
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(0.3);
    } catch (e) {
      debugPrint('BGM init configuration error: $e');
    }
    try {
      await _sfxPlayer.setSource(AssetSource(AppAssets.sfxPopWood.replaceFirst('assets/', '')));
      await _voicePlayer.setSource(AssetSource(AppAssets.voiceHebat.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('Audio preload fallback: $e');
    }
  }

  void toggleMute() {
    setMuted(!_isMuted);
  }

  void setMuted(bool muted) {
    _isMuted = muted;
    if (_isMuted) {
      _sfxPlayer.stop();
      _sfxFastPlayer.stop();
      _celebrationPlayer.stop();
      _voicePlayer.stop();
      _bgmPlayer.pause();
    } else {
      if (_isBgmActive) {
        _bgmPlayer.resume().catchError((_) => playBgmMap());
      }
    }
  }

  Future<void> _playSfx(String path, {bool fast = false}) async {
    if (_isMuted) return;
    try {
      final player = fast ? _sfxFastPlayer : _sfxPlayer;
      await player.stop();
      await player.play(AssetSource(path.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('SFX play error for $path: $e');
    }
  }

  /// Plays tactile pop sound for button clicks (V8)
  Future<void> playPop() => _playSfx(AppAssets.sfxPopWood, fast: true);

  /// Plays squish sound when dragging an object (V16)
  Future<void> playSquish() => _playSfx(AppAssets.sfxSquish, fast: true);

  /// Plays success celebration chime (V14)
  /// Menggunakan dedicated _celebrationPlayer agar tidak pernah terpotong SFX tombol
  Future<void> playSuccess() async {
    if (_isMuted) return;
    try {
      await _celebrationPlayer.stop();
      await _celebrationPlayer.play(AssetSource(AppAssets.sfxChimeSuccess.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('Celebration chime play error: $e');
    }
  }

  /// Plays soft gentle retry sound (V0.4, no harsh buzzer)
  Future<void> playSoftRetry() => _playSfx(AppAssets.sfxSoftRetry);

  /// Plays star unlock ding
  Future<void> playStarUnlock() => _playSfx(AppAssets.sfxStarUnlock);

  /// Plays soft card flip
  Future<void> playCardFlip() => _playSfx(AppAssets.sfxCardFlip, fast: true);

  /// Plays popup whoosh
  Future<void> playPopupWhoosh() => _playSfx(AppAssets.sfxPopupWhoosh);

  /// Plays tactile mute click
  Future<void> playMuteClick() => _playSfx(AppAssets.sfxMuteClick, fast: true);

  /// BGM Controls (Map/Home Only, Loop, Volume 0.3)
  Future<void> playBgmMap() async {
    _isBgmActive = true;
    if (_isMuted) return;
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(0.3);
      await _bgmPlayer.stop();
      await _bgmPlayer.play(AssetSource(AppAssets.bgmMapHome.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('BGM play error: $e');
    }
  }

  Future<void> stopBgm() async {
    _isBgmActive = false;
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('BGM stop error: $e');
    }
  }

  Future<void> duckBgm(bool duck) async {
    try {
      await _bgmPlayer.setVolume(duck ? 0.12 : 0.3);
    } catch (e) {
      debugPrint('BGM duck error: $e');
    }
  }

  /// Plays voice instruction or pronunciation with auto BGM-ducking
  Future<void> playVoice(String assetPath) async {
    if (_isMuted) return;
    try {
      await duckBgm(true);
      await _voicePlayer.stop();
      await _voicePlayer.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('Voice play error for $assetPath (mock asset fallback): $e');
      await duckBgm(false);
    }
  }

  /// Synthesizes or plays word / syllable pronunciation
  Future<void> playTts(String text) async {
    if (_isMuted) return;
    debugPrint('SoundPlayer playing word/syllable pronunciation: $text');
    await playVoice('assets/audio/voice/$text.mp3');
  }

  /// Speaks the pronounced number in Indonesian (e.g. 1 -> "Satu")
  Future<void> playNumber(int number) async => playVoice(AppAssets.numberVoice(number));

  /// Speaks the name of a letter (e.g. 'A', 'B')
  Future<void> playLetterName(String letter) async => playVoice(AppAssets.letterNameVoice(letter));

  /// Speaks the phonic sound of a letter (e.g. /a/, /beh/)
  Future<void> playLetterPhonic(String letter) async => playVoice(AppAssets.letterPhonicVoice(letter));

  /// Speaks a complete word in Indonesian (e.g. "Buku")
  Future<void> playWord(String word) async => playVoice(AppAssets.wordVoice(word));

  /// Speaks a single syllable (e.g. "bu", "ku")
  Future<void> playSyllable(String syllable) async => playVoice(AppAssets.syllableVoice(syllable));

  /// Speaks the zone announcement (e.g. "huruf", "angka", "kata")
  Future<void> playZone(String zone) async => playVoice(AppAssets.zoneVoice(zone));

  /// Plays randomized positive praise voice ("Hebat!", "Pintar sekali!", "Bagus!")
  /// Hanya memilih dari berkas yang 100% ada di disk (eliminasi 50% kegagalan senyap)
  Future<void> playPraise() async {
    const praises = [
      AppAssets.voiceHebat,
      AppAssets.voicePintar,
      AppAssets.voiceBagus,
    ];
    final selected = (List<String>.from(praises)..shuffle()).first;
    await playVoice(selected);
  }

  /// Plays gentle anti-frustration encouragement ("Yuk, coba lagi!")
  Future<void> playEncouragement() async {
    const encouragements = [
      AppAssets.voiceCobaLagi,
    ];
    final selected = encouragements.first;
    await playVoice(selected);
  }

  /// Speaks counting prompt ("Ayo hitung buahnya!")
  Future<void> playPromptCount() async => playVoice(AppAssets.voiceHitung);

  /// Speaks tracing prompt ("Tebalkan dulu ya")
  Future<void> playPromptTebalkan() async => playVoice(AppAssets.voiceTebalkanDuluYa);

  /// Speaks island map prompt ("Pilih pulau main!")
  Future<void> playPromptPilihPulau() async => playVoice(AppAssets.voicePilihPulau);

  void dispose() {
    _sfxPlayer.dispose();
    _sfxFastPlayer.dispose();
    _celebrationPlayer.dispose();
    _voicePlayer.dispose();
    _bgmPlayer.dispose();
  }
}
