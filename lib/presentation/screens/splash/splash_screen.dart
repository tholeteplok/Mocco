import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/sound_player.dart';
import '../../widgets/mascot/mascot_widget.dart';
import '../../widgets/text/clay_brand_text.dart';
import '../map/adventure_map_screen.dart';

/// Layar pembuka (Splash Screen) ramah anak.
///
/// Menggunakan tipografi [Fredoka] yang selaras dengan teks buku pada icon launcher,
/// maskot Mocco pose membaca ([MascotMood.reading]), dan warna latar warm cream
/// yang identik dengan [AdventureMapScreen] sehingga transisinya bebas flicker (kedip).
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.displayDuration = const Duration(milliseconds: 2800),
    this.nextScreen,
    this.enableAudio = true,
  });

  /// Durasi tampilan splash sebelum otomatis berpindah.
  final Duration displayDuration;

  /// Layar tujuan setelah splash selesai (default: [AdventureMapScreen]).
  final Widget? nextScreen;

  /// Apakah memutar audio pop ramah anak saat masuk.
  final bool enableAudio;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    if (widget.enableAudio) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          SoundPlayer.instance.playIntro();
        }
      });
    }

    _navigationTimer = Timer(widget.displayDuration, _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    final target = widget.nextScreen ?? const AdventureMapScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) => target,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Maskot Mocco sedang membaca buku biru (identik dengan icon launcher)
                  const MascotWidget(
                    mood: MascotMood.reading,
                    size: 140.0,
                    animate: true,
                    showShadow: true,
                  ),
                  const SizedBox(height: AppSpacing.space24),

                  // Teks Merek "Mocco" dengan font Fredoka & clay bevel 3D
                  const ClayBrandText(
                    fontSize: 52.0,
                  ),
                  const SizedBox(height: AppSpacing.space8),

                  // Tagline edukatif ramah anak
                  Text(
                    'Belajar Membaca & Berhitung',
                    style: AppTypography.uiBody(
                      fontSize: 16.0,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
