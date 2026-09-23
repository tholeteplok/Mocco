# Mocco Design System v2.0 — Airy Clay, Playful Diorama & Age-Appropriate Toddler UX

Sistem desain generasi kedua untuk Mocco, ditransformasikan secara menyeluruh mengadopsi standar industri terbaik dari kurasi modern (*Kids Education Mobile App UI — Duolingo ABC, Lingokids, Pok Pok Playroom*) yang disesuaikan secara saintifik dengan psikologi perkembangan kognitif balita (usia 2–6 tahun).

---

## 1. Filosofi Inti (The 5 Golden Pillars)

### 1.1 The Frameless Living Stage (Prinsip "Gajah Tanpa Kontainer")
* **Evolusi dari v1.5 ke v2.0**:
  * Pada v1.5, objek belajar masih dibungkus dalam kartu kotak persegi (`ChunkyCard`) dengan border tebal. Ini menciptakan efek "lembar kerja sekolah" (*school worksheet*) dan membatasi skala objek visual.
  * Pada v2.0, konten utama dibebaskan dari kurungan kartu kaku dan ditempatkan di atas **`DioramaStage`**:
    - Panggung terbuka berbentuk elips lembut dengan transparansi warna kategori (40%).
    - Dilengkapi bayangan lantai 2.5D solid (*contact floor shadow*) yang memberi ilusi objek 3D melayang di atas pulau karpet bermain.
    - Konten utama (huruf kapital, angka, ilustrasi buah) dapat tampil **25%–40% lebih besar**, lebih taktil, dan langsung menjadi jangkar fokus balita.

### 1.2 Alur Tanpa Pilihan (*Zero-Choice Linear Flow & Hick's Law*)
* Anak pra-sekolah memiliki kapasitas memori kerja (*working memory*) yang sangat terbatas. Banyaknya pilihan tombol memicu *decision paralysis* dan kebingungan.
* **Standar v2.0**:
  - **Satu Jalur Pasti**: Setiap latihan hanya memiliki satu alur aksi logis tanpa tombol sampingan yang redundan.
  - **Penyatuan Kontrol Tracing**: Tombol *Contoh* dan *Hapus* disatukan menjadi satu tombol cerdas `[ ▶ Contoh ]` yang otomatis membersihkan coretan dan memutar animasi panduan pensil.
  - **Tombol CTA 3-Status Adaptif**:
    - Kosong: `[ Tebalkan Dulu Ya ✏️ ]` (suara panduan ramah).
    - Belum Sempurna: `[ Coba Lagi 🧽 ]` (dorongan bersahabat anti-frustrasi).
    - Selesai (>= 70%): Modal selebrasi meluncur dengan tombol lebar penuh `[ Lanjut Latihan ➜ ]`.
  - **Pembersihan Sakelar Suara**: Tombol suara dihapus dari seluruh header latihan dan dipusatkan secara eksklusif hanya pada peta petualangan.

### 1.3 Pre-Reader Native (Minimal Teks — Optimal Ikon & Audio)
* Balita belum mampu membaca teks instruksi panjang. Teks instruksi berbelit-belit hanya menjadi distraksi (*visual noise*).
* **Standar v2.0**:
  - **Instruksi Auditori Mandiri**: `AudioPromptButton` heroik berukuran 72–80dp dengan ikon speaker proporsional dan animasi denyut lembut. Anak cukup menekan speaker untuk mendengar suara fonik alami Indonesia.
  - **Simbol Visual Intuitif**: Teks bantuan diganti dengan ikon keranjang belanja bulat `Icons.shopping_basket_rounded`.
  - **Progres Simbolik Bintang Emas**: Counter teks angka diganti dengan 3 bintang emas interaktif (`⭐⭐⭐` 32dp) yang menyala satu per satu setiap pasang huruf berhasil dicocokkan.

