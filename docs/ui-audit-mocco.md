# Audit Konsistensi UI Mocco vs Design System v2.0

- Scope: seluruh `Mocco` (`lib/`)
- Acuan: `docs/mocco-design-system-v2-0.md`
- Mode: light only
- Target: mobile 375px + tablet 768px
- Metode: static code + verifikasi langsung file kunci, tanpa edit kode
- Tanggal: 2026-09-23

## Skor ringkas

| Kategori | Skor | Catatan |
|---|---:|---|
| A Token warna/spacing/radius/bevel | 9/10 | Definisi token cocok DS. Pelanggaran di pemakaian, bukan definisi. |
| B Komponen heroik | 7/10 | Struktur `CelebrationPopup`, `AudioPromptButton`, `ChunkyButton` cocok. 2 deviasi fungsional: opacity diorama + threshold tracing. |
| C Layout mobile/tablet | 6/10 | Pola responsif ada tapi tidak konsisten. Risiko overflow 375px dan CTA fixed-width. |
| D Blind spot pra-sekolah 2-6 th | 6/10 | Fondasi pre-reader kuat. Risiko di threshold motorik, copy CTA default, warna hardcoded, parent-gate tidak langsung. |

## Temuan Critical

| # | Severity | Lokasi | Expected DS | Actual | Rekomendasi |
|---|---|---|---|---|---|
| B1 | Critical | `lib/presentation/widgets/stage/diorama_stage.dart:28,55,61` | Backdrop elips opacity 0.40 | Default `elevation=0.08`, dipakai sebagai alpha + glow `elevation*0.7` | Ubah default ke `0.40`. Grep override di `letter_*`, `counting_screen`, `blending` sebelum ubah. |
| B2 | Critical | `lib/presentation/widgets/tracing/guided_tracing_canvas.dart:54,58,106` | Selesai `>=70%` picu selebrasi | `perStrokeThreshold=0.78`, `totalProgressThreshold=0.80` | Selaraskan ke `0.70` atau revisi DS ke `80%`. Anak 70-79% saat ini tertahan tanpa `CelebrationPopup`. |
| C1 | Critical | `lib/presentation/screens/blending/syllable_blending_screen.dart:179-316` | Muat 375px, scroll aman | `Column` + `Spacer` x2, tanpa `SingleChildScrollView` terdeteksi | Bungkus scroll, ganti `Spacer` dengan `SizedBox(space24/space20)`. Uji 375px height kecil. |
| D1 | Critical | `lib/presentation/widgets/tracing/guided_tracing_canvas.dart:42-63` | Toleran motorik balita | Koridor `toleranceRadius=15.0`, `step 6.0`, guard `strokeActivation 0.60` + ambang 80% | Pertahankan hanya bila ada demo otomatis + undo besar + CTA 3-status. Uji anak 2-3 th, turunkan ambang bila frustrasi berulang. |

## Temuan Major

