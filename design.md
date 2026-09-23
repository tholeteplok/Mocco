# Mocco Design System v2.0 — Airy Clay, Playful Diorama & Age-Appropriate Toddler UX

> **Bilingual Documentation / Dokumentasi Dwibahasa**  
> *Sistem Desain & Panduan Pengalaman Pengguna Berbasis Psikologi Perkembangan Balita (Usia 2–6 Tahun)*  
> *Design System & User Experience Guidelines Grounded in Pre-School Developmental Psychology (Ages 2–6)*

---

## 1. Executive Summary / Ringkasan Eksekutif

**ID**: Mocco Design System v2.0 adalah lompatan arsitektur antarmuka dan interaksi yang dirancang khusus untuk anak usia pra-sekolah (tahap perkembangan pra-operasional Jean Piaget). Menggantikan paradigma aplikasi edukasi konvensional yang kerap memperlakukan anak seperti "orang dewasa mini" dengan formulir berkotak-kotak, Mocco v2.0 mentransformasikan setiap latihan menjadi **taman bermain diorama terbuka (*The Floating Playground*)**. Setiap interaksi berakar pada prinsip: **Alur Tanpa Pilihan (*Zero-Choice Linear Flow*)**, **Konten Bebas Bingkai Kartu (*Frameless Living Stage*)**, **Minimal Teks — Optimal Ikon & Audio (*Pre-Reader Native*)**, dan **Selebrasi Kemenangan Hidup (*3D Breakout Mascot*)**.

