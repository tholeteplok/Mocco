import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import '../constants/app_assets.dart';

/// Centralized Sound & Audio Service for Mocco (V7, V8, V14, V31, V34)
/// Supports 4 dedicated audio channels: SFX, Fast SFX, Voice (with BGM ducking), and BGM Loop.
class SoundPlayer {
  SoundPlayer._() {
    _initAudioContext();
  }
  static final SoundPlayer instance = SoundPlayer._();

  static const String _muteKey = '__system_mute';
  static const String _boxName = 'mocco_mastery_box';

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _sfxFastPlayer = AudioPlayer();
  final AudioPlayer _celebrationPlayer = AudioPlayer();
  final AudioPlayer _voicePlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();

  DateTime? _lastSuccessPlayTime;

  bool _isMuted = false;
  bool get isMuted => _isMuted;
  bool _isBgmActive = false;
  bool get isBgmActive => _isBgmActive;

  static const double _bgmDefaultVolume = 0.80;
  static const double _bgmDuckedVolume = 0.25;

  bool _isBgmTransitioning = false;

  static final AudioContext _appAudioContext = AudioContext(
    android: const AudioContextAndroid(
      isSpeakerphoneOn: true,
      stayAwake: false,
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.game,
      audioFocus: AndroidAudioFocus.none,
    ),
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const {
        AVAudioSessionOptions.mixWithOthers,
      },
    ),
  );

  void _initAudioContext() {
    try {
      AudioPlayer.global.setAudioContext(_appAudioContext);
      // Auto-loop fail-safe: pulihkan pemutaran jika native platform mencapai akhir lagu
      _bgmPlayer.onPlayerComplete.listen((_) {
        if (!_isMuted && _isBgmActive) {
          _syncBgm();
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

  Future<void> _applyPerPlayerAudioContext() async {
    try {
      await _bgmPlayer.setAudioContext(_appAudioContext);
      await _celebrationPlayer.setAudioContext(_appAudioContext);
      await _voicePlayer.setAudioContext(_appAudioContext);
      await _sfxPlayer.setAudioContext(_appAudioContext);
      await _sfxFastPlayer.setAudioContext(_appAudioContext);
    } catch (e) {
      debugPrint('Error applying per-player audio context: $e');
    }
  }

  Future<void> init({bool muted = false}) async {
    _isMuted = muted;
    await _applyPerPlayerAudioContext();
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(_bgmDefaultVolume);
    } catch (e) {
      debugPrint('BGM init configuration error: $e');
    }
    try {
      await _sfxPlayer.setSource(AssetSource(AppAssets.sfxPopWood.replaceFirst('assets/', '')));
      await _voicePlayer.setSource(AssetSource(AppAssets.voiceHebat.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('Audio preload fallback: $e');
    }
    syncMuteFromStorage();
  }

  void toggleMute() {
    setMuted(!_isMuted);
  }

  void _persistMuteState(bool muted) {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        Hive.box(_boxName).put(_muteKey, muted);
      }
    } catch (_) {}
  }

  void syncMuteFromStorage() {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        final box = Hive.box(_boxName);
        final saved = box.get(_muteKey) as bool?;
        if (saved != null && saved != _isMuted) {
          setMuted(saved, persist: false);
        }
      }
    } catch (_) {}
  }

  void setMuted(bool muted, {bool persist = true}) {
    _isMuted = muted;
    if (persist) {
      _persistMuteState(muted);
    }
    if (_isMuted) {
      _sfxPlayer.stop();
      _sfxFastPlayer.stop();
      _celebrationPlayer.stop();
      _voicePlayer.stop();
    }
    _syncBgm();
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
    _lastSuccessPlayTime = DateTime.now();
    try {
      await _celebrationPlayer.stop();
      await _celebrationPlayer.play(AssetSource(AppAssets.sfxChimeSuccess.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('Celebration chime play error: $e');
    }
  }

  /// Memutar rangkaian selebrasi lengkap tersentralisasi:
  /// 1. Lonceng kemenangan (chime_success.mp3 - 1,23 detik)
  /// 2. Menunggu sampai nada lonceng selesai + jeda nafas natural 150 ms (~1,38 detik total)
  /// 3. Suara pujian maskot acak ("Hebat!", "Pintar sekali!", "Bagus!") dengan auto BGM-ducking
  Future<void> playCelebration({Duration gap = const Duration(milliseconds: 150)}) async {
    if (_isMuted) return;
    await playSuccess();
    await Future.delayed(const Duration(milliseconds: 1230) + gap);
    await playPraise();
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

  /// Plays welcoming intro jingle for Splash Screen
  Future<void> playIntro() => _playSfx(AppAssets.sfxIntro);

  /// Plays celebratory level up fanfare for LevelUpDialog
  Future<void> playLevelUp() async {
    if (_isMuted) return;
    _lastSuccessPlayTime = DateTime.now();
    try {
      await _celebrationPlayer.stop();
      await _celebrationPlayer.play(
        AssetSource(AppAssets.sfxLevelUp.replaceFirst('assets/', '')),
      );
    } catch (e) {
      debugPrint('Level up play error: $e');
    }
  }

  /// State Synchronization Mutex untuk BGM.
  /// Menjamin konvergensi state dan auto-recovery tanpa race condition saat
  /// tombol selesai/lanjut ditekan secara cepat.
  Future<void> _syncBgm() async {
    if (_isBgmTransitioning) return;
    _isBgmTransitioning = true;
    try {
      while (true) {
        final desiredPlay = _isBgmActive && !_isMuted;
        if (desiredPlay) {
          // Pulihkan volume BGM (memulihkan dari ducking yang tertahan)
          await _bgmPlayer.setVolume(_bgmDefaultVolume);
          if (_bgmPlayer.state != PlayerState.playing) {
            await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
            await _bgmPlayer.stop();
            await _bgmPlayer.play(
              AssetSource(AppAssets.bgmMapHome.replaceFirst('assets/', '')),
            );
          }
        } else {
          if (_bgmPlayer.state == PlayerState.playing) {
            await _bgmPlayer.stop();
          }
        }

        // Cek apakah ada perubahan status yang masuk saat operasi async di atas berlangsung
        final updatedDesired = _isBgmActive && !_isMuted;
        final isCurrentlyPlaying = _bgmPlayer.state == PlayerState.playing;
        if (updatedDesired == isCurrentlyPlaying) {
          break; // State telah konvergen sempurna
        }
      }
    } catch (e) {
      debugPrint('BGM sync error: $e');
    } finally {
      _isBgmTransitioning = false;
    }
  }

  /// BGM Controls (Map/Home Only, Loop, Volume 0.80)
  Future<void> playBgmMap() async {
    _isBgmActive = true;
    await _syncBgm();
  }

  Future<void> stopBgm() async {
    _isBgmActive = false;
    await _syncBgm();
  }

  Future<void> duckBgm(bool duck) async {
    try {
      await _bgmPlayer.setVolume(duck ? _bgmDuckedVolume : _bgmDefaultVolume);
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
  /// Otomatis menunggu dentang chime_success selesai jika baru saja diputar
  Future<void> playPraise() async {
    if (_isMuted) return;
    if (_lastSuccessPlayTime != null) {
      final elapsed = DateTime.now().difference(_lastSuccessPlayTime!);
      const requiredWait = Duration(milliseconds: 1380); // 1230ms chime + 150ms gap
      if (elapsed < requiredWait) {
        final remaining = requiredWait - elapsed;
        await Future.delayed(remaining);
      }
    }
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