| # | Severity | Lokasi | Expected DS | Actual | Rekomendasi |
|---|---|---|---|---|---|
| B3 | Major | `lib/presentation/widgets/buttons/chunky_button.dart:101-110` | CTA `Lanjut Latihan` utuh, tanpa `Lanju...` | `Flexible` + `ellipsis` + `maxLines:1` | Wajib `width=double.infinity` untuk CTA selebrasi. Jangan pakai `ChunkyButton` di parent fixed-width tanpa `Expanded`. |
| B4 | Major | `lib/presentation/screens/counting/counting_screen.dart:260,267,276,281,283,296,303` | CTA full-width 54dp font 18sp | `width:260.0`, `height:52.0`, teks `Coba Lagi / Tebalkan Dulu` | Ganti ke `double.infinity`, `height:54`, `fontSize:18`. Berlaku juga `letter_onboarding_screen.dart:322,329,338,345,358,365` pola sama. |
| C2 | Major | `lib/presentation/screens/node/node_detail_screen.dart:215-231` | Muat 375px, padding 16 | Backdrop `340x300` fixed | `width:min(340,width-32)`, tambah `ResponsiveHelper.value` tablet. |
| C3 | Major | `lib/presentation/screens/node/node_detail_screen.dart:246-260` | Teks utuh tanpa clip | `learningDisplay 160.0` tanpa `FittedBox/Expanded` | Bungkus `FittedBox(scaleDown)`, `maxLines:1`. |
| C4 | Major | `lib/presentation/screens/letter/letter_onboarding_screen.dart:247-264,388-405,495-511`, `letter_match_screen.dart:111-133`, `counting_screen.dart:186-202,324-340`, `letter_quiz_screen.dart:164-180` | Prompt muat 375px | `Row` + `Text 18-22sp` + `AudioPromptButton` tanpa `Expanded/Flexible` | Bungkus `Text` dengan `Expanded`, `softWrap:true`, `maxLines:2`. Skala tablet via `ResponsiveHelper`. |
| C5 | Major | `lib/presentation/screens/letter/letter_match_screen.dart:107-108`, `letter_quiz_screen.dart:141-142`, `letter_onboarding_screen.dart:224-225`, `counting_screen.dart:167-168` | Padding horizontal `space16` tunggal | `ResponsiveScaffold(16)` + inner scroll horizontal `space16` = 32dp ganda | Hapus padding horizontal inner, sisakan `bottom` saja. |
| C6 | Major | `lib/presentation/screens/home/home_screen.dart:100,127,227,285`, `rewards_screen.dart:73-78` | Margin seksi `space24`, grid adaptif | Gap `8/12/16` dominan, `Grid crossCount:3 fixed spacing:8` | Naikkan gap seksi ke `space24`, `crossCount:ResponsiveHelper.value(mobile:3,tablet:4)`, center `maxWidth 600`. |
| D2 | Major | `lib/presentation/screens/letter/*`, `counting_screen`, `blending` | Pre-reader: audio dulu, teks pendamping | Instruksi teks masih dominan di samping `AudioPromptButton` | Pastikan `AudioPromptButton` 72dp autoplay sekali, ikon besar, teks hanya pendamping orang tua. |
| D3 | Major | `lib/presentation/screens/letter/letter_quiz_screen.dart`, `blending/syllable_blending_screen.dart`, `counting_screen.dart` | Zero-choice, maks 2-3 pilihan besar | Risiko pilihan >3 per layar | Pecah jadi langkah linear satu aksi. Audit jumlah opsi per layar. |

## Temuan Minor

| # | Severity | Lokasi | Expected DS | Actual | Rekomendasi |
|---|---|---|---|---|---|
| B5 | Minor | `lib/presentation/widgets/feedback/celebration_popup.dart:22,38` | Copy `[Lanjut Latihan]` | Default `buttonText='Lanjut'` | Wajibkan call-site passing `'Lanjut Latihan'`. Terverifikasi `letter_onboarding:291` sudah benar, lainnya audit via grep `CelebrationPopup.show`. |
| B6 | Minor | `lib/presentation/widgets/feedback/celebration_popup.dart:95-104,118,129` | Kartu `cardSurface`, border mint 3dp bevel 6dp | `Colors.white`, `0xFFB2EAE3`, `0xFFD0F0EB`, teks `0xFF13695F/0xFF267D73` hardcoded | Daftarkan sebagai token atau ganti ke `AppColors.cardSurface/brandMint/brandMintDark`. Dimensi radius 32dp + bevel 6dp sudah benar. |
| B7 | Minor | `lib/presentation/widgets/stage/diorama_stage.dart:26-27,79-91` | Floor shadow 110-260x10-16 | Default `120x14` elips, alpha 0.22 | Pertahankan. Larang override di luar rentang. |
| A1 | Minor | `lib/core/theme/app_theme.dart:11-14` | Surface kartu `#FFFFFF` bila dipakai kartu | `surface:AppColors.background #FAF8F5` | Ganti ke `cardSurface` bila `colorScheme.surface` dipakai kartu. Verifikasi pemakaian. |
| A2 | Minor | `lib/core/theme/app_theme.dart:18-20` | Konsisten token tipografi | `headlineMedium 24`, `bodyMedium 16` override default 28/20 | Dokumentasikan di DS atau samakan ke `AppTypography`. |
| C7 | Minor | `lib/presentation/widgets/headers/responsive_scaffold.dart` + `chunky_header.dart` | `SafeArea` tunggal | `body:SafeArea` + header `SafeArea` = inset atas ganda | `body SafeArea(top:false)`. |
| C8 | Minor | `lib/presentation/screens/map/adventure_map_screen.dart:226-230,408-419`, `journey_screen.dart:250-253`, `splash_screen.dart:105-146` | `minTouchTarget 64`, responsif | Padding fixed `140/80/92/64`, button `52x64`, splash tanpa scroll | Pakai `ResponsiveHelper.value`, tinggi zona tekan 64, splash bungkus scroll + skala tablet. |
| C9 | Minor | `lib/core/utils/responsive_helper.dart:5-9` | Target 768 tercakup | `tabletBreakpoint=600.0`, jarang dipakai 9/12 screen | Pertahankan 600, tambah `maxContentWidth`, pakai di home, rewards, counting, letter, node. |
| D4 | Minor | `lib/presentation/widgets/headers/jelly_progress_bar.dart`, `widgets/counting/counting_basket.dart` | Progres simbolik bintang emas 32dp | Counter angka abstrak | Ganti dengan 3 bintang progresif + `Icons.shopping_basket_rounded` besar + label audio. |

