# Google Play Console & Store Compliance Guide for Mocco

Dokumen ini adalah panduan praktis (*submission cheat-sheet*) untuk pengembang saat mengisi deklarasi rilis aplikasi Mocco di **Google Play Console** dan **Apple App Store Connect**.

---

## 1. Google Play Console — Kategori & Target Audiens

### A. Target Audience and Content (Target Audiens & Konten)
* **Kelompok Usia Sasaran (*Target Age Groups*)**:
  * Centang: **Usia 5 tahun ke bawah (Ages 5 and under)**
  * Opsional: **Usia 6–8 tahun (Ages 6–8)**
* **Dirancang untuk Keluarga (*Designed for Families / Families Policy*)**:
  * Status: **Wajib Mematuhi Kebijakan Keluarga Google Play**.
  * Aplikasi Mocco sepenuhnya mematuhi standar privasi anak:
    * Semua aset font dibundle luring (`assets/fonts/`).
    * Semua audio fonik dan SFX dibundle lokal (`assets/audio/`).
    * Tidak ada pemanggilan HTTP / REST API runtime.

### B. Deklarasi Iklan (*Ads Declaration*)
* Pertanyaan: *Does your app contain advertisements?* (Apakah aplikasi Anda berisi iklan?)
* Jawaban: **TIDAK (No, my app does not contain ads)**.
* Tidak ada SDK iklan pihak ketiga yang terpasang di `pubspec.yaml`.

---

## 2. Formulir Keamanan Data (*Data Safety Form*)

Saat mengisi kuesioner **Data Safety** di Play Console:

| Pertanyaan / Bagian | Jawaban | Catatan / Rujukan |
| :--- | :--- | :--- |
| **Data Collection and Security** | | |
| *Does your app collect or share any of the required user data types?* | **No** (Tidak) | Mocco tidak mengumpulkan data pengguna apa pun ke server eksternal. |
| *Is all user data collected encrypted in transit?* | **N/A** (Tidak ada data dikirim) | Tidak ada transmisi jaringan. |
| *Do you provide a way for users to request data deletion?* | **N/A** | Semua progres disimpan lokal di perangkat (`Hive box`) dan terhapus otomatis saat aplikasi di-uninstall. |

---

## 3. Rating Konten (*IARC Content Rating Questionnaire*)

* **Kategori Aplikasi**: Aplikasi Konsumen / Game Edukasi (*Educational Game*).
* **Kekerasan / Ketakutan (*Violence & Fear*)**: **Tidak** (Aset bertema tanah liat cerah / *playful clay diorama*).
* **Bahasa Kasar (*Profanity*)**: **Tidak** (Instruksi fonik ramah balita: "Hebat!", "Pintar sekali!").
* **Materi Dewasa (*Sexuality / Drugs*)**: **Tidak**.
* **Interaksi Pengguna (*User Interaction / Social Features*)**: **Tidak** (Tidak ada chat room, tidak ada pertukaran pesan antar pengguna).
* **Pembelian Barang Digital (*Digital Purchases*)**: **Tidak** (Tidak ada In-App Purchases).
* **Hasil Rating**:
  * **ESRB**: Everyone (E)
  * **PEGI**: 3
  * **USK**: 0
  * **IARC**: 3+

---

## 4. Akses Aplikasi & Gerbang Orang Tua (*Parental Gate*)

Jika peninjau Google Play (*App Reviewer*) menanyakan terkait akses area pengaturan atau informasi eksternal:
* Mocco mengimplementasikan **Parental Gate** bawaan: [`ParentGateDialog`](lib/presentation/widgets/dialogs/parent_gate_dialog.dart).
* Sebelum orang dewasa dapat membuka *Parent Dashboard*, sistem menampilkan dialog teka-teki matematika acak (misal: "Berapa 4 + 7?") yang memerlukan kemampuan aritmatika dasar di luar daya kognitif balita usia 2–4 tahun.

---

## 5. Tautan Kebijakan Privasi (*Privacy Policy URL*)

Play Console mewajibkan tautan publik ke Kebijakan Privasi yang aktif. Anda dapat mengarahkan ke:
1. File publik di GitHub:  
   `https://raw.githubusercontent.com/<username>/Mocco/main/PRIVACY_POLICY.md`  
   atau halaman GitHub Pages repositori ini.
2. Pastikan teks di halaman tersebut identik dengan isi dokumen [`PRIVACY_POLICY.md`](PRIVACY_POLICY.md).
