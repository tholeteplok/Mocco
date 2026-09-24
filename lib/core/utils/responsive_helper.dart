import 'package:flutter/material.dart';

/// Helper to handle adaptive layouts between Mobile (Portrait) and Tablet (Landscape).
abstract final class ResponsiveHelper {
  static const double tabletBreakpoint = 600.0;
  static const double maxContentWidth = 600.0;

  static bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.sizeOf(context).shortestSide;
    return shortestSide >= tabletBreakpoint;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  /// Returns value based on screen format
  static T value<T>(
    BuildContext context, {
    required T mobile,
    required T tablet,
  }) {
    return isTablet(context) ? tablet : mobile;
  }

  /// Wraps content in a centered ConstrainedBox with maxContentWidth for tablet views.
  static Widget constrainMaxWidth({
    required BuildContext context,
    required Widget child,
    double maxWidth = maxContentWidth,
  }) {
    if (!isTablet(context)) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
