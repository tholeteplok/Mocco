import 'package:flutter/material.dart';
import '../../../core/tokens/app_colors.dart';
import '../../../core/tokens/app_spacing.dart';
import '../../../core/tokens/app_typography.dart';
import '../../../core/utils/sound_player.dart';

/// Interactive Touch Tracing Canvas for Letters and Numbers (V0.8, V5, V10)
/// Features:
/// - Light template letter displayed in font Andika
/// - Chunky brush stroke (28dp width) with rounded caps
/// - Audio feedback during tracing
class TracingCanvas extends StatefulWidget {
  const TracingCanvas({
    super.key,
    required this.letter,
    this.strokeColor = AppColors.letterPrimary,
    this.templateColor = AppColors.letterTint,
    this.strokeWidth = 28.0,
    this.width = 240.0,
    this.height = 240.0,
    this.onStrokeCompleted,
  });

  final String letter;
  final Color strokeColor;
  final Color templateColor;
  final double strokeWidth;
  final double width;
  final double height;
  final VoidCallback? onStrokeCompleted;

  @override
  State<TracingCanvas> createState() => TracingCanvasState();
}

class TracingCanvasState extends State<TracingCanvas> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _currentStroke = [details.localPosition];
      _strokes.add(_currentStroke);
    });
    SoundPlayer.instance.playSquish();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentStroke.add(details.localPosition);
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    _currentStroke = [];
    if (_strokes.isNotEmpty && _strokes.first.length > 5) {
      widget.onStrokeCompleted?.call();
    }
  }

  void clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
    });
    SoundPlayer.instance.playPop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppSpacing.roundedLarge,
        border: Border.all(
          color: widget.strokeColor.withValues(alpha: 0.5),
          width: 3.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.letterBevel,
            offset: const Offset(0, AppSpacing.bevelNormal),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Letter Template Guide
          Center(
            child: Text(
              widget.letter,
              style: AppTypography.learningDisplay(
                fontSize: widget.height * 0.75,
                color: widget.templateColor,
              ),
            ),
          ),
          // Interactive Tracing Painter Layer
          GestureDetector(
            onPanStart: _handlePanStart,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            child: CustomPaint(
              size: Size(widget.width, widget.height),
              painter: _StrokePainter(
                strokes: _strokes,
                strokeColor: widget.strokeColor,
                strokeWidth: widget.strokeWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StrokePainter extends CustomPainter {
  const _StrokePainter({
    required this.strokes,
    required this.strokeColor,
    required this.strokeWidth,
  });

  final List<List<Offset>> strokes;
  final Color strokeColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor.withValues(alpha: 0.85)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke.first, strokeWidth / 2, paint..style = PaintingStyle.fill);
        paint.style = PaintingStyle.stroke;
      } else {
        final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
        for (int i = 1; i < stroke.length; i++) {
          path.lineTo(stroke[i].dx, stroke[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) => true;
}
