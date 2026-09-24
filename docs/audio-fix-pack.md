# Audio Fix Pack Mocco — BGM, SFX, Voice

Acuan: `docs/mocco-design-system-v2-0.md` §1.2, §1.3 + V24/V32 once-per-visit. Target: anak 2-6th, light, mobile/tablet.

## A. Naskah voice (id-ID, <3 detik, 1 talent hangat lambat)

| File | Teks | Status |
|---|---|---|
| `voice/praise_hebat.mp3` | Hebat! | Ada, pertahankan |
| `voice/praise_pintar.mp3` | Pintar sekali! | Ada, pertahankan |
| `voice/praise_bagus.mp3` | Bagus! | Ada, pertahankan |
| `voice/praise_keren.mp3` | Keren sekali! | Baru |
| `voice/praise_luar_biasa.mp3` | Luar biasa! | Baru |
| `voice/praise_kamu_bisa.mp3` | Kamu pasti bisa! | Baru |
| `voice/coba_lagi.mp3` | Yuk, coba lagi! | Ada, pertahankan |
| `voice/tidak_apa_apa.mp3` | Tidak apa-apa, coba lagi yuk! | Baru |
| `voice/hitung.mp3` | Ayo hitung buahnya! | Ada, pertahankan |
| `voice/tebalkan_dulu_ya.mp3` | Tebalkan dulu ya! | Ada, pertahankan |
| `voice/pilih_pulau.mp3` | Pilih pulau main! | Baru, map on-demand |
| `voice/zone_huruf.mp3` | Pulau Huruf! | Baru, samakan `journey_catalog.dart` |
| `voice/zone_angka.mp3` | Pulau Angka! | Baru |
| `voice/zone_kata.mp3` | Pulau Kata! | Baru |

Aturan: autoplay sekali per kunjungan tipe latihan. Selanjutnya hanya via `AudioPromptButton`.

## B. Spec SFX + BGM

| File | Karakter | Durasi |
|---|---|---|
| `sfx/pop_wood.mp3` | Pop kayu taktil | 0.08s, ada |
| `sfx/squish.mp3` | Squish drag | 0.15s, ada, throttle 80ms |
| `sfx/chime_success.mp3` | Chime menang | 0.6s, ada |
| `sfx/soft_retry.mp3` | Retry lembut, tanpa buzzer | 0.4s, ada |
| `sfx/star_unlock.mp3` | Ding cerah | 0.4s, baru |
| `sfx/card_flip.mp3` | Flip kertas lembut | 0.15s, baru |
| `sfx/popup_whoosh.mp3` | Whoosh naik | 0.3s, baru |
| `sfx/mute_click.mp3` | Klik | 0.08s, baru |
| `bgm/map_home_loop.mp3` | Ukulele + xylophone 80 BPM, seamless loop, -12dB di bawah voice | 60-90s, baru, hanya map/home |

BGM dilarang di latihan, rewards loop, splash, parent area, celebration popup.

## C. Gap aset vs katalog (wajib tutup dulu)

```
grep -rn "AppAssets\." lib/core/constants/app_assets.dart
ls assets/audio/sfx assets/audio/voice assets/audio/bgm
```

`assets/audio/` saat ini hanya `sfx/`, `voice/` berisi ~100 file + `.gitkeep`. Verifikasi tiap konstanta `AppAssets.sfx*, voice*, numberVoice, letter*, wordVoice, syllableVoice` ada file fisiknya. `playTts` yang merakit `voice/$text.mp3` tanpa whitelist adalah sumber sunyi misterius — tambah whitelist `word_catalog` + fallback eja fonem + log file hilang.

## D. Integrasi SoundPlayer

Ganti `lib/core/utils/sound_player.dart`. API lama tetap jalan.

```dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_assets.dart';

class SoundPlayer {
  SoundPlayer._() { _initAudioContext(); }
  static final SoundPlayer instance = SoundPlayer._();

  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _sfxFastPlayer = AudioPlayer();
  final AudioPlayer _voicePlayer = AudioPlayer();
  final AudioPlayer _bgmPlayer = AudioPlayer();

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  void _initAudioContext() {
    try {
      AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true, stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.assistanceSonification,
            audioFocus: AndroidAudioFocus.none,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {AVAudioSessionOptions.mixWithOthers},
          ),
        ),
      );
    } catch (e) { debugPrint('Error configuring global audio context: $e'); }
  }

  Future<void> init({bool muted = false}) async {
    _isMuted = muted;
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(0.3);
    try {
      await _sfxPlayer.setSource(AssetSource(AppAssets.sfxPopWood.replaceFirst('assets/', '')));
      await _voicePlayer.setSource(AssetSource(AppAssets.voiceHebat.replaceFirst('assets/', '')));
    } catch (e) { debugPrint('Audio preload failed: $e'); }
  }

  void toggleMute() => setMuted(!_isMuted);
  void setMuted(bool muted) {
    _isMuted = muted;
    if (_isMuted) {
      _sfxPlayer.stop(); _sfxFastPlayer.stop(); _voicePlayer.stop(); _bgmPlayer.pause();
    }
  }

  Future<void> _playSfx(String path, {bool fast = false}) async {
    if (_isMuted) return;
    try {
      final p = fast ? _sfxFastPlayer : _sfxPlayer;
      await p.stop();
      await p.play(AssetSource(path.replaceFirst('assets/', '')));
    } catch (e) { debugPrint('SFX error $path: $e'); }
  }

  Future<void> playPop() => _playSfx(AppAssets.sfxPopWood, fast: true);
  Future<void> playSquish() => _playSfx(AppAssets.sfxSquish, fast: true);
  Future<void> playSuccess() => _playSfx(AppAssets.sfxChimeSuccess);
  Future<void> playSoftRetry() => _playSfx(AppAssets.sfxSoftRetry);
  Future<void> playStarUnlock() => _playSfx('assets/audio/sfx/star_unlock.mp3');
  Future<void> playCardFlip() => _playSfx('assets/audio/sfx/card_flip.mp3', fast: true);
  Future<void> playPopupWhoosh() => _playSfx('assets/audio/sfx/popup_whoosh.mp3');
  Future<void> playMuteClick() => _playSfx('assets/audio/sfx/mute_click.mp3', fast: true);

  Future<void> playVoice(String assetPath) async {
    if (_isMuted) return;
    try {
      await duckBgm(true);
      await _voicePlayer.stop();
      await _voicePlayer.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (e) { debugPrint('Voice play error for $assetPath: $e'); }
    finally { await duckBgm(false); }
  }

  Future<void> playTts(String text) async {
    if (_isMuted) return;
    debugPrint('SoundPlayer missing TTS fallback: $text');
    await playVoice('assets/audio/voice/$text.mp3');
  }

  Future<void> playNumber(int n) => playVoice(AppAssets.numberVoice(n));
  Future<void> playLetterName(String l) => playVoice(AppAssets.letterNameVoice(l));
  Future<void> playLetterPhonic(String l) => playVoice(AppAssets.letterPhonicVoice(l));
  Future<void> playWord(String w) => playVoice(AppAssets.wordVoice(w));
  Future<void> playSyllable(String s) => playVoice(AppAssets.syllableVoice(s));

  Future<void> playPraise() async {
    final praises = [
      AppAssets.voiceHebat, AppAssets.voicePintar, AppAssets.voiceBagus,
      'assets/audio/voice/praise_keren.mp3',
      'assets/audio/voice/praise_luar_biasa.mp3',
      'assets/audio/voice/praise_kamu_bisa.mp3',
    ];
    await playVoice((praises..shuffle()).first);
  }

  Future<void> playEncouragement() => playVoice(AppAssets.voiceCobaLagi);
  Future<void> playPromptCount() => playVoice(AppAssets.voiceHitung);
  Future<void> playPromptTebalkan() => playVoice(AppAssets.voiceTebalkanDuluYa);
  Future<void> playZone(String zone) => playVoice('assets/audio/voice/zone_$zone.mp3');

  Future<void> playBgmMap() async {
    if (_isMuted) return;
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.play(AssetSource('audio/bgm/map_home_loop.mp3'));
    } catch (e) { debugPrint('BGM error: $e'); }
  }
  Future<void> stopBgm() => _bgmPlayer.stop();
  Future<void> duckBgm(bool duck) async => _bgmPlayer.setVolume(duck ? 0.12 : 0.3);

  void dispose() {
    _sfxPlayer.dispose(); _sfxFastPlayer.dispose();
    _voicePlayer.dispose(); _bgmPlayer.dispose();
  }
}
```

Tambah ke `AppAssets`: `sfxStarUnlock`, `sfxCardFlip`, `sfxPopupWhoosh`, `sfxMuteClick`, `bgmMapHome`. Daftarkan `assets/audio/bgm/` di `pubspec.yaml`. Panggil `await SoundPlayer.instance.init()` saat boot, `playBgmMap()` di map/home, `stopBgm()` saat masuk latihan. Simpan mute di Hive.

## E. Render TTS

Install sekali: `pip install edge-tts ffmpeg`

```powershell
edge-tts --voice id-ID-GadisNeural --text "Keren sekali!" --write-media assets/audio/voice/praise_keren.mp3
edge-tts --voice id-ID-GadisNeural --text "Luar biasa!" --write-media assets/audio/voice/praise_luar_biasa.mp3
edge-tts --voice id-ID-GadisNeural --text "Tidak apa-apa, coba lagi yuk!" --write-media assets/audio/voice/tidak_apa_apa.mp3
edge-tts --voice id-ID-GadisNeural --text "Pilih pulau main!" --write-media assets/audio/voice/pilih_pulau.mp3
edge-tts --voice id-ID-GadisNeural --text "Pulau Huruf!" --write-media assets/audio/voice/zone_huruf.mp3
ffmpeg -y -i assets/audio/voice/praise_keren.mp3 -filter:a loudnorm=I=-16:TP=-1.5:LRA=11 assets/audio/voice/praise_keren.mp3
```

Ulangi pola sama tabel A. Satu voice, kecepatan default.

## F. Validasi

```
flutter test test/presentation/screens/letter_flow_test.dart test/presentation/screens/counting_tracing_flow_test.dart
```

Cek tap cepat tidak memotong squish, mute persist restart, BGM berhenti masuk latihan, file hilang tercatat via log `playTts`.
