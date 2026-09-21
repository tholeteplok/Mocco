# Aplikasi Belajar Alfabet & Angka — Foundation Spec

## 0. Prinsip Dasar (Berbasis Riset)

- **Nama dan bunyi huruf diajarkan bersamaan**, bukan salah satu duluan — riset menunjukkan kombinasi ini mengungguli instruksi bunyi-saja maupun nama-saja
- **Kuantitas, bukan cuma simbol** — angka harus disandingkan representasi visual (jumlah benda), bukan dihafal sebagai bentuk semata; ini fondasi *number sense* yang jadi prediktor kuat kemampuan matematika ke depan
- **Distraktor berbasis kesalahan nyata, bukan acak** — sama filosofi dengan `math-speed-game-core-gameplay-spec.md` §3: pilihan salah harus mencerminkan cara anak biasanya keliru (bentuk visual mirip untuk huruf, salah hitung ±1 untuk angka)
- **Tidak menghukum kesalahan** — prinsip anti-frustrasi yang sama dipegang sejak game matematika berlaku penuh di sini, bahkan lebih penting karena audiensnya lebih muda
- **Multisensori** — lihat + dengar + gerak (tracing sentuh) terbukti memperkuat retensi dibanding lihat+dengar saja

---

## 1. Jalur Huruf

### 1.1 Onboarding

Per huruf, urutan paparan:
1. Tampilkan huruf (besar, jelas, uppercase+lowercase berdampingan)
2. Audio nama huruf ("A")
3. Audio bunyi huruf ("a" pendek/fonetik)
4. Tracing sentuh — anak menelusuri bentuk huruf pakai jari, audio bunyi diputar ulang saat tracing

**Urutan huruf**: alfabet standar sebagai default (sederhana, cukup baik). Opsional pembuka: huruf dari nama anak sendiri terlebih dulu (riset mencatat ini titik masuk efektif secara motivasi) — bisa jadi personalisasi fase lanjutan, bukan wajib di v1.

**Uppercase & lowercase diajarkan bersamaan**, bukan berurutan terpisah — sesuai riset alphabet knowledge.

### 1.2 Fase 1 — Paparan Acak (Hafalan)

Huruf yang sudah di-onboarding muncul acak (bukan urutan), anak diminta identifikasi (tap huruf yang disebutkan, atau sejenis) — tujuan murni familiarisasi, bukan tes, jadi tidak perlu skor/kegagalan eksplisit.

### 1.3 Fase 2 — Kuis Audio-ke-Huruf

Format: audio bunyi/nama huruf diputar sebagai pertanyaan, 4 pilihan huruf sebagai jawaban.

**Distraktor** — reuse pola `DistractorGenerator` dari game matematika, tapi sumber error beda:
| Error pattern | Contoh |
|---|---|
| Kemiripan visual (rotasi/refleksi) | b ↔ d, p ↔ q |
| Kemiripan visual (bentuk umum) | m ↔ w, n ↔ h |
| Kemiripan bunyi | b ↔ p, d ↔ t |

Level rendah: campur 1 distraktor "jauh beda" + sisanya berbasis error, sama prinsip dengan kalibrasi distraktor game matematika (§3.4 core-gameplay-spec) — supaya pemula tidak langsung dihadapkan 4 pilihan yang semuanya membingungkan.

### 1.4 Fase 3 — Blending (Gabung Jadi Kata)

Progresi: 2 huruf → 3 huruf → kata utuh. Ini prinsip *synthetic phonics* (dengar bunyi tiap huruf, gabungkan jadi kata) — metode yang didukung riset literasi awal.

**Catatan khusus Bahasa Indonesia**: sistem ejaan Indonesia jauh lebih transparan/regular dibanding Inggris (hampir tidak ada pengecualian bunyi-huruf) — blending semestinya terasa lebih mulus dan cepat dikuasai anak dibanding kurikulum serupa berbahasa Inggris. Ini keunggulan alami yang bisa dimanfaatkan (progresi ke kata utuh bisa lebih cepat dari asumsi awal).

Pilih kata awal dari suku kata sederhana (KV-KV: "bu-ku", "ma-ta") sebelum kata dengan gugus konsonan.

---

## 2. Jalur Angka

### 2.1 Onboarding

