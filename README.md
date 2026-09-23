# Mocco — Early Literacy & Numeracy Adventure (v2.0)

> **Bilingual Overview / Gambaran Umum Dwibahasa**  
> *Aplikasi Pembelajaran Mandiri untuk Balita & Anak Usia Pra-Sekolah (Membaca Fonik & Pra-Matematika)*  
> *Self-Paced Learning Adventure for Toddlers & Pre-Schoolers (Phonics Reading & Pre-Math Foundations)*

---

## 1. Overview / Tentang Mocco

**ID**: Mocco adalah platform edukasi interaktif untuk anak usia 2–6 tahun (PAUD/TK) yang menggabungkan pendekatan Montessori dengan estetika visual modern **Airy Clay & Playful Diorama**. Dirancang khusus sesuai psikologi perkembangan kognitif balita, Mocco menghadirkan pengalaman belajar yang menenangkan, bebas frustrasi, dan sepenuhnya mandiri tanpa perlu didampingi orang tua secara terus-menerus.

**EN**: Mocco is an interactive early-childhood learning app for ages 2–6, harmonizing Montessori self-directed principles with a modern **Airy Clay & Playful Diorama** design language. Engineered around developmental psychology, Mocco delivers a calm, sensory-friendly, and frustration-free environment that empowers toddlers to learn letters, numbers, and words independently.

---

## 2. Core UX Innovations v2.0 / Inovasi Utama Desain v2.0

| Inovasi / Innovation | Deskripsi Bahasa Indonesia | English Description |
| :--- | :--- | :--- |
| **Zero-Choice Linear Flow** | **Alur Tanpa Pilihan**: Meniadakan cabang tombol yang membingungkan balita (*Hick's Law*). Kontrol disederhanakan menjadi 1 jalur pasti (tombol *Contoh* terpadu & tombol audio terpusat di peta). | Eliminates decision paralysis by removing branching button choices. Every exercise presents a single, unmistakable action path. |
| **Frameless Diorama Stage** | **Panggung Bebas Kartu**: Menghilangkan kartu kotak persegi kaku. Objek utama (huruf, angka, buah 3D) berdiri bebas di atas panggung pulau organik (`DioramaStage`) berbayangan lantai 2.5D, tampil 30% lebih besar. | Replaces restrictive rectangular card containers with open, organic diorama stages with 2.5D floor contact shadows, enlarging visual assets by 30%. |
| **Pre-Reader Native** | **Minimal Teks & Audio Fonik**: Tidak mengandalkan kemampuan membaca teks. Menggunakan instruksi suara ramah (`AudioPromptButton`), simbol taktil (ikon keranjang 🧺), dan bintang emas progres (`⭐⭐⭐`). | 100% pre-reader friendly. Replaces dense instructional copy with native Indonesian auditory cues, tactile icons, and golden star progress meters. |
| **3D Breakout Mascot** | **Selebrasi Maskot Dominan**: Modal popup meluncur dari bawah dengan maskot dinosaurus Mocco 130dp yang overlap memotong batas atas kartu, dilengkapi tombol aksi lebar penuh (*full-width*) tanpa teks terpotong. | Slide-up modal sheet featuring a dominant 130dp celebratory mascot overflowing the card rim, paired with full-width action buttons that never truncate. |

---

## 3. Learning Modules / Modul Pembelajaran

1. **Pengenalan & Tracing Huruf (*Letter Recognition & Tracing*)**:
   - Tracing cerdas dengan garis putus-putus mengalir (*flowing dashes*) dan deteksi sapuan kuas 70%.
   - Latihan memasangkan huruf besar & huruf kecil (*Uppercase to Lowercase Matching*).
   - Kuis diskriminasi visual & fonik suara asli Indonesia.
2. **Berhitung & Tracing Angka (*Counting & Number Tracing*)**:
   - Tracing angka 0–10 multi-stroke presisi (termasuk angka 4, 9, dan 10 dua-stroke terpisah).
   - Diorama berhitung buah 3D clay dengan susunan subitizing intuitif.
   - Mode bantuan keranjang belanja interaktif (*Single-Task Principle*).
3. **Penggabungan Suku Kata (*Syllable Blending & Word Assembly*)**:
   - Penggabungan kata pola Konsonan-Vokal (KV-KV) seperti *bu-ku*, *bo-la*, *sa-pi*.
   - Animasi magnetik slide & merge saat kedua suku kata berhasil dirangkai.
4. **Peta Petualangan Berkelanjutan (*Looping Adventure Map*)**:
   - Peta jalur bergelombang dengan ubin latar bertema dinamis.
   - Maskot penjelajah Mocco 130dp bertengger gagah di atas node aktif dengan *hit-box* sentuh terpadu.

---

## 4. Tech Stack & Architecture / Arsitektur Teknis

* **Framework**: Flutter 3.x (Multiplatform: Android, iOS, Tablet)
* **State Management**: Flutter Riverpod 3.x
* **Custom Graphics & Tracing**: Flutter `CustomPainter` dengan algoritma kalkulasi *Point Proximity & Stroke Progress Tracking*
* **Sound System**: Procedural synthetic sound generator & Native Indonesian voice audio clips (`SoundPlayer`)
* **Design System**: Fully centralized design tokens (`AppColors`, `AppSpacing`, `AppTypography`, `ResponsiveHelper`)
* **Testing**: Comprehensive Widget & Unit Test Suite (35+ automated tests)

```
lib/
├── core/
│   ├── constants/       # Asset paths & voice manifest
│   ├── tokens/          # Centralized Design Tokens (AppColors, AppSpacing, AppTypography)
│   └── utils/           # SoundPlayer, ResponsiveHelper
├── domain/
│   ├── entities/        # LetterEntity, WordEntity, CountingQuestion
│   └── services/        # NumberStrokes, WordCatalog, DistractorGenerators
└── presentation/
    ├── screens/         # Map, Letter, Counting, Blending, Splash, Parent
    └── widgets/
        ├── stage/       # DioramaStage (Frameless Living Stage)
        ├── feedback/    # CelebrationPopup (Breakout Mascot Modal)
        ├── tracing/     # GuidedTracingCanvas (Adaptive 3-State Tracing)
        ├── mascot/      # MascotWidget (Mood & Animated Clay Mascot)
        └── buttons/     # ChunkyButton, BubbleIconButton, AudioPromptButton
```

---

## 5. Development & Verification / Pengujian & Verifikasi

### Prerequisites
* Flutter SDK (3.24.0 or higher)
* Dart SDK (3.5.0 or higher)

### Run Automated Tests
```bash
# Menjalankan seluruh 35+ automated unit & widget tests
flutter test
```

### Static Analysis
```bash
# Memverifikasi standar kualitas kode Mocco (0 warnings / 0 errors target)
flutter analyze
```

### Run Application
```bash
# Menjalankan aplikasi pada emulator atau perangkat fisik
flutter run
```

---

## 6. Design System Guide / Panduan Sistem Desain

Dokumentasi lengkap mengenai filosofi psikologi balita, panduan geometri komponen, dan token desain Mocco v2.0 dapat diakses di:
* **[design.md](design.md)** — Buku Panduan Sistem Desain Mocco v2.0 (*Airy Clay & Playful Diorama*)
* **[docs/mocco-design-system-v2-0.md](docs/mocco-design-system-v2-0.md)** — Spesifikasi Teknis Internal

---

## 7. License
Mocco is developed under proprietary educational license. All rights reserved.
