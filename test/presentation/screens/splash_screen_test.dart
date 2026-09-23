import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocco/presentation/screens/splash/splash_screen.dart';
import 'package:mocco/presentation/widgets/mascot/mascot_widget.dart';
import 'package:mocco/presentation/widgets/text/clay_brand_text.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    testWidgets('renders reading mascot, Fredoka clay brand text, and tagline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(
            displayDuration: Duration(seconds: 10), // long enough to stay during test
            enableAudio: false,
          ),
        ),
      );

      // Selesaikan inisialisasi controller animasi
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verifikasi komponen maskot dengan mood reading (sesuai icon launcher)
      final mascotFinder = find.byWidgetPredicate(
        (widget) => widget is MascotWidget && widget.mood == MascotMood.reading,
      );
      expect(mascotFinder, findsOneWidget);

      // Verifikasi teks merek "Mocco" (ClayBrandText)
      expect(find.byType(ClayBrandText), findsOneWidget);
      expect(find.text('Mocco'), findsOneWidget);

      // Verifikasi tagline
      expect(find.text('Belajar Membaca & Berhitung'), findsOneWidget);
    });

    testWidgets('auto-transitions to nextScreen when displayDuration expires', (tester) async {
      final mockNextScreenKey = UniqueKey();

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            displayDuration: const Duration(milliseconds: 500),
            enableAudio: false,
            nextScreen: Scaffold(
              key: mockNextScreenKey,
              body: const Text('Target Peta Petualangan'),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Target Peta Petualangan'), findsNothing);

      // Majukan waktu melewati durasi splash dan durasi transisi fade
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Verifikasi bahwa layar tujuan berhasil ditampilkan
      expect(find.text('Target Peta Petualangan'), findsOneWidget);
      expect(find.byKey(mockNextScreenKey), findsOneWidget);
    });
  });
}
