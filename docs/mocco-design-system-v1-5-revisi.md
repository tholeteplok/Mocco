# Design System — Mocco v1.5 (Revisi)

Perubahan terhadap v1.4, disusun sebagai changelog supaya jelas apa yang berubah dan kenapa.

## Klarifikasi Interaksi Drag (V16) — Diterima, Dijabarkan Lebih Detail

Drag dipakai **khusus di soal hitung** sebagai alat bantu opsional — bukan menggantikan mekanisme jawab-pilih-4-kartu, tapi melengkapinya. Anak boleh menggeser objek satu-satu ke area "sudah dihitung" di sudut kartu sebelum menjawab, atau langsung pilih jawaban tanpa drag kalau sudah bisa menghitung sekilas. Ini scaffold klasik untuk membangun korespondensi satu-satu (*one-to-one correspondence*) — mencegah anak menghitung objek yang sama dua kali atau melewatkan satu, dan sekaligus memenuhi V0.8 (tactile first) secara sangat langsung.

**Detail interaksi**:
- Area target ("keranjang hitung") ditempatkan di sudut kartu, gaya chunky bulat, tint warna kategori Angka (`#FDEBD7` / bevel `#D68236`) — konsisten dengan sistem warna kategori yang sudah ada
- Objek yang sudah digeser masuk ke keranjang **tidak menampilkan angka apa pun** (tidak ada counter numerik live) — kalau ditampilkan, itu sama saja membocorkan jawaban sebelum anak sempat menjawab sendiri; yang terlihat cuma tumpukan visual objek, anak tetap yang menyimpulkan jumlahnya
- Objek di keranjang bisa digeser balik keluar (undo alami lewat drag terbalik) — tidak perlu tombol undo terpisah, konsisten dengan V27 (tanpa long-press, interaksi tetap sederhana)
- Setelah anak merasa cukup (baik pakai drag maupun tidak), jawaban tetap dipilih lewat 4 kartu angka seperti biasa — drag murni alat bantu proses, bukan mekanisme submit jawaban

**Tambahan kode keputusan**:

| Kode | Area | Spesifikasi |
|---|---|---|
| V16 (revisi) | Interaksi Hitung | Drag objek ke "keranjang hitung" di sudut kartu — HANYA di soal hitung, opsional, tanpa counter numerik live saat drag berlangsung |

---

## Perbaikan Kontradiksi Internal

### V4 vs V0.2 — Ambang Kontras

**Masalah**: V0.2 mengklaim target WCAG AAA, tapi V4 mengunci 4.5:1 (itu ambang AA untuk teks normal, AAA butuh 7:1).

**Revisi** — pilih salah satu, saya sarankan opsi A supaya klaim di V0.2 tetap valid tanpa kompromi keterbacaan:

| Kode | Area | Spesifikasi Lama | Spesifikasi Revisi |
|---|---|---|---|
| V4 | Kontras | Rasio minimal 4.5:1 | **Opsi A (disarankan)**: 7:1 untuk teks instruksi ukuran normal, 4.5:1 khusus teks besar ≥18pt/24px — memenuhi ambang AAA yang sudah diklaim di V0.2 |
| — | — | — | **Opsi B (alternatif)**: turunkan klaim V0.2 jadi "WCAG AA", biarkan V4 di 4.5:1 apa adanya |

### V9 vs V12 — Blur Shadow

**Masalah**: V12 melarang blur shadow demi performa (bevel solid dipilih justru karena lebih murah dirender), tapi V9 mewajibkan blur 4px di overlay modal — kontradiksi alasan performa yang sama.

**Revisi**:

| Kode | Area | Spesifikasi Lama | Spesifikasi Revisi |
|---|---|---|---|
| V9 | Dialog | Modal rounded dengan overlay blur 4px | Modal rounded dengan overlay **gelap solid 40% transparan** (pola sama dengan V25) — tanpa `BackdropFilter`/blur, aman untuk tablet kelas menengah-bawah dan konsisten dengan alasan performa di V12 |

---

## Keputusan Baru (Mengisi Celah)

| Kode | Area | Spesifikasi |
|---|---|---|
| V30 | Objek Hitung | Semua objek dalam satu soal hitung wajib berukuran seragam — cegah anak menilai jumlah dari luas area alih-alih menghitung sungguhan |
| V31 | Audio | Sumber audio bunyi/nama huruf & angka wajib rekaman suara manusia asli, bukan text-to-speech — pelafalan bunyi fonetik pendek sering terdengar tidak natural lewat TTS, krusial untuk fase pengenalan bunyi |
| V32 | Voice-over | V24 diperjelas: voice-over otomatis berbunyi **sekali per kunjungan ke layar** (saat pertama masuk tipe latihan baru), **bukan** berulang tiap soal dalam sesi kuis yang sama — mencegah ritme belajar melambat untuk anak yang sudah familiar |
| V33 | Text Scaling | Glyph Display (font Andika, 120-200sp) **tidak** mengikuti pengaturan text-scaling OS perangkat — ukurannya sudah sengaja besar untuk keterbacaan maksimal, scaling tambahan berisiko merusak layout flashcard |
| V34 | Audio Setting | Wajib ada toggle mute/audio di layar pengaturan — audio otomatis (V24/V32) butuh jalan keluar untuk situasi yang butuh senyap |

---

## Ditandai "Perlu Konfirmasi" (Bukan Diputuskan Sepihak di Sini)

| Kode | Area | Catatan |
|---|---|---|
| V1 | Layout | Kunci orientasi Landscape masih masuk akal **kalau** target utama tablet. Kalau banyak pengguna diperkirakan pakai HP orang tua (portrait default), landscape-only bisa jadi friksi. Perlu dikonfirmasi device target sebelum status "non-negotiable" dipertahankan. |

---

## Ringkasan Perubahan dari v1.4

- **Diperbaiki** (kontradiksi internal): V4, V9
- **Ditambah** (celah baru): V30, V31, V32, V33, V34
- **Diperjelas** (bukan diubah substansinya): V16 — sudah sesuai maksud awal, cuma dijabarkan detail interaksinya
- **Ditandai perlu keputusan eksternal**: V1