## Yang sudah sesuai — pertahankan

- Token `AppColors` cocok DS: `canvasBackground 0xFFFAF8F5:7`, `cardSurface/Border/Bevel:9-11`, `letterPrimary 0xFF4EA8DE:14`, `numberPrimary 0xFFFF9F1C:19`, `blendingPrimary 0xFF7BC47F:25`, `brandMint 0xFF2EC4B6:32`, `brandMintDark 0xFF25A296:33`, `retryBackground/Bevel:38-39`, `textPrimary/Secondary:42-43`, `modalOverlay 0x66000000:47`.
- Token `AppSpacing`: `space8/12/16/20/24`, `minTouchTarget 64.0:22`, `radiusCard 24.0:34`, `radiusPill 32.0:35`, `bevelThick 6.0:46`.
- `ChunkyButton:21` default `height=minTouchTarget`. `BubbleIconButton` default `size=bubbleButtonSize=64`. `AudioPromptButton:12,100-103` size `72.0` + ikon `55%` + denyut `1.0-1.08`.
- `CelebrationPopup:63-64,81-83` maskot `130dp` overlap `65dp` `Stack Clip.none`, scrim `modalOverlay`, CTA `double.infinity 54dp 18sp:135-151`, `isDismissible:false, enableDrag:false`.
- `CelebrationBanner` hanya alias `CelebrationPopup:feedback/celebration_banner.dart:6`. Tidak ada banner inline. Pemakaian `CelebrationPopup.show` terverifikasi di `blending:138`, `counting:127,225`, `letter_match:79`, `letter_onboarding:176,287`, `letter_quiz:112`.
- Kontrol tracing tunggal `[Contoh]` + CTA adaptif `[Tebalkan Dulu / Coba Lagi / Lanjut]` terverifikasi di `counting_screen:237-303` dan `letter_onboarding:299-365`.
- `ChunkyCard` tersisa di `home:130,288`, `rewards:33`, `parent_dashboard:49,77,147,189,226,252` — bukan konten latihan utama, masih dapat diterima. Jangan pakai untuk konten latihan, gunakan `DioramaStage`.

## Blind spot pra-sekolah — risiko sisa