### 1.4 Selebrasi Maskot Dominan Overlap (*3D Breakout Mascot & Dopamine Loop*)
* Menyelesaikan latihan adalah momen kemenangan besar bagi balita. Banner inline tipis di bawah layar terbukti menjepit teks menjadi `"Lanju..."` dan mengecilkan maskot menjadi 54dp.
* **Standar v2.0 (`CelebrationPopup`)**:
  - **Slide-Up Modal Bottom-Sheet**: Muncul meluncur halus dengan latar temaram (*scrim overlay* 40% `AppColors.modalOverlay`), mengisolasi fokus anak pada rasa pencapaian.
  - **Maskot Dominan 130dp**: Maskot berdiri overlap memotong batas atas kartu (setengah tubuh maskot 65dp melompat keluar ke atas kartu via `Stack(clipBehavior: Clip.none)`).
  - **Tombol Lebar Penuh (*Full-Width*)**: Menggunakan `ChunkyButton` vertikal (lebar `double.infinity`, tinggi 54dp, font 18sp) yang menjamin teks *"Lanjut Latihan"* tampil utuh tanpa terpotong dan sangat mudah disentuh jempol balita (*Fitts's Law*).

### 1.5 Palet Warna Tenang-Ceria & Material Clay 2.5D
* **Kanvas Krem Susu Hangat (`#FAF8F5`)**: Menggantikan putih silau dengan krem yang menenangkan sistem syaraf mata anak dan memenuhi kepatuhan kontras WCAG AAA.
* **Material Clay Taktil**: Seluruh kontrol interaktif memiliki bevel solid 2.5D tebal (3–6dp) yang memberikan sensasi mainan karet fisik yang membal saat ditekan.

---

## 2. Token Desain Terpusat (Design Tokens)

### 2.1 Warna (AppColors)
| Token | Hex | Penggunaan |
| :--- | :--- | :--- |
| `canvasBackground` | `#FAF8F5` | Latar belakang seluruh layar (Krem Susu Tenang) |
| `cardSurface` | `#FFFFFF` | Permukaan kartu modal & tombol porselen |
| `cardBorder` | `#F0EAE1` | Garis tepi kartu minimalis (1.5dp) |
| `cardBevel` | `#E8E0D5` | Bevel kontak 2.5D solid lembut |
| `brandMint` | `#2EC4B6` | Warna kemenangan, tombol lanjut, highlight benar |
| `brandMintDark` | `#25A296` | Bevel tombol kemenangan mint |
| `numberPrimary` | `#FF9F1C` | Aksen kategori angka & berhitung (Oranye Ceria) |
| `letterPrimary` | `#4EA8DE` | Aksen kategori huruf & fonik (Biru Langit) |
| `blendingPrimary` | `#7BC47F` | Aksen kategori penggabungan kata (Hijau Daun) |
| `retryBackground` | `#FFF3D6` | Latar tombol coba lagi lembut anti-frustrasi |
| `retryBevel` | `#F5C542` | Bevel tombol coba lagi |
| `modalOverlay` | `#66000000` | 40% Scrim Dim (Latar temaram modal selebrasi) |
| `textPrimary` | `#2B2D42` | Teks utama kontras tinggi (Warm Charcoal) |
| `textSecondary` | `#495057` | Teks sekunder terbaca (Dark Neutral WCAG AAA) |

### 2.2 Dimensi & Radius (AppSpacing)
| Token | Nilai | Penggunaan |
| :--- | :--- | :--- |
| `space8` | `8.0 dp` | Jarak mikro antar teks |
| `space12` | `12.0 dp` | Jarak panggung diorama |
| `space16` | `16.0 dp` | Padding standar horizontal kontainer |
| `space20` | `20.0 dp` | Jarak pemisah grup aksi |
| `space24` | `24.0 dp` | Margin antar komponen layar |
| `minTouchTarget` | `64.0 dp` | Target sentuh minimum motorik balita |
| `radiusCard` | `24.0 dp` | Sudut kelengkungan kartu besar |
| `radiusPill` | `32.0 dp` | Sudut kelengkungan tombol heroik & modal |
| `bevelThick` | `6.0 dp` | Ketebalan bevel 3D clay solid |

---

## 3. Spesifikasi Komponen Terpusat

### 3.1 DioramaStage (`lib/presentation/widgets/stage/diorama_stage.dart`)
* Menggantikan kotak persegi pada konten utama latihan.
* Backdrop elips transparan (opacity 0.40) dengan bayangan lantai 2.5D (`110–260dp` lebar, `10–16dp` tinggi).

### 3.2 CelebrationPopup (`lib/presentation/widgets/feedback/celebration_popup.dart`)
* Modal bottom sheet meluncur dari bawah via `CelebrationPopup.show(...)`.
* Maskot 130dp overlap 65dp di atas batas kartu.
* Kartu porselen putih radius 32dp dengan border mint 3dp dan bevel 6dp.
* Tombol CTA selebar penuh (*full-width*, tinggi 54dp, font 18sp).

### 3.3 GuidedTracingCanvas (`lib/presentation/widgets/tracing/guided_tracing_canvas.dart`)
* Kanvas tracing 290dp dengan deteksi sapuan presisi.
* Kontrol tunggal `[ ▶ Contoh ]` (reset coretan + animasi demo pensil).
* Tombol adaptif 3 status anti-frustrasi.

### 3.4 AudioPromptButton (`lib/presentation/widgets/buttons/audio_prompt_button.dart`)
* Tombol speaker heroik 72–80dp dengan denyut visual lembut dan penskalaan ikon otomatis 55%.
