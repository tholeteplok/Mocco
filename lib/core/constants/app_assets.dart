/// Centralized Asset paths for Mocco
abstract final class AppAssets {
  // Base paths
  static const String _images = 'assets/images';
  static const String _objects = '$_images/objects';
  static const String _ui = '$_images/ui';
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

  // --- UI Assets ---
  static const String mapCanvasBg = '$_ui/map_canvas_loop.png';
  static const String mascotIdle = '$_ui/mascot_idle.png';
  static const String mascotJump = '$_ui/mascot_jump.png';
  static const String badgeStamp = '$_ui/badge_stamp.png';

  // --- SFX (Tactile Sound Effects) ---
  static const String sfxPopWood = '$_sfx/pop_wood.mp3';
  static const String sfxSquish = '$_sfx/squish.mp3';
  static const String sfxChimeSuccess = '$_sfx/chime_success.mp3';
  static const String sfxSoftRetry = '$_sfx/soft_retry.mp3';

  // --- Voice Over Helpers ---
  static String numberVoice(int number) => '$_voice/num_$number.mp3';
  static String letterNameVoice(String letter) => '$_voice/letter_name_${letter.toLowerCase()}.mp3';
  static String letterPhonicVoice(String letter) => '$_voice/letter_phonic_${letter.toLowerCase()}.mp3';
  static String wordVoice(String word) => '$_voice/${word.toLowerCase()}.mp3';
  static String syllableVoice(String syllable) => '$_voice/syl_${syllable.toLowerCase()}.mp3';

  // --- Praise & Prompt Voices ---
  static const String voiceHebat = '$_voice/hebat.mp3';
  static const String voicePintar = '$_voice/pintar.mp3';
  static const String voiceBagus = '$_voice/bagus.mp3';
  static const String voiceCobaLagi = '$_voice/coba_lagi.mp3';
  static const String voiceHitung = '$_voice/hitung.mp3';
}
