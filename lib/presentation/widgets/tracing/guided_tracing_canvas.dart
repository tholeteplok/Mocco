import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/tokens/app_colors.dart';
import '../../../core/utils/sound_player.dart';
import '../../../domain/services/number_strokes.dart';

/// Interactive Guided Tracing Canvas (V2.2 - Firm Motoric Proximity Calibration)
///
/// Features:
/// - Flowing marching dashes showing writing direction
/// - Pulsing green start point with stroke order numbers (1, 2, ...)
/// - Animated demo pencil tracing the path
/// - Real-time cute pencil cursor tracking the child's touch
/// - Proximity Path Coverage (Tolerance 15dp, Per-Stroke 78%, Total 80%)
/// - Sequential Stroke Guard (Stroke s activates when stroke s-1 reaches 60%)
/// - Gamified visual progress bar and completion badge
/// - Audio squish on touch & success chime on threshold
class GuidedTracingCanvas extends StatefulWidget {
  const GuidedTracingCanvas({
    super.key,
    required this.char,
    this.strokeColor = AppColors.numberPrimary,
    this.size = 290.0,
    this.autoPlayDemo = true,
    this.onProgressChanged,
    this.onCompleted,
  });

  final String char;
  final Color strokeColor;
  final double size;
  final bool autoPlayDemo;
  final ValueChanged<double>? onProgressChanged;
  final VoidCallback? onCompleted;

  @override
  State<GuidedTracingCanvas> createState() => GuidedTracingCanvasState();
}

/// Centralized calibration parameters for guided tracing motoric tolerance
abstract final class TracingCalibration {
  /// Maximum deviation radius (in dp) from the guide path.
  /// Calibrated to 20.0dp to comfortably accommodate preschool toddlers' micro-jitters
  /// while still enforcing stroke discipline along the target character.
  static const double toleranceRadius = 20.0;

  /// Distance (in dp) between discrete checkpoint dots along guide strokes.
  /// Tightened from 8.0dp to 6.0dp for smoother, more precise continuity tracking.
  static const double stepSize = 6.0;

  /// Minimum coverage ratio required for an individual stroke to count as complete.
  /// Raised from 58% to 78% so the child must trace nearly the entire path.
  static const double perStrokeThreshold = 0.78;

  /// Minimum total coverage ratio required across all strokes for victory.
  /// Raised from 65% to 80%.
  static const double totalProgressThreshold = 0.80;

  /// Minimum progress required on preceding stroke(s) before a subsequent stroke
  /// can accept touch points (anti-scribble guard).
  static const double strokeActivationThreshold = 0.60;
}

