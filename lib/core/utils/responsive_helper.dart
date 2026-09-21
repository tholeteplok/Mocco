import 'package:flutter/material.dart';

/// Helper to handle adaptive layouts between Mobile (Portrait) and Tablet (Landscape).
abstract final class ResponsiveHelper {
  static const double tabletBreakpoint = 600.0;

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
}
