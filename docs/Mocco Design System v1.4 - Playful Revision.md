# **Design System — Mocco**

# **Aplikasi Belajar Alfabet & Angka**

Versi: 1.4 (Revisi Interaktif & Tactile Toy Feel)  
Status: Siap implementasi

## **1\. Ringkasan Perubahan dari v1.3 ke v1.4**

Pembaruan utama berfokus pada transisi dari estetika digital-flat menuju pengalaman fisik "Tactile Playground" untuk menciptakan kedekatan emosional dengan pengguna anak-anak.

&nbsp;

* **Claymorphic / Chunky Toy Depth (2.5D)**: Menghilangkan kesan "aplikasi kantor" dengan mengganti bayangan standar menggunakan *bottom border offset* yang tebal. Hal ini menciptakan ilusi optik tombol plastik padat yang dapat ditekan secara nyata.  
* **Custom Chunky Icons**: Peralihan dari Material Symbols yang kaku ke ikon vektor bergaya stiker. Ikon memiliki garis luar yang organik dan sudut yang sangat membulat (*rounded cap*).  
* **Physical Flashcard Feel**: Elemen edukasi (huruf/angka) kini diletakkan di atas kartu dengan *frame* stiker timbul, menyerupai alat peraga fisik di sekolah atau di rumah.  
* **Organic Playground Background**: Mengganti latar belakang putih kosong dengan warna krem hangat (\#FFF6EB) yang dilengkapi siluet bukit pastel samar untuk memberikan kedalaman visual tanpa mengganggu konsentrasi.  
* **Micro-delight & Playful Audio Pairing**: Setiap interaksi didukung oleh transisi "spring" yang kenyal (squishy) dan efek suara mekanik mainan.

## **2\. Prinsip Visual Fondasi (Non-Negotiable)**

Sistem desain ini dibangun di atas delapan pilar utama yang memastikan aplikasi tetap edukatif sekaligus menghibur.

&nbsp;

* **V0.1: Konten adalah bintang** — Elemen huruf dan angka harus selalu menjadi titik fokus terbesar di layar.  
* **V0.2: Kontras tinggi, distraksi rendah** — Visual yang ceria tetap harus memiliki keterbacaan tinggi (WCAG AAA untuk teks utama).  
* **V0.3: Konsisten \> kreatif** — Pola interaksi yang sama untuk tugas yang sama guna membangun rasa percaya diri anak.  
* **V0.4: Tidak ada visual 'salah' yang keras** — Kesalahan direspon dengan petunjuk lembut, bukan tanda silang merah yang mengintimidasi.  
* **V0.5: Target sentuh besar** — Minimum area sentuh adalah 64x64dp untuk mengakomodasi kontrol motorik anak yang masih berkembang.  
* **V0.6: Satu fokus per layar** — Hindari *multitasking* visual; satu instruksi untuk satu aksi.  
* **V0.7: Audio \+ visual selalu berpasangan** — Setiap aksi visual harus memiliki umpan balik auditif yang relevan.  
* **V0.8: Karakter fisik mainan (Tactile First)** — UI harus terasa seperti benda yang bisa disentuh, ditekan, dan digeser, bukan sekadar piksel di balik layar.

## **3\. Arah Style: Playful Primitives & Toybox Warmth**

### **Palet Warna & Identitas Kategori**

Warna digunakan sebagai sistem navigasi kognitif untuk membedakan mode belajar.

&nbsp;

| Kategori | Warna Utama | Tint (BG Kartu) | Bevel (Shadow) |
| :---- | :---- | :---- | :---- |
| **Latar Utama** | \#FFF6EB (Warm Cream) | \- | \- |
| **Huruf** | \#6FA8DC (Pastel Blue) | \#E3EEF9 | \#4F86B8 |
| **Angka** | \#F4A259 (Pastel Orange) | \#FDEBD7 | \#D68236 |
| **Blending** | \#7BC47F (Pastel Green) | \#E3F4EC | \#5DA361 |
| **Feedback Benar** | \#E8F5E9 | \- | \#7BC47F |
| **Feedback Coba Lagi** | \#FFF3D6 | \- | \#F5C542 |

### **Tipografi**

* **Display Belajar**: Menggunakan font **Andika** (OFL) dengan ukuran 120–200sp. Font ini dipilih karena bentuk hurufnya yang menyerupai tulisan tangan instruksional yang benar.  
* **Antarmuka (UI)**: Menggunakan **Lexend Soft** atau **Nunito Rounded** (20–28sp) untuk kejelasan navigasi dengan karakter yang bersahabat.

## **4\. Spesifikasi Komponen & Rasa Sentuh (Tactile 2.5D)**

### **Tombol Chunky (Toy Button)**

* **Bentuk**: *Pill* atau *rounded rectangle* dengan radius 24dp \- 32dp.  
* **Visual 3D**: Menggunakan lapisan bawah (bevel) setebal 4dp-6dp dengan warna yang lebih gelap dari warna utama tombol.  
* **Interaksi**: Saat ditekan (*State Pressed*), posisi tombol turun 4dp secara vertikal (Y-axis) dan bevel menipis menjadi 1dp, memberikan kepuasan taktil "klik" yang nyata.

### **Kartu Flashcard Jawaban**

* **Dimensi**: Minimal 96x96dp, ukuran ideal pada tablet 120x120dp.  
* **Gaya**: Memiliki *frame border* 3dp warna pastel kategori dan *bottom bevel* 4dp.  
* **Kontras**: Karakter di tengah (Glyph) wajib menggunakan warna hitam pekat (\#000000) untuk aksesibilitas maksimal.

### **Header Non-Kantoran**

* **Elemen Kontrol**: Tombol navigasi (kembali/pengaturan) dibungkus dalam lingkaran *bubble* (56-64dp) dengan border tebal.  
* **Progress Indicator**: Berbentuk "kapsul jelly" transparan yang terisi oleh segmen-segmen warna pastel seiring kemajuan belajar.

## **5\. Peta Petualangan & Objek Interaktif**

Dunia belajar dibagi menjadi beberapa zona interaktif yang terasa seperti papan permainan fisik.

&nbsp;

* **Node Perhentian**: Menggunakan desain kenop 3D (*chunky badge*) yang menonjol keluar dari layar. Dilengkapi efek kilau (*glossy*) lembut untuk menarik perhatian.  
* **Sistem Reward**: Koleksi stempel di Buku Petualangan menggunakan desain stiker karet timbul (*embossed rubber sticker*).  
* **Objek Hitung**: Aset visual (buah, hewan, benda) menggunakan gaya ilustrasi *flat-rounded* dengan *outline* putih tebal (seperti stiker yang baru dipotong).

## **6\. Tabel Keputusan yang Dikunci (V1 \- V29)**

| Kode | Area | Keputusan Spesifikasi |
| :---- | :---- | :---- |
| V1 | Layout | Layout wajib kunci orientasi Landscape. |
| V2 | Skala | Menggunakan 8dp grid system untuk semua spacing. |
| V3 | Corner | Radius sudut terkecil adalah 12dp (soft corners only). |
| V4 | Kontras | Teks instruksi wajib kontras rasio minimal 4.5:1. |
| V5 | Font | Andika wajib digunakan untuk mode literasi/tracing. |
| V6 | Tombol | Wajib memiliki state visual 'pressed' yang nyata (offset Y). |
| V7 | Animasi | Durasi transisi antara 200ms \- 400ms (Spring/Bounce). |
| V8 | Audio | Klik tombol menggunakan suara "pop" kayu/plastik. |
| V9 | Dialog | Pop-up menggunakan modal rounded dengan overlay blur 4px. |
| V10 | Ikon | Ikon tidak boleh menggunakan garis tipis \< 2dp. |
| V11 | Warna | Dilarang menggunakan warna hitam murni \#000000 untuk latar. |
| V12 | Bayangan | Bayangan harus berupa solid-color bevel, bukan blur shadow. |
| V13 | Navigasi | Navigasi utama tidak boleh lebih dari 3 pilihan di satu layar. |
| V14 | Feedback | Partikel bintang keluar saat jawaban benar (Visual Joy). |
| V15 | Error | Getaran halus (Haptic) saat input salah (jika perangkat mendukung). |
| V16 | Flashcard | Elevasi kartu naik saat di-drag (Scaling 1.05x). |
| V17 | Border | Border elemen UI menggunakan warna tint gelap kategori terkait. |
| V18 | Loading | Animasi loading menggunakan karakter Mocco yang melompat. |
| V19 | Text UI | Lexend Soft Medium untuk keterbacaan menu utama. |
| V20 | Spacing | Jarak antar kartu minimal 16dp. |
| V21 | World Map | Background menggunakan gradasi linear lembut (Top-Down). |
| V22 | Badge | Lencana reward memiliki efek "Wiggle" saat baru didapat. |
| V23 | Konten | Angka menggunakan font yang sama dengan huruf untuk konsistensi. |
| V24 | Voice | Voice-over otomatis aktif saat masuk ke layar latihan baru. |
| V25 | Overlay | Overlay gelap saat pause hanya setransparan 40%. |
| V26 | Scrolling | Scroll area harus memiliki indikator panah chunky yang berdenyut. |
| V27 | Interaction | Tekan lama (Long press) ditiadakan untuk menghindari kebingungan. |
| V28 | Progress | Bar progress harus selalu memiliki warna kontras dari background. |
| V29 | Safety | Tombol "Keluar" diletakkan di pojok dengan proteksi "Hold 3s". |

&nbsp;