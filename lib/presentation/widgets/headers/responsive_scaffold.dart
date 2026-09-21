import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/utils/responsive_helper.dart';
import 'chunky_header.dart';

/// Adaptive Scaffold for Mocco
/// Automatically provides Warm Cream background and adapts padding between Mobile and Tablet.
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.header,
    this.bottomBar,
  });

  final Widget body;
  final ChunkyHeader? header;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.value(
      context,
      mobile: AppSpacing.space16,
      tablet: AppSpacing.space32,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: header,
      bottomNavigationBar: bottomBar,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: body,
        ),
      ),
    );
  }
}
