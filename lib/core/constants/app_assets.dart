/// Centralized Asset paths for Mocco
abstract final class AppAssets {
  // Base paths
  static const String _images = 'assets/images';
  static const String _objects = '$_images/objects';
  static const String _ui = '$_images/ui';
  static const String _mascot = '$_images/mascot';
  static const String _audio = 'assets/audio';
  static const String _sfx = '$_audio/sfx';
  static const String _voice = '$_audio/voice';

  // --- 10 Objek Buah & Sayur (1:1 Uniform Scale, 3D Clay Transparent PNG) ---
  static const String fruitApple = '$_objects/apple.png';
  static const String fruitOrange = '$_objects/orange.png';
  static const String fruitBanana = '$_objects/banana.png';
  static const String fruitStrawberry = '$_objects/strawberry.png';
  static const String fruitWatermelon = '$_objects/watermelon.png';
  static const String vegCarrot = '$_objects/carrot.png';
  static const String vegTomato = '$_objects/tomato.png';
  static const String vegCorn = '$_objects/corn.png';
  static const String vegEggplant = '$_objects/eggplant.png';
  static const String vegBroccoli = '$_objects/broccoli.png';

  static const List<String> countingObjects = [
    fruitApple,
    fruitOrange,
    fruitBanana,
    fruitStrawberry,
    fruitWatermelon,
    vegCarrot,
    vegTomato,
    vegCorn,
    vegEggplant,
    vegBroccoli,
  ];

  // --- 3D Claymorphism Assets (Pinterest Toy Aesthetic) ---
  static const String appleClay = fruitApple;
  static const String orangeClay = fruitOrange;
  static const String basketClay = '$_ui/basket_clay.jpg';

  // --- 3D Clay Mascot (Living Companion — Mocco) ---
  static const String mascotGreeting = '$_mascot/mascot_greeting.png';
  static const String mascotReading = '$_mascot/mascot_reading.png';
  static const String mascotCelebrate = '$_mascot/mascot_celebrate.png';
  static const String mascotLove = '$_mascot/mascot_love.png';
  static const String mascotThinking = '$_mascot/mascot_thinking.png';
  static const String mascotThumbsUp = '$_mascot/mascot_thumbs_up.png';
  static const String mascotCrawling = '$_mascot/mascot_crawling.png';
  static const String mascotSleeping = '$_mascot/mascot_sleeping.png';
  static const String mascotExploring = '$_mascot/mascot_exploring.png';

  // Backward-compatibility aliases
  static const String mascotIdle = mascotGreeting;
  static const String mascotJump = mascotCelebrate;

  // --- UI Assets ---
  static const String worldMapSingle = '$_ui/world_map_single.webp';
  static const String badgeStamp = '$_ui/badge_stamp.png';

  // --- 3D Clay Button Assets (Border-free Diorama Toys) ---
  static const String _buttons = '$_ui/buttons';
  static const String btnBack = '$_buttons/ic_button_back.png';
  static const String btnBackPressed = '$_buttons/ic_button_back_pressed.png';
  static const String btnNext = '$_buttons/ic_button_next.png';
  static const String btnNextPressed = '$_buttons/ic_button_next_pressed.png';
  static const String btnParents = '$_buttons/ic_button_parents.png';
  static const String btnParentsPressed = '$_buttons/ic_button_parents_pressed.png';
  static const String btnPlay = '$_buttons/ic_button_play.png';
  static const String btnPlayPressed = '$_buttons/ic_button_play_pressed.png';
  static const String btnSoundOn = '$_buttons/ic_button_soundON.png';
  static const String btnSoundOff = '$_buttons/ic_button_soundOFF.png';
  static const String btnVoice = '$_buttons/ic_button_voice.png';
  static const String btnVoicePressed = '$_buttons/ic_button_voice_pressed.png';
  static const String btnReplay = '$_buttons/ic_replay.png';
  static const String btnReplayPressed = '$_buttons/ic_replay_pressed.png';
  static const String icStar = '$_buttons/ic_star.png';

  // --- SFX (Tactile Sound Effects) ---
  static const String sfxPopWood = '$_sfx/pop_wood.mp3';
  static const String sfxSquish = '$_sfx/squish.mp3';
  static const String sfxChimeSuccess = '$_sfx/chime_success.mp3';
  static const String sfxSoftRetry = '$_sfx/soft_retry.mp3';
  static const String sfxStarUnlock = '$_sfx/star_unlock.mp3';
  static const String sfxCardFlip = '$_sfx/card_flip.mp3';
  static const String sfxPopupWhoosh = '$_sfx/popup_whoosh.mp3';
  static const String sfxMuteClick = '$_sfx/mute_click.mp3';

  // --- BGM (Background Music — Map/Home Loop Only) ---
  static const String _bgm = '$_audio/bgm';
  static const String bgmMapHome = '$_bgm/map_home_loop.mp3';

  // --- Voice Over Helpers ---
  static String numberVoice(int number) => '$_voice/num_$number.mp3';
  static String letterNameVoice(String letter) => '$_voice/letter_name_${letter.toLowerCase()}.mp3';
  static String letterPhonicVoice(String letter) => '$_voice/letter_phonic_${letter.toLowerCase()}.mp3';
  static String wordVoice(String word) => '$_voice/${word.toLowerCase()}.mp3';
  static String syllableVoice(String syllable) => '$_voice/syl_${syllable.toLowerCase()}.mp3';
  static String zoneVoice(String zone) => '$_voice/zone_${zone.toLowerCase()}.mp3';

  // --- Praise & Prompt Voices ---
  static const String voiceHebat = '$_voice/hebat.mp3';
  static const String voicePintar = '$_voice/pintar.mp3';
  static const String voiceBagus = '$_voice/bagus.mp3';
  static const String voicePraiseKeren = '$_voice/praise_keren.mp3';
  static const String voicePraiseLuarBiasa = '$_voice/praise_luar_biasa.mp3';
  static const String voicePraiseKamuBisa = '$_voice/praise_kamu_bisa.mp3';
  static const String voiceCobaLagi = '$_voice/coba_lagi.mp3';
  static const String voiceTidakApaApa = '$_voice/tidak_apa_apa.mp3';
  static const String voiceHitung = '$_voice/hitung.mp3';
  static const String voiceTebalkanDuluYa = '$_voice/tebalkan_dulu_ya.mp3';
  static const String voicePilihPulau = '$_voice/pilih_pulau.mp3';
}