**EN**: Mocco Design System v2.0 is an interaction and visual architecture overhaul specifically engineered for pre-school children (Jean Piaget's pre-operational cognitive stage). Departing from conventional educational interfaces that treat toddlers as "mini adults" navigating dense worksheets and bureaucratic boxes, Mocco v2.0 reimagines every screen as an organic **Floating Playground**. Every interaction is governed by: **Zero-Choice Linear Flow**, **Frameless Living Stages**, **Pre-Reader Native Iconography & Audio**, and **3D Breakout Mascot Celebrations**.

---

## 2. The 5 Golden Pillars of Toddler UX / 5 Pilar Emas UX Anak

### 2.1 Pillar 1: Zero-Choice Linear Flow (Alur Tanpa Pilihan & Reduksi Beban Kognitif)
* **ID (Psikologi & Hukum Hick)**:
  * Anak pra-sekolah memiliki kapasitas memori kerja (*working memory*) yang sangat terbatas (1–2 unit informasi). Memberikan banyak cabang tombol (misal: tombol suara di setiap layar, tombol *Contoh* berdampingan dengan tombol *Hapus*, serta tombol *Bantu* teks) memicu **kelebihan beban kognitif (*cognitive overload*)** dan kelumpuhan keputusan (*decision paralysis*).
  * **Solusi Mocco v2.0**:
    1. **Satu Jalur Pasti**: Hanya ada satu aksi utama yang logis di setiap tahap.
    2. **Penyatuan Kontrol Tracing**: Tombol *Contoh* dan *Hapus* digabung menjadi satu tombol taktil tunggal `[ ▶ Contoh ]` yang otomatis mengosongkan kanvas dan memutar panduan pensil.
    3. **Tombol CTA Adaptif 3-Status**: Tombol bawah beradaptasi secara cerdas:
       - Status 1 (Belum Ditebalkan): `[ Tebalkan Dulu Ya ✏️ ]` (memutar suara panduan + animasi demo).
       - Status 2 (Ada Coretan Belum Sempurna): `[ Coba Lagi 🧽 ]` (dorongan bersahabat tanpa rasa bersalah).
       - Status 3 (Berhasil >= 70%): Modal selebrasi meluncur dengan tombol heroik lebar penuh `[ Lanjut Latihan ➜ ]`.
    4. **Pembersihan Sakelar Suara**: Tombol mute/unmute audio dihapus dari seluruh layar latihan dan dipusatkan secara eksklusif hanya di layar peta petualangan (`JourneyScreen`).
* **EN (Cognitive Psychology & Hick's Law)**:
  * Toddlers operate with limited cognitive working memory. Cluttering an educational interface with multiple choice buttons (e.g., redundant sound toggles on every screen, separate *Demo* and *Clear* buttons, or confusing helper toggles) induces **decision paralysis** and cognitive friction.
  * **Mocco v2.0 Solution**:
    1. **Single Clear Path**: Only one contextual primary action is presented at any given time.
    2. **Unified Tracing Control**: Combined *Demo* and *Erase* into a single tactile button `[ ▶ Contoh ]` that clears stray strokes and demonstrates animated pencil tracing.
    3. **3-State Adaptive CTA**: Dynamically shifts between prompt `[ Tebalkan Dulu Ya ✏️ ]`, encouragement `[ Coba Lagi 🧽 ]`, and celebration `[ Lanjut Latihan ➜ ]`.
    4. **Eliminated Screen Noise**: Audio toggles stripped from exercise headers, centralized strictly on the adventure map.

---

### 2.2 Pillar 2: Frameless Living Stage / Prinsip "Gajah Tanpa Kontainer"
* **ID (Prinsip Panggung Bebas Bingkai Kartu)**:
  * **Masalah v1.5**: Objek utama (huruf besar, angka, buah untuk berhitung) dikurung dalam kartu kotak putih persegi (`ChunkyCard`) dengan garis tepi tebal. Hal ini membatasi ukuran visual, memakan ruang layar, dan menyerupai lembar kerja sekolah (*school worksheet*).
  * **Standar v2.0**: Mengusung prinsip *"Gajah di Alam Bebas, Bukan di Dalam Kandang"*. Objek belajar utama ditampilkan di atas **`DioramaStage`** terbuka:
    - Tanpa kotak pembatas persegi yang kaku.
    - Dilengkapi *soft elliptical glow* transparan (40% warna kategori tema).
    - Memiliki bayangan lantai kontak 3D (*2.5D contact floor shadow*), memberi ilusi objek fisik melayang di atas pulau karpet bermain.
    - Konten objek dapat tampil **25%–40% lebih besar**, lebih taktil, dan langsung menjadi pusat fokus mata balita (*visual hierarchy anchor*).
* **EN (Frameless Living Stage Principle)**:
  * **The v1.5 Problem**: Main learning content was trapped inside rigid rectangular card boxes with heavy borders. This constrained visual scaling, wasted vertical space, and felt like a formal test worksheet.
  * **The v2.0 Standard**: Removing the container cage. The core learning subject rests directly atop an organic **`DioramaStage`**:
    - Zero rigid rectangular borders.
    - Soft elliptical ambient backdrop tinted with category theme colors.
    - Tactile 2.5D contact floor shadow grounding the item in space.
    - Subject assets scale **25%–40% larger**, boosting visual engagement and tactile immersion.

---

### 2.3 Pillar 3: Pre-Reader Native / Minimal Text — Optimal Icon & Audio
* **ID (Komunikasi Simbolik & Fonik)**:
  * Anak usia 2–6 tahun belum memiliki kemampuan membaca mandiri (*pre-readers / non-readers*). Paragraf teks panjang (misal: *"Pasangkan huruf besar A dengan huruf kecilnya!"* atau counter teks *"2 dari 3 terpasang"*) adalah *visual noise* yang diabaikan anak.
  * **Standar v2.0**:
    - **Instruksi Auditori Mandiri**: `AudioPromptButton` heroik berdenyut lembut (80dp) yang dapat ditekan anak kapan saja untuk mendengar pelafalan fonik asli Indonesia.
    - **Simbol Visual Taktil**: Mengganti teks tombol *"Bantu / Sembunyi"* dengan ikon keranjang belanja bulat `Icons.shopping_basket_rounded`.
    - **Indikator Progres Bintang Emas**: Mengganti counter teks angka dengan 3 bintang emas bertahap (`Icons.star_rounded` 32dp), memberikan visual reward instan yang langsung dipahami anak tanpa perlu membaca.
* **EN (Symbolic & Phonetic Native Experience)**:
  * Toddlers cannot read multi-sentence instructions. Text instructions like *"Match the uppercase letter with lowercase"* or numeric trackers like *"2 of 3 matched"* represent meaningless visual noise.
  * **The v2.0 Standard**:
    - **Auditory-First Delivery**: Pulsing 80dp `AudioPromptButton` lets pre-readers tap to hear native Indonesian phonics repeatedly on demand.
    - **Tactile Iconography**: Abstract text toggles replaced with self-explanatory icons (e.g. Shopping Basket icon for helper mode).
    - **Visual Gold Stars Progress**: Numeric counters replaced with tactile golden stars (`⭐⭐⭐`) that illuminate dynamically upon each successful match.

---

### 2.4 Pillar 4: 3D Breakout Mascot & Gamified Dopamine Loop
* **ID (Selebrasi Kemenangan yang Bermakna)**:
  * Menyelesaikan tracing atau soal adalah pencapaian besar (*achievement threshold*) bagi balita. Banner inline lama yang terjepit di bawah layar membuat maskot mini (54dp) dan memotong teks tombol menjadi `"Lanju..."`.
  * **Standar v2.0 (`CelebrationPopup`)**:
    - **Modal Bottom-Sheet Meluncur**: Latar belakang temaram lembut (*scrim 40%* `AppColors.modalOverlay`) memusatkan perhatian anak total pada momen kemenangan.
    - **3D Breakout Mascot (130dp)**: Maskot perayaan Mocco (`MascotMood.celebrate`) berdiri overlap menembus bibir atas kartu (separuh badan maskot keluar 65dp ke atas kartu), memberi kesan boneka maskot melompat hidup ke hadapan anak.
    - **Tombol Heroik Lebar Penuh (*Full-Width*)**: Tombol mint cerah (`#2EC4B6`) selebar penuh (tinggi 54dp, font 18sp) memberikan area ketukan (*hit-box*) masif yang mudah dijangkau jempol anak tanpa pemotongan teks (*Fitts's Law*).
* **EN (Meaningful Celebration & Gamification)**:
  * Completing a motor tracing path or quiz is a triumphant milestone. The old squeezed inline banner resulted in a shrunken 54dp avatar and truncated button copy (`"Lanju..."`).
  * **The v2.0 Standard (`CelebrationPopup`)**:
    - **Slide-Up Modal Bottom-Sheet**: Soft dimmed backdrop (*40% scrim*) isolates focus on the achievement.
    - **3D Breakout Mascot (130dp)**: The celebratory dinosaur mascot bursts out 65dp past the upper card boundary (`Stack(clipBehavior: Clip.none)`), giving the visual illusion of jumping out of the screen.
    - **Full-Width Heroic Button**: Wide 54dp-tall mint action button ensures zero label truncation, providing an effortless, satisfying tap target for small hands (*Fitts's Law*).

---

### 2.5 Pillar 5: Tactile 2.5D Clay Geometry & Color Science
* **ID (Palet Tenang-Ceria & Material Clay)**:
  * **Kanvas Krem Susu Hangat (`#FAF8F5`)**: Menggantikan latar putih silau dengan krem hangat yang menenangkan saraf mata anak dan memenuhi standar kontras WCAG AAA.
  * **Sentuhan 2.5D Clay**: Seluruh tombol interaktif memiliki lapisan bevel solid bawah (3–6dp) yang memberikan sensasi mainan fisik yang bisa ditekan (*tactile squish*).
* **EN (Calm-Vibrant Harmonization & Clay Toy Depth)**:
  * **Warm Milk Canvas (`#FAF8F5`)**: Soft, eye-friendly cream background replaces harsh blinding white, achieving AAA WCAG readability.
  * **2.5D Tactile Bevel**: Every interactive button and tile features solid offset depth (3–6dp), mimicking rubbery physical clay buttons.

---

## 3. Component Architecture & Geometry / Arsitektur Komponen

```
                  Breakout Mascot (130dp)
                     ╭─────────────╮
                     │   (●'◡'●)   │  <- Overlap: 65dp above card border
             ┌───────┴─────────────┴───────┐
             │       Luar Biasa! ⭐        │  <- Title: 24sp #13695F
             │  Huruf Gg berhasil          │  <- Subtitle: 16sp #267D73
             │  ditebalkan!                │
             │                             │
             │ [    Lanjut Latihan ➜     ] │  <- Full-width ChunkyButton: 54dp
             └─────────────────────────────┘
```

### 3.1 `DioramaStage` (`lib/presentation/widgets/stage/diorama_stage.dart`)
* **Purpose**: Centralized open stage for core learning items (letters, numbers, 3D fruits).
* **Backdrop**: Soft elliptical container with 40% category tint (`AppColors.letterPrimary`, `AppColors.numberPrimary`, `AppColors.blendingPrimary`).
* **Floor Shadow**: 2.5D contact shadow oval (`width: 110–260dp`, `height: 10–16dp`, color: `stageColor` with 25% opacity).
* **Zero Container**: No rectangular cardboard frames surrounding the main subject.

### 3.2 `CelebrationPopup` (`lib/presentation/widgets/feedback/celebration_popup.dart`)
* **Modal Trigger**: `CelebrationPopup.show(context: context, title: ..., subtitle: ..., buttonText: ..., onNextPressed: ...)`
* **Mascot Size**: 130.0 dp (`MascotMood.celebrate`).
* **Overlap Top Offset**: `65.0 dp` above card rim via `Stack(clipBehavior: Clip.none)`.
* **Card Surface**: Pure white, 32.0 dp radius pill, mint clay outline 3.0 dp (`#B2EAE3`), floor bevel 6.0 dp (`#D0F0EB`).
* **CTA Button**: Full-width `ChunkyButton` (54.0 dp height, 18.0 sp font).

### 3.3 `GuidedTracingCanvas` (`lib/presentation/widgets/tracing/guided_tracing_canvas.dart`)
* **Tracing Grid**: 290.0 dp canvas dengan kalibrasi presisi motorik halus (`TracingCalibration`).
* **Tolerance Radius**: 15.0 dp (koridor 30dp pas dengan ketebalan kuas visual 16dp; menolak sentuhan melenceng di luar garis).
* **Completion Threshold**: 78% per-stroke, 80% total progres untuk selebrasi tuntas.
* **Sequential Stroke Guard**: Stroke $s$ baru aktif setelah stroke sebelumnya $s-1$ mencapai progres minimal 60% (eliminasi coretan acak/gosok layar).
* **Unified Control**: `[ ▶ Contoh ]` aksi tunggal (reset progres + jalankan animasi pensil percontohan).
* **3-State Dynamic Banner**: Otomatis mendeteksi status `hasUserStrokes` dari instruksi awal, dorongan coba lagi, hingga selebrasi.

### 3.4 `AudioPromptButton` (`lib/presentation/widgets/buttons/audio_prompt_button.dart`)
* **Hero Size**: 72.0–80.0 dp circular bubble speaker.
* **Proportional Scaling**: Inner volume icon auto-scales at `55%` of outer button size.
* **Haptic Sound Feedback**: Triggers native voice prompt via `SoundPlayer.instance`.

---

## 4. Design Tokens Matrix / Matriks Token Desain

### 4.1 Color Tokens (`AppColors`)
| Token | Hex | Role / Peran |
| :--- | :--- | :--- |
| `canvasBackground` | `#FAF8F5` | Warm Milk Cream Canvas (Latar belakang utama tenang) |
| `cardSurface` | `#FFFFFF` | Luminous White Porcelain (Permukaan kartu modal & kontrol) |
| `cardBorder` | `#F0EAE1` | Soft Clay Outline (Garis batas kartu halus) |
| `cardBevel` | `#E8E0D5` | 2.5D Tactile Shadow (Bayangan lantai kartu) |
| `brandMint` | `#2EC4B6` | Luminous Mint (Warna kemenangan, tombol lanjut, highlight) |
| `brandMintDark` | `#25A296` | Mint Bevel (Bayangan tombol kemenangan) |
| `numberPrimary` | `#FF9F1C` | Honeycomb Orange (Aksen kategori angka & berhitung) |
| `letterPrimary` | `#4EA8DE` | Sky Blue (Aksen kategori pengenalan huruf) |
| `blendingPrimary` | `#7BC47F` | Leaf Green (Aksen kategori penggabungan kata) |
| `retryBackground` | `#FFF3D6` | Soft Amber Wash (Latar tombol coba lagi anti-frustrasi) |
| `retryBevel` | `#F5C542` | Amber Bevel (Bayangan tombol coba lagi) |
| `modalOverlay` | `#66000000` | 40% Scrim Dim (Latar temaram modal selebrasi) |
| `textPrimary` | `#2B2D42` | Warm Charcoal (Teks kontras tinggi ramah mata anak) |
| `textSecondary` | `#495057` | Dark Neutral (Teks instruksi sekunder WCAG AAA) |

### 4.2 Spacing & Dimension Tokens (`AppSpacing`)
| Token | Value | Role / Peran |
| :--- | :--- | :--- |
| `space8` | `8.0 dp` | Jarak mikro antar elemen teks |
| `space12` | `12.0 dp` | Jarak vertikal panggung diorama |
| `space16` | `16.0 dp` | Padding standar horizontal kontainer |
| `space20` | `20.0 dp` | Jarak antar grup tombol aksi |
| `space24` | `24.0 dp` | Margin pemisah antar seksi belajar |
| `minTouchTarget` | `64.0 dp` | Ukuran sentuh minimum motorik balita |
| `radiusCard` | `24.0 dp` | Kelengkungan sudut kartu besar |
| `radiusPill` | `32.0 dp` | Kelengkungan kapsul tombol heroik & modal |
| `bevelThick` | `6.0 dp` | Ketebalan bevel 3D clay solid |

### 4.3 Typography Tokens (`AppTypography`)
| Token / Method | Font Family | Size Range | Role / Peran |
| :--- | :--- | :--- | :--- |
| `brandTitle` | `Momentz` | `48–54 sp` | Brand Display Logo / Teks Merek Mocco (Bubbly claymorphic) |
| `learningDisplay` | `Andika` | `120–200 sp` | Tracing & Glyphs (Anatomi huruf/angka fonik ramah anak) |
| `uiHeading` | `Nunito` | `24–32 sp` | Header layar dan judul modal selebrasi |
| `uiButton` | `Nunito` | `18–24 sp` | Teks tombol aksi sentral (`ChunkyButton`) |
| `uiBody` | `Nunito` | `14–18 sp` | Label sekunder dan teks petunjuk |

---

## 5. Do's and Don'ts / Panduan Praktik Terbaik & Anti-Pola

| Area | DO (Dianjurkan) ✅ | DON'T (Dilarang) ❌ |
| :--- | :--- | :--- |
| **Kontrol Aksi** | Gunakan 1 alur aksi pasti (`[ ▶ Contoh ]`, `[ Lanjut ]`). | Jangan beri anak pra-sekolah banyak tombol pilihan bercabang. |
| **Konten Utama** | Taruh objek di panggung terbuka `DioramaStage` dengan bayangan 2.5D. | Jangan kurung objek belajar di dalam kartu kotak persegi kaku. |
| **Instruksi** | Gunakan `AudioPromptButton` bersuara ramah dan ikon simbolik. | Jangan gunakan teks instruksi panjang dan berbelit-belit. |
| **Selebrasi** | Gunakan modal popup meluncur dengan maskot 130dp overlap. | Jangan pasang banner selebrasi tipis yang menjepit tombol jadi `"Lanju..."`. |
| **Tombol Tindakan**| Berikan tombol aksi selebar penuh (*full-width*, tinggi min 52dp). | Jangan gunakan tombol kecil berjejer horizontal yang sempit bagi balita. |
| **Tracing Feedback**| Bedakan status kosong (*Tebalkan Dulu*), coretan (*Coba Lagi*), & selesai (*Lanjut*). | Jangan tampilkan pesan error agresif berlatar merah yang membuat anak cemas. |