Per angka (1-10 dulu, bukan lebih):
1. Tampilkan simbol angka
2. Audio nama angka
3. **Representasi kuantitas** — kumpulan buah/sayur sejumlah angka tsb., ukuran item seragam (hindari isyarat visual keliru dari ukuran)
4. Tracing sentuh simbol angka

### 2.2 Mekanik Hitung Buah/Sayur (Kuis Utama)

Pertanyaan: tampilkan N buah/sayur (1-10), jawaban 4 pilihan angka.

**Aturan tata letak**:
- **1 jenis objek per soal** (jangan campur apel+jeruk dalam satu hitungan — itu skill klasifikasi+hitung sekaligus, level lebih maju)
- **Ukuran item konsisten** dalam satu soal — cegah anak menilai jumlah dari luas area, bukan hitungan
- **6-10: tata letak berkelompok** (2 baris isi 5, atau pola dadu+sisa) — melatih *conceptual subitizing* ("5 dan 2" bukan hitung manual 7x). 1-5 bebas tata letak, sudah cukup mudah dikenali sekilas dalam susunan apa pun.
- **Anak boleh menghitung** (tidak ada batas waktu di v1) — di tahap ini yang dilatih *cardinality* (paham angka = jumlah), bukan subitizing instan. Mode "kilat" (gambar tampil ~1 detik) untuk subitizing sungguhan dicatat sebagai fase lanjutan opsional, bukan wajib v1.

### 2.3 Distraktor

| Error pattern | Prioritas |
|---|---|
| `correct ± 1` (salah hitung natural — kelewat/kehitung dobel) | Utama |
| Angka jauh beda | Pelengkap, terutama level pemula |

---

## 3. Infrastruktur yang Di-reuse dari Game Matematika

Prinsip desain berikut sudah terbukti di `math-speed-game-*` dan langsung relevan dipakai ulang, beda domain konten saja:

- **Mastery Bank berbasis box Leitner** — huruf/angka yang sering salah muncul lagi setelah beberapa soal lain (spaced retrieval), bukan diulang langsung
- **DDA lunak** — kalau anak kesulitan di huruf/angka tertentu, tambah paparan/waktu, bukan dianggap "gagal"
- **Feedback ±400ms, tidak ada buzzer/hukuman visual** — sama prinsip anti-frustrasi
- **Progress bar visual** (kalau ada elemen waktu di fase lanjutan) lebih baik dari angka countdown — sama alasan beban kognitif seperti di game matematika

**Perbedaan penting dari game matematika**: di v1 aplikasi ini, **jangan pakai timer/tekanan waktu sama sekali** (kecuali mode "kilat" opsional di §2.2, itu pun bukan tekanan kompetitif, murni melatih subitizing). Audiens lebih muda, dan tujuan utamanya pengenalan bukan kecepatan — tekanan waktu di usia ini berisiko kontraproduktif, beda dengan game matematika yang audiensnya lebih siap untuk elemen kompetitif.

---

## 4. Sketsa Model Data

```dart
class LetterMasteryRecord {
  final String letter;       // 'a', 'b', dst — atau 'a-lower', 'A-upper' kalau dipisah kasus
  final int box;             // pola sama dengan MasteryRecord game matematika
  final int attempts;
  final int correct;
}

class NumberMasteryRecord {
  final int number;          // 1-10
  final int box;
  final int attempts;
  final int correct;
}

class CountingQuestion {
  final String objectType;   // 'apel', 'jeruk', dst — nama aset gambar
  final int count;           // 1-10
  final int correctAnswer;   // == count
  final List<int> distractors;
}
```

Struktur ini sengaja mirror `MasteryRecord`/`Question` dari game matematika — kalau nanti dua proyek berbagi package inti (`domain/services` generik untuk mastery tracking + distraktor), migrasinya jadi murah.

---

## 5. Belum Diputuskan (Perlu Dibahas Sebelum Coding)

- Aset gambar buah/sayur: ilustrasi custom atau gunakan set open-source/beli?
- Apakah huruf besar dan kecil dihitung sebagai `MasteryRecord` terpisah atau digabung?
- Struktur progres: linear ketat (harus selesai fase 1 semua huruf sebelum fase 2) atau per-huruf independen (huruf A sudah fase 2 sementara huruf Z masih fase 1)?
- Platform: proyek Flutter terpisah, atau modul di dalam app yang sudah ada?
