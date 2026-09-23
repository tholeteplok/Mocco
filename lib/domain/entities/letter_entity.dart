import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';

/// Entity representing an Indonesian Alphabet Letter with its name and phonic pronunciation
@immutable
class LetterEntity {
  const LetterEntity({
    required this.char,
    required this.lowercaseChar,
    required this.name,
    required this.phonic,
    this.exampleWord = '',
    this.imageAsset,
    this.emoji = '',
  });

  /// Uppercase character (e.g. 'A')
  final String char;

  /// Lowercase character (e.g. 'a')
  final String lowercaseChar;

  /// Indonesian Letter name (e.g. 'A', 'Be', 'Ce', 'De')
  final String name;

  /// Phonic sound description (e.g. '/a/', '/buh/', '/kuh/')
  final String phonic;

  /// Example word in Indonesian (e.g. 'Apel', 'Buku')
  final String exampleWord;

  /// 3D Clay transparent object asset path (e.g. AppAssets.fruitApple)
  final String? imageAsset;

  /// Child-friendly emoji representation (e.g. 🍎, 🥦, 🍒)
  final String emoji;

  /// Full display string: e.g. "Aa"
  String get pairDisplay => '$char$lowercaseChar';

  /// Representative child-friendly icon for the example word
  IconData get icon {
    switch (char.toUpperCase()) {
      case 'A': return Icons.apple_rounded;
      case 'B': return Icons.menu_book_rounded;
      case 'C': return Icons.spa_rounded;
      case 'D': return Icons.casino_rounded;
      case 'E': return Icons.pets_rounded;
      case 'F': return Icons.camera_alt_rounded;
      case 'G': return Icons.cruelty_free_rounded;
      case 'H': return Icons.pets_rounded;
      case 'I': return Icons.set_meal_rounded;
      case 'J': return Icons.lunch_dining_rounded;
      case 'K': return Icons.pets_rounded;
      case 'L': return Icons.local_florist_rounded;
      case 'M': return Icons.park_rounded;
      case 'N': return Icons.grass_rounded;
      case 'O': return Icons.wb_sunny_rounded;
      case 'P': return Icons.eco_rounded;
      case 'R': return Icons.bakery_dining_rounded;
      case 'S': return Icons.icecream_rounded;
      case 'T': return Icons.checkroom_rounded;
      default: return Icons.auto_stories_rounded;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LetterEntity &&
          runtimeType == other.runtimeType &&
          char == other.char &&
          lowercaseChar == other.lowercaseChar;

  @override
  int get hashCode => char.hashCode ^ lowercaseChar.hashCode;

  /// Standard Indonesian Alphabet catalog (26 letters)
  static const List<LetterEntity> alphabet = [
    LetterEntity(char: 'A', lowercaseChar: 'a', name: 'A', phonic: '/a/', exampleWord: 'Apel', imageAsset: AppAssets.fruitApple, emoji: '🍎'),
    LetterEntity(char: 'B', lowercaseChar: 'b', name: 'Be', phonic: '/buh/', exampleWord: 'Brokoli', imageAsset: AppAssets.vegBroccoli, emoji: '🥦'),
    LetterEntity(char: 'C', lowercaseChar: 'c', name: 'Ce', phonic: '/ch/', exampleWord: 'Ceri', emoji: '🍒'),
    LetterEntity(char: 'D', lowercaseChar: 'd', name: 'De', phonic: '/duh/', exampleWord: 'Dadu', emoji: '🎲'),
    LetterEntity(char: 'E', lowercaseChar: 'e', name: 'E', phonic: '/eh/', exampleWord: 'Ekor', emoji: '🐾'),
    LetterEntity(char: 'F', lowercaseChar: 'f', name: 'Ef', phonic: '/fff/', exampleWord: 'Foto', emoji: '📷'),
    LetterEntity(char: 'G', lowercaseChar: 'g', name: 'Ge', phonic: '/guh/', exampleWord: 'Gajah', emoji: '🐘'),
    LetterEntity(char: 'H', lowercaseChar: 'h', name: 'Ha', phonic: '/hhh/', exampleWord: 'Harimau', emoji: '🐯'),
    LetterEntity(char: 'I', lowercaseChar: 'i', name: 'I', phonic: '/eee/', exampleWord: 'Ikan', emoji: '🐟'),
    LetterEntity(char: 'J', lowercaseChar: 'j', name: 'Je', phonic: '/juh/', exampleWord: 'Jeruk', imageAsset: AppAssets.fruitOrange, emoji: '🍊'),
    LetterEntity(char: 'K', lowercaseChar: 'k', name: 'Ka', phonic: '/kuh/', exampleWord: 'Kucing', emoji: '🐱'),
    LetterEntity(char: 'L', lowercaseChar: 'l', name: 'El', phonic: '/lll/', exampleWord: 'Lemon', emoji: '🍋'),
    LetterEntity(char: 'M', lowercaseChar: 'm', name: 'Em', phonic: '/mmm/', exampleWord: 'Mangga', emoji: '🥭'),
    LetterEntity(char: 'N', lowercaseChar: 'n', name: 'En', phonic: '/nnn/', exampleWord: 'Nanas', emoji: '🍍'),
    LetterEntity(char: 'O', lowercaseChar: 'o', name: 'O', phonic: '/oh/', exampleWord: 'Obor', emoji: '🔦'),
    LetterEntity(char: 'P', lowercaseChar: 'p', name: 'Pe', phonic: '/puh/', exampleWord: 'Pisang', imageAsset: AppAssets.fruitBanana, emoji: '🍌'),
    LetterEntity(char: 'Q', lowercaseChar: 'q', name: 'Ki', phonic: '/kuh/', exampleWord: 'Qari', emoji: '📖'),
    LetterEntity(char: 'R', lowercaseChar: 'r', name: 'Er', phonic: '/rrr/', exampleWord: 'Roti', emoji: '🍞'),
    LetterEntity(char: 'S', lowercaseChar: 's', name: 'Es', phonic: '/sss/', exampleWord: 'Semangka', imageAsset: AppAssets.fruitWatermelon, emoji: '🍉'),
    LetterEntity(char: 'T', lowercaseChar: 't', name: 'Te', phonic: '/tuh/', exampleWord: 'Tomat', imageAsset: AppAssets.vegTomato, emoji: '🍅'),
    LetterEntity(char: 'U', lowercaseChar: 'u', name: 'U', phonic: '/uuu/', exampleWord: 'Ulat', emoji: '🐛'),
    LetterEntity(char: 'V', lowercaseChar: 'v', name: 'Ve', phonic: '/vvv/', exampleWord: 'Vas', emoji: '🏺'),
    LetterEntity(char: 'W', lowercaseChar: 'w', name: 'We', phonic: '/wuh/', exampleWord: 'Wortel', imageAsset: AppAssets.vegCarrot, emoji: '🥕'),
    LetterEntity(char: 'X', lowercaseChar: 'x', name: 'Eks', phonic: '/ks/', exampleWord: 'Xilofon', emoji: '🎶'),
    LetterEntity(char: 'Y', lowercaseChar: 'y', name: 'Ye', phonic: '/yuh/', exampleWord: 'Yoyo', emoji: '🪀'),
    LetterEntity(char: 'Z', lowercaseChar: 'z', name: 'Zet', phonic: '/zzz/', exampleWord: 'Zebra', emoji: '🦓'),
  ];
}
