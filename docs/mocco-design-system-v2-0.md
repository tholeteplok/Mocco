# Mocco Design System v2.0 — Airy Clay & Playful Diorama

Sistem desain generasi kedua untuk Mocco, ditransformasikan secara menyeluruh mengadopsi standar industri terbaik dari referensi kurasi Pinterest (*Kids Education Mobile App UI — Learn English & Pre-Math*).

---

## 1. Filosofi Inti (The 5 Golden Pillars)

### 1.1 The Floating Playground (Bebas dari Sindrom Birokrasi Kotak)
* **Masalah v1.5**: Setiap objek dimasukkan ke dalam kotak individu dengan border tebal dan bevel kaku (`CountingObjectItem`). Ini menciptakan *visual clutter* yang berat dan membuat aplikasi terasa seperti tabel perkantoran.
* **Standar v2.0**: Objek belajar (buah 3D clay, sayuran, stiker huruf) **berdiri bebas (*floating*)** di atas kartu putih bersih (`#FFFFFF`). Objek hanya memiliki bayangan kontak lembut (*soft contact shadow*), diperlakukan layaknya mainan nyata di atas karpet bermain (*physical diorama*).

### 1.2 Prinsip Fokus Tunggal (*Single-Task Principle*)
* Anak usia 2–6 tahun memiliki kapasitas *working memory* terbatas. Satu layar hanya boleh memiliki **satu jenis interaksi utama**.
* **Layar Berhitung Visual**: Murni menampilkan objek untuk dihitung secara visual + 4 tombol pilihan angka simetris di bawah. Keranjang interaktif dipindahkan ke mode permainan korespondensi terpisah agar tidak membingungkan anak.

### 1.3 Palet Warna Tenang-Ceria (*Calm-Vibrant Harmonization*)
* **Kanvas & Latar Belakang**: Krem susu hangat (`#FAF8F5`) yang menenangkan sistem syaraf visual anak.
* **Permukaan Kartu**: Putih bersinar (*Luminous White* `#FFFFFF`) dengan sudut membulat lebar (24dp) dan garis tepi tipis (`#F0EAE1`, 1.5dp).
* **Aksen Interaktif (*Vibrant Anchors*)**: Warna-warna cerah hanya diaplikasikan pada objek belajar 3D, status sukses (Mint `#2EC4B6`), dan tombol aksi utama.

### 1.4 Geometri Simetris Anti-Orphan (*1x4 & 2x2 Grids*)
* Dilarang keras membiarkan tombol jawaban terbungkus (*wrap*) secara asimetris menjadi 3 di baris atas dan 1 yatim di baris bawah.
* Jawaban pilihan ganda selalu disusun dalam:
  * **1 Baris Presisi (1x4)**: Menggunakan `Row` + `Expanded` dengan padding proporsional.
  * **Grid 2x2**: Khusus jika teks/konten memerlukan dimensi vertikal lebih besar.

### 1.5 Siklus Dopamin Maskot (*The Gamified Feedback Loop*)
* Mengeliminasi transisi otomatis instan (1 detik) yang membingungkan.
* Saat jawaban benar:
  1. Tombol pilihan angka langsung menyala hijau toska cerah (`#2EC4B6`) dengan teks putih dan animasi timbul (*spring bounce*).
  2. Suara sukses (*chime* + pujian suara Gadis: *"Hebat!" / "Pintar!"*) diputar.
  3. Muncul banner selebrasi di bagian bawah layar: Maskot tersenyum gembira + teks afirmasi + tombol besar **`[ Lanjut → ]`**.
  4. Anak memegang kendali penuh kapan ingin melangkah ke soal berikutnya setelah menikmati rasa pencapaian mereka.

---

## 2. Token Desain Terpusat (Design Tokens)

### 2.1 Warna (AppColors)
| Token | Hex | Penggunaan |
| :--- | :--- | :--- |
| `canvasBackground` | `#FAF8F5` | Latar belakang seluruh layar (Krem Susu) |
| `cardSurface` | `#FFFFFF` | Permukaan kartu utama (Putih Bersih) |
| `cardBorder` | `#F0EAE1` | Garis tepi kartu minimalis (1.5dp) |
| `cardBevel` | `#E8E0D5` | Bevel kontak 2.5D lembut (3dp) |
| `brandMint` | `#2EC4B6` | Warna sukses, tombol lanjut, highlight benar |
| `brandMintDark` | `#25A296` | Bevel tombol mint sukses |
| `numberPrimary` | `#FF9F1C` | Aksen kategori angka (Oranye ceria) |
| `letterPrimary` | `#4EA8DE` | Aksen kategori huruf (Biru langit) |
| `textPrimary` | `#2B2D42` | Teks utama kontras tinggi (Charcoal ramah anak) |
| `textSecondary` | `#6C757D` | Teks pendukung |
| `successBannerBg` | `#E8F8F5` | Latar belakang banner selebrasi |

### 2.2 Dimensi & Radius (AppSpacing)
| Token | Nilai | Penggunaan |
| :--- | :--- | :--- |
| `radiusCard` | `24.0` | Sudut kelengkungan kartu utama |
| `radiusPill` | `32.0` | Sudut kelengkungan tombol jawaban & banner |
| `radiusButton` | `18.0` | Sudut kelengkungan tombol kontrol |
| `minTouchTarget` | `64.0` | Target sentuh minimum motorik anak |
| `bevelCard` | `4.0` | Tebal bevel kartu 2.5D |
| `bevelPill` | `4.0` | Tebal bevel tombol jawaban |

---

## 3. Spesifikasi Komponen

### 3.1 ChunkyCard v2.0
* Permukaan: Putih `#FFFFFF` murni.
* Radius: 24dp melengkung lembut.
* Border: 1.5dp `#F0EAE1`.
* Kontak 2.5D: Offset solid 4dp `#E8E0D5`.

### 3.2 AnswerChoiceTile (Pill Jawaban)
* Ukuran: Tinggi 64–72dp, flex proporsional 1x4 horizontal.
* Normal: Latar `#FFFFFF`, border 2dp `#F0EAE1`, bevel 4dp `#E8E0D5`, angka tebal `#FF9F1C` / `#2B2D42`.
* Benar: Latar `#2EC4B6`, border 2dp `#25A296`, bevel 4dp `#25A296`, angka tebal `#FFFFFF`.
* Salah (Soft Retry): Efek wobble halus tanpa warna agresif merah.

### 3.3 CelebrationBanner
* Terletak di bagian bawah layar saat anak berhasil menjawab.
* Komponen:
  * Avatar Mocco berukuran 56x56dp dengan ekspresi gembira.
  * Bubble teks: *"Hebat sekali!"* / *"Kamu pintar!"*.
  * Tombol CTA: Lebar dinamis, warna `#2EC4B6`, teks *"Lanjut"* dengan ikon panah.

### 3.4 CountingFloatingArea
* Objek diatur secara subitizing:
  * 1–5 objek: 1 baris lurus simetris di tengah.
  * 6–10 objek: 2 baris teratur (5 di baris atas, sisanya di baris bawah).
* Objek transparan PNG 3D clay tanpa frame kotak, dilengkapi bayangan lantai oval tipis.
