import 'package:flutter/material.dart';

/// Custom Painter that renders a winding adventure trail with soft clay cobblestones
/// and grassy landscape contours.
class ClayWindingPathPainter extends CustomPainter {
  const ClayWindingPathPainter({
    required this.nodeCount,
    this.pathColor = const Color(0xFFE8DCB8), // Warm sandy cobblestone
    this.borderPathColor = const Color(0xFFC4B289),
  });

  final int nodeCount;
  final Color pathColor;
  final Color borderPathColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 0 || size.width <= 0) return;

    final borderPaint = Paint()
      ..color = borderPathColor.withValues(alpha: 0.7)
      ..strokeWidth = 24.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final pathPaint = Paint()
      ..color = pathColor
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final stepY = size.height / (nodeCount + 1);

    final path = Path();
    for (int i = 0; i < nodeCount; i++) {
      final y = stepY * (i + 1);
      final x = (i % 3 == 0)
          ? size.width * 0.25
          : (i % 3 == 1)
              ? size.width * 0.50
              : size.width * 0.75;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevY = stepY * i;
        final prevX = ((i - 1) % 3 == 0)
            ? size.width * 0.25
            : ((i - 1) % 3 == 1)
                ? size.width * 0.50
                : size.width * 0.75;

        final midY = (prevY + y) / 2;
        path.cubicTo(prevX, midY, x, midY, x, y);
      }
    }

    // Draw wide trail border & inner sandy fill
    canvas.drawPath(path, borderPaint);
    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant ClayWindingPathPainter oldDelegate) {
    return oldDelegate.nodeCount != nodeCount ||
        oldDelegate.pathColor != pathColor ||
        oldDelegate.borderPathColor != borderPathColor;
  }
}