class GuidedTracingCanvasState extends State<GuidedTracingCanvas>
    with TickerProviderStateMixin {
  final List<List<Offset>> _userStrokes = [];
  List<Offset>? _currentStroke;

  late final AnimationController _flowController;
  late final AnimationController _demoController;
  bool _isDemoPlaying = false;

  // ── Proximity Path Validation State (Per-Stroke Engine) ───────────
  List<List<Offset>> _strokeCheckpoints = [];
  final List<Set<int>> _coveredPerStroke = [];
  bool _isCompleted = false;

  double get progress {
    int total = 0;
    int covered = 0;
    for (int s = 0; s < _strokeCheckpoints.length; s++) {
      total += _strokeCheckpoints[s].length;
      if (s < _coveredPerStroke.length) {
        covered += _coveredPerStroke[s].length;
      }
    }
    return total == 0 ? 1.0 : (covered / total);
  }

  bool isStrokeCompleted(int strokeIndex) {
    if (strokeIndex >= _strokeCheckpoints.length || _strokeCheckpoints[strokeIndex].isEmpty) {
      return true;
    }
    final covered = strokeIndex < _coveredPerStroke.length
        ? _coveredPerStroke[strokeIndex].length
        : 0;
    return (covered / _strokeCheckpoints[strokeIndex].length) >= TracingCalibration.perStrokeThreshold;
  }

  bool get areAllStrokesCompleted {
    if (_strokeCheckpoints.isEmpty) return true;
    for (int s = 0; s < _strokeCheckpoints.length; s++) {
      if (!isStrokeCompleted(s)) return false;
    }
    return progress >= TracingCalibration.totalProgressThreshold;
  }

  bool get isCompleted => _isCompleted;

  @override
  void initState() {
    super.initState();
    _initCheckpoints();

    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _demoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _demoController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _isDemoPlaying = false);
      }
    });

    if (widget.autoPlayDemo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) playDemo();
        });
      });
    }
  }

  @override
  void didUpdateWidget(covariant GuidedTracingCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.char != widget.char || oldWidget.size != widget.size) {
      _initCheckpoints();
      _userStrokes.clear();
      _currentStroke = null;
    }
  }

  void _initCheckpoints() {
    final guidePaths = NumberStrokes.forChar(widget.char);
    _strokeCheckpoints = _generateCheckpoints(guidePaths, widget.size);
    _coveredPerStroke.clear();
    for (int s = 0; s < _strokeCheckpoints.length; s++) {
      _coveredPerStroke.add(<int>{});
    }
    _isCompleted = false;
  }

  /// Menghasilkan titik-titik acuan diskrit per stroke setiap ~6 pixel
  static List<List<Offset>> _generateCheckpoints(
    List<List<List<double>>>? guidePaths,
    double size,
  ) {
    if (guidePaths == null || guidePaths.isEmpty) return const [];
    final scaleX = size / 100.0;
    final scaleY = size / 100.0;
    final result = <List<Offset>>[];
    const stepSize = TracingCalibration.stepSize;

    for (final stroke in guidePaths) {
      if (stroke.isEmpty) continue;
      final strokePts = <Offset>[];
      if (stroke.length == 1) {
        strokePts.add(Offset(stroke[0][0] * scaleX, stroke[0][1] * scaleY));
        result.add(strokePts);
        continue;
      }
      for (int i = 0; i < stroke.length - 1; i++) {
        final p0 = Offset(stroke[i][0] * scaleX, stroke[i][1] * scaleY);
        final p1 = Offset(stroke[i + 1][0] * scaleX, stroke[i + 1][1] * scaleY);
        final segLen = (p1 - p0).distance;
        if (segLen <= 0) continue;

        final steps = (segLen / stepSize).ceil();
        for (int s = 0; s < steps; s++) {
          final t = s / steps;
          strokePts.add(Offset.lerp(p0, p1, t)!);
        }
      }
      final last = stroke.last;
      strokePts.add(Offset(last[0] * scaleX, last[1] * scaleY));
      result.add(strokePts);
    }
    return result;
  }

  /// Memeriksa apakah stroke [strokeIndex] diizinkan menerima sentuhan.
  /// Stroke berikutnya hanya aktif setelah stroke sebelumnya mencapai progres minimal (Sequential Guard).
  bool _canStrokeAcceptTouch(int strokeIndex) {
    if (strokeIndex == 0) return true;
    for (int prev = 0; prev < strokeIndex; prev++) {
      final prevTotal = _strokeCheckpoints[prev].length;
      if (prevTotal == 0) continue;
      final prevCovered = prev < _coveredPerStroke.length ? _coveredPerStroke[prev].length : 0;
      if ((prevCovered / prevTotal) < TracingCalibration.strokeActivationThreshold) {
        return false;
      }
    }
    return true;
  }

  /// Cek kedekatan sentuhan jari anak ke titik-titik panduan per stroke (radius 15dp)
  void _checkProximity(Offset touchPos) {
    if (_strokeCheckpoints.isEmpty) return;

    const toleranceRadius = TracingCalibration.toleranceRadius;
    const toleranceRadiusSq = toleranceRadius * toleranceRadius;
    bool newlyAdded = false;

    for (int s = 0; s < _strokeCheckpoints.length; s++) {
      // Sequential Stroke Guard: Stroke s baru aktif jika stroke sebelumnya >= 60%
      if (!_canStrokeAcceptTouch(s)) continue;

      final pts = _strokeCheckpoints[s];
      final covered = _coveredPerStroke[s];
      for (int i = 0; i < pts.length; i++) {
        if (covered.contains(i)) continue;
        final d2 = (touchPos - pts[i]).distanceSquared;
        if (d2 <= toleranceRadiusSq) {
          covered.add(i);
          newlyAdded = true;
        }
      }
    }

    if (newlyAdded) {
      final currentProgress = progress;
      widget.onProgressChanged?.call(currentProgress);

      // Karakter multi-stroke: SELURUH stroke wajib selesai (misal garis miring & vertikal angka 4)
      if (!_isCompleted && areAllStrokesCompleted) {
        setState(() => _isCompleted = true);
        SoundPlayer.instance.playSuccess();
        widget.onCompleted?.call();
      } else {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _flowController.dispose();
    _demoController.dispose();
    super.dispose();
  }

  void playDemo() {
    _demoController.reset();
    setState(() => _isDemoPlaying = true);
    SoundPlayer.instance.playSquish();
    _demoController.forward();
  }

  void stopDemo() {
    if (_isDemoPlaying) {
      _demoController.stop();
      setState(() => _isDemoPlaying = false);
    }
  }

  void clear() {
    stopDemo();
    setState(() {
      _userStrokes.clear();
      _currentStroke = null;
      for (final s in _coveredPerStroke) {
        s.clear();
      }
      _isCompleted = false;
    });
    widget.onProgressChanged?.call(0.0);
    SoundPlayer.instance.playPop();
  }

  bool get hasDrawn => _userStrokes.isNotEmpty && _userStrokes.first.length > 5;
  bool get hasUserStrokes => _userStrokes.isNotEmpty || (_currentStroke != null && _currentStroke!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final strokes = NumberStrokes.forChar(widget.char);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Soft Organic Backdrop Stage (Bebas Kontainer Kartu Kaku — Konsep Gajah Dribbble)
            Container(
              width: widget.size * 0.96,
              height: widget.size * 0.96,
              decoration: BoxDecoration(
                color: (_isCompleted ? AppColors.brandMintDark : widget.strokeColor)
                    .withValues(alpha: 0.10),
                borderRadius: BorderRadius.all(
                  Radius.elliptical(widget.size * 0.48, widget.size * 0.48),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isCompleted ? AppColors.brandMintDark : widget.strokeColor)
                        .withValues(alpha: 0.08),
                    blurRadius: 42,
                    spreadRadius: 14,
                  ),
                ],
              ),
            ),

            // Area Kanvas Interaktif dengan Ukuran Eksplisit
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (d) {
                  stopDemo();
                  setState(() {
                    _currentStroke = [d.localPosition];
                    _userStrokes.add(_currentStroke!);
                  });
                  _checkProximity(d.localPosition);
                  widget.onProgressChanged?.call(progress);
                  SoundPlayer.instance.playSquish();
                },
                onPanUpdate: (d) {
                  setState(() => _currentStroke?.add(d.localPosition));
                  _checkProximity(d.localPosition);
                },
                onPanEnd: (_) {
                  setState(() => _currentStroke = null);
                },
                child: AnimatedBuilder(
                  animation: Listenable.merge([_flowController, _demoController]),
                  builder: (context, _) {
                    return CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _TracingCanvasPainter(
                        char: widget.char,
                        guidePaths: strokes,
                        userStrokes: _userStrokes,
                        currentStroke: _currentStroke,
                        guideColor: widget.strokeColor.withValues(alpha: 0.25),
                        strokeColor: _isCompleted
                            ? AppColors.brandMintDark
                            : widget.strokeColor,
                        flowProgress: _flowController.value,
                        isDemoPlaying: _isDemoPlaying,
                        demoProgress: _demoController.value,
                        completedStrokes: List.generate(
                          _strokeCheckpoints.length,
                          isStrokeCompleted,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Lencana selesai di sudut panggung
            if (_isCompleted)
              Positioned(
                top: 8,
                right: 8,
                child: AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.brandMintDark,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandMintDark.withValues(alpha: 0.35),
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '✓',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Hebat!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 16),

        // Visual Progress Meter (Umpan balik dopamin motorik real-time)
        Container(
          width: widget.size * 0.75,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.disabledMuted,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (_isCompleted ? 1.0 : progress).clamp(0.0, 1.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: _isCompleted ? AppColors.brandMintDark : widget.strokeColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TracingCanvasPainter extends CustomPainter {
  const _TracingCanvasPainter({
    required this.char,
    required this.guidePaths,
    required this.userStrokes,
    required this.currentStroke,
    required this.guideColor,
    required this.strokeColor,
    required this.flowProgress,
    required this.isDemoPlaying,
    required this.demoProgress,
    this.completedStrokes = const [],
  });

  final String char;
  final List<List<List<double>>>? guidePaths;
  final List<List<Offset>> userStrokes;
  final List<Offset>? currentStroke;
  final Color guideColor;
  final Color strokeColor;
  final double flowProgress;
  final bool isDemoPlaying;
  final double demoProgress;
  final List<bool> completedStrokes;

  @override
  void paint(Canvas canvas, Size size) {
    const canvasSize = 100.0;
    final scaleX = size.width / canvasSize;
    final scaleY = size.height / canvasSize;

    // 1. Bayangan huruf/angka samar di latar belakang (skala adaptif untuk angka 2 digit seperti 10)
    final textPainter = TextPainter(
      text: TextSpan(
        text: char,
        style: TextStyle(
          fontSize: char.length > 1 ? size.height * 0.58 : size.height * 0.80,
          fontWeight: FontWeight.w900,
          color: guideColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    // 2. Garis panduan putus-putus mengalir
    if (guidePaths != null && guidePaths!.isNotEmpty) {
      final dashPaint = Paint()
        ..color = const Color(0xFFE5A93C)
        ..strokeWidth = 9.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      const dashLen = 7.0;
      const gapLen = 9.0;
      const period = dashLen + gapLen;

      final allSegments = <_TracingSegment>[];
      double grandTotal = 0.0;

      for (int s = 0; s < guidePaths!.length; s++) {
        final stroke = guidePaths![s];
        if (stroke.length < 2) continue;

        final pts = stroke
            .map((p) => Offset(p[0] * scaleX, p[1] * scaleY))
            .toList();

        final cumLengths = <double>[0.0];
        for (int i = 1; i < pts.length; i++) {
          final len = (pts[i] - pts[i - 1]).distance;
          cumLengths.add(cumLengths.last + len);

          allSegments.add(_TracingSegment(
            start: pts[i - 1],
            end: pts[i],
            length: len,
            cumulativeStart: grandTotal,
            strokeIndex: s,
          ));
          grandTotal += len;
        }

        final strokeTotalLen = cumLengths.last;
        if (strokeTotalLen > 0) {
          final patternOffset = (period - (flowProgress * period)) % period;
          double d = patternOffset;

          while (d < strokeTotalLen) {
            final dEnd = math.min(d + dashLen, strokeTotalLen);
            final pStart = _interpolateOnStroke(pts, cumLengths, d);
            final pEnd = _interpolateOnStroke(pts, cumLengths, dEnd);
            if (pStart != null && pEnd != null) {
              canvas.drawLine(pStart, pEnd, dashPaint);
            }
            d += period;
          }
        }

        // Titik mulai stroke & indikator status stroke
        final startPt = pts.first;
        final isDone = s < completedStrokes.length && completedStrokes[s];
        final isActive = !isDone &&
            (s == 0 || (s > 0 && s - 1 < completedStrokes.length && completedStrokes[s - 1]));

        if (isDone) {
          // Stroke selesai: centang hijau ✓
          canvas.drawCircle(
            startPt,
            10.0,
            Paint()..color = AppColors.tracingPathSuccess,
          );
          final checkPainter = TextPainter(
            text: const TextSpan(
              text: '✓',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          checkPainter.paint(
            canvas,
            Offset(startPt.dx - checkPainter.width / 2, startPt.dy - checkPainter.height / 2),
          );
        } else if (isActive) {
          // Stroke aktif yang harus ditarik anak: berdenyut hijau
          final pulseR = 10.0 + 3.0 * math.sin(flowProgress * 2 * math.pi);
          canvas.drawCircle(
            startPt,
            pulseR + 4,
            Paint()..color = AppColors.tracingPathSuccess.withValues(alpha: 0.3),
          );
          canvas.drawCircle(
            startPt,
            9.5,
            Paint()..color = AppColors.tracingPathSuccess,
          );
          final numPainter = TextPainter(
            text: TextSpan(
              text: '${s + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          numPainter.paint(
            canvas,
            Offset(startPt.dx - numPainter.width / 2, startPt.dy - numPainter.height / 2),
          );
        } else {
          // Stroke berikutnya: biru lembut
          canvas.drawCircle(
            startPt,
            8.5,
            Paint()..color = AppColors.tracingPath,
          );
          final numPainter = TextPainter(
            text: TextSpan(
              text: '${s + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          numPainter.paint(
            canvas,
            Offset(startPt.dx - numPainter.width / 2, startPt.dy - numPainter.height / 2),
          );
        }
      }

      // 3. Animasi pensil demo
      if (isDemoPlaying && grandTotal > 0) {
        final activeDist = demoProgress * grandTotal;

        final demoInkPaint = Paint()
          ..color = AppColors.tracingPath
          ..strokeWidth = 12.0
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;

        for (final seg in allSegments) {
          if (activeDist <= seg.cumulativeStart) break;

          final segEndDist = seg.cumulativeStart + seg.length;
          if (activeDist >= segEndDist) {
            canvas.drawLine(seg.start, seg.end, demoInkPaint);
          } else {
            final subRatio = (activeDist - seg.cumulativeStart) / seg.length;
            final subEnd = Offset.lerp(seg.start, seg.end, subRatio)!;
            canvas.drawLine(seg.start, subEnd, demoInkPaint);
            break;
          }
        }

        final sample = _samplePositionAndAngle(allSegments, activeDist);
        if (sample != null) {
          final demoPencil = TextPainter(
            text: const TextSpan(text: '✏️', style: TextStyle(fontSize: 34)),
            textDirection: TextDirection.ltr,
          )..layout();

          canvas.save();
          canvas.translate(sample.position.dx, sample.position.dy);
          canvas.rotate(sample.angle - 0.5 + 0.08 * math.sin(demoProgress * 30));
          demoPencil.paint(canvas, const Offset(6, -18));
          canvas.restore();
        }
      }
    }

    // 4. Goresan jari anak
    final userPaint = Paint()
      ..color = strokeColor.withValues(alpha: 0.9)
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final s in userStrokes) {
      if (s.length < 2) continue;
      final path = Path()..moveTo(s.first.dx, s.first.dy);
      for (int i = 1; i < s.length; i++) {
        path.lineTo(s[i].dx, s[i].dy);
      }
      canvas.drawPath(path, userPaint);
    }

    if (currentStroke != null && currentStroke!.length > 1) {
      final path = Path()..moveTo(currentStroke!.first.dx, currentStroke!.first.dy);
      for (int i = 1; i < currentStroke!.length; i++) {
        path.lineTo(currentStroke![i].dx, currentStroke![i].dy);
      }
      canvas.drawPath(path, userPaint);
    }

    // 5. Kursor pensil mengikuti jari anak
    if (!isDemoPlaying && currentStroke != null && currentStroke!.isNotEmpty) {
      final tip = currentStroke!.last;
      final touchPencil = TextPainter(
        text: const TextSpan(text: '✏️', style: TextStyle(fontSize: 30)),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(tip.dx, tip.dy);
      canvas.rotate(-0.45);
      touchPencil.paint(canvas, const Offset(8, -14));
      canvas.restore();
    }
  }

  static Offset? _interpolateOnStroke(
    List<Offset> pts,
    List<double> cumLengths,
    double targetDist,
  ) {
    if (pts.isEmpty) return null;
    if (targetDist <= 0) return pts.first;
    if (targetDist >= cumLengths.last) return pts.last;

    for (int i = 1; i < pts.length; i++) {
      if (targetDist <= cumLengths[i]) {
        final segStartDist = cumLengths[i - 1];
        final segLen = cumLengths[i] - segStartDist;
        if (segLen <= 0) return pts[i];
        final t = (targetDist - segStartDist) / segLen;
        return Offset.lerp(pts[i - 1], pts[i], t);
      }
    }
    return pts.last;
  }

  static _TracingSample? _samplePositionAndAngle(
    List<_TracingSegment> segments,
    double distance,
  ) {
    if (segments.isEmpty) return null;
    if (distance <= 0) {
      final first = segments.first;
      final angle = math.atan2(first.end.dy - first.start.dy, first.end.dx - first.start.dx);
      return _TracingSample(position: first.start, angle: angle);
    }
    for (final s in segments) {
      if (distance <= s.cumulativeStart + s.length) {
        final ratio = (distance - s.cumulativeStart) / s.length;
        final pos = Offset.lerp(s.start, s.end, ratio)!;
        final angle = math.atan2(s.end.dy - s.start.dy, s.end.dx - s.start.dx);
        return _TracingSample(position: pos, angle: angle);
      }
    }
    final last = segments.last;
    final angle = math.atan2(last.end.dy - last.start.dy, last.end.dx - last.start.dx);
    return _TracingSample(position: last.end, angle: angle);
  }

  @override
  bool shouldRepaint(covariant _TracingCanvasPainter old) => true;
}

class _TracingSegment {
  const _TracingSegment({
    required this.start,
    required this.end,
    required this.length,
    required this.cumulativeStart,
    required this.strokeIndex,
  });

  final Offset start;
  final Offset end;
  final double length;
  final double cumulativeStart;
  final int strokeIndex;
}

class _TracingSample {
  const _TracingSample({required this.position, required this.angle});

  final Offset position;
  final double angle;
}