| # | Area | Risiko usia 2-6 | Status Mocco | Aksi |
|---|---|---|---|---|
| S1 | Threshold motorik | Ambang 80% + koridor 15dp terlalu ketat untuk 2-3 th | Perlu uji | Turunkan ke 70% sesuai DS atau tambah mode bantuan bertahap. Sediakan undo satu-ketuk besar. |
| S2 | Copy CTA default | Default `Lanjut` melanggar copy DS, membingungkan pre-reader | Perlu perbaiki | Ubah default `CelebrationPopup.buttonText` ke `'Lanjut Latihan'`. |
| S3 | Warna hardcoded di luar token | `0xFFE0574A`, `0xFFC05621`, `0xFF13695F`, `0xFFB2EAE3`, `0xFFFAF7F2`, `map 0xFFDCD8D3/0xFFB0ABA4/0xFF8C867F`, `tracing 0xFF3ECF6A/0xFF538BBC/0xFFEDE4D8` berisiko kontras di krem | Perlu audit kontras | Daftarkan ke `AppColors` + uji kecerahan rendah. Larang teks di atas opacity 40% tanpa chip solid. |
| S4 | Parent gate tidak langsung | `parent_dashboard_screen` tidak memanggil `ParentGateDialog` sendiri, mengandalkan `mocco_shell:61` + `journey:207` + `map:257` | Mitigasi parsial | Bungkus rute parent langsung dengan `ParentGateDialog`. Audit deep-link agar tidak bypass shell. |
| S5 | Navigasi pulang | Back/home persisten 64dp belum terverifikasi di semua latihan | Perlu verifikasi | Tambah header home 64dp + back 64dp di latihan. Kembali selalu ke peta. Cegah tap ganda. |
| S6 | Feedback <100ms | `SoundPlayer` + animasi bounce belum diukur | Perlu ukur | Preload audio, feedback sentuh <100ms, jangan blokir TTS panjang. |
| S7 | Gestur kompleks | `counting_floating_area`, `looping_map_canvas`, `tracing_canvas` pakai drag | Perlu verifikasi | Ganti drag presisi dengan tap-to-move + snap target besar. Larang hover-only, multi-jari, timeout. Dialog selalu satu CTA 64dp tanpa timeout. |
| S8 | Tablet 768 | `ResponsiveHelper` ada tapi jarang dipakai, kanvas tracing fixed `290dp` | Belum adaptif penuh | `size:ResponsiveHelper.value(mobile:290,tablet:340)`, container 280 -> 320-360, grid 3 -> 4. |

## Bypass token terdeteksi — wajib sentralisasi

`guided_tracing_canvas:386,430-440,504,566,589,594,616,641`, `celebration_popup:98,103,118,129`, `home:109,131,243,264,272,280,289`, `node_detail:90-92,692`, `splash:106`, `map:218 + looping_map_canvas:105,149`, `journey:231`, `counting_basket:48`, `map_node_button:84-85,152,187`, `clay_*:path_painter:8-9, container:13-14, stepping_stone:78-79,146`, `letter_onboarding:472,609,612,633,640`, `letter_match:259,294`, `adventure_map zone button 414 height:52`, `screen_time_dialog:41 0xFFF0F4FC`.

Perintah verifikasi:

```
grep -rn "Color(0xFF\|Color(0x66\|fontSize:\|BorderRadius.circular\|EdgeInsets" lib/ --include="*.dart"
grep -rn "CelebrationPopup.show\|CelebrationBanner\|AudioPromptButton\|BubbleIconButton\|ChunkyCard\|ParentGate" lib/ --include="*.dart"
grep -rn "width: 260\|height: 52\|SingleChildScrollView\|Spacer()\|Expanded\|FittedBox" lib/presentation/screens --include="*.dart"
```

## Limitasi

- Verifikasi langsung: token, `diorama_stage`, `chunky_button`, `celebration_popup`, `bubble_icon_button`, `audio_prompt_button`, `guided_tracing 1-130`, `responsive_helper`. Sisanya mengandalkan grep + audit paralel statis.
- Run mobile/tablet belum dilakukan. Butuh `flutter analyze`, `flutter test`, `flutter run -d` + cek 375px dan 768px light mode.
- Line screen dari subagent wajib verifikasi manual sebelum eksekusi karena rentan geser.

## Rekomendasi urutan perbaikan

1. `diorama_stage elevation 0.08 -> 0.40`.
2. Threshold tracing 80% -> 70% atau revisi DS.
3. CTA `260x52` -> `double.infinity x 54 font 18` di counting + onboarding.
4. Default `buttonText 'Lanjut' -> 'Lanjut Latihan'`.
5. Bungkus `Text` prompt dengan `Expanded/FittedBox`, hilangkan padding ganda 32dp, tambah scroll blending.
6. Sentralisasi warna hardcoded ke `AppColors`, tambah `maxContentWidth` tablet.
7. Parent-gate langsung di dashboard + audit kontras + uji motorik 2-3 th.
