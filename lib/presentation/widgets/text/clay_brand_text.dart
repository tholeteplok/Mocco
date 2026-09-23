import 'package:flutter/material.dart';

import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_typography.dart';

/// Komponen teks merek "Mocco" dengan efek claymorphism 3D.
///
/// Menggunakan font [Fredoka] yang selaras 100% dengan teks pada
/// sampul buku di icon launcher aplikasi.
class ClayBrandText extends StatelessWidget {
  const ClayBrandText({
    super.key,
    this.text = 'Mocco',
    this.fontSize = 48.0,
    this.primaryColor = AppColors.brandOrange,
    this.bevelColor = AppColors.brandOrangeDark,
    this.showAccentLeaf = true,
  });

  final String text;
  final double fontSize;
  final Color primaryColor;
  final Color bevelColor;
  final bool showAccentLeaf;

  @override
  Widget build(BuildContext context) {
    final baseStyle = AppTypography.brandTitle(
      fontSize: fontSize,
      color: primaryColor,
    ).copyWith(
      shadows: [
        // Lapisan 1: Clay extrusion bevel (tebal solid ke bawah)
        Shadow(
          color: bevelColor,
          offset: Offset(0, fontSize * 0.08),
          blurRadius: 0,
        ),
        // Lapisan 2: Ambient contact shadow (bayangan lembut mengambang)
        Shadow(
          color: bevelColor.withValues(alpha: 0.30),
          offset: Offset(0, fontSize * 0.14),
          blurRadius: fontSize * 0.10,
        ),
      ],
    );

    return Semantics(
      label: text,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: baseStyle,
      ),
    );
  }
}
