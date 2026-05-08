import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Reusable UGO brand logo — "U" with a location pin on top.
/// [size] controls the bounding square.
/// [onDark] uses a white-background version (for placing on coloured backgrounds).
class UgoLogo extends StatelessWidget {
  final double size;
  final bool onDark;

  const UgoLogo({super.key, this.size = 80, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _UgoLogoPainter(onDark: onDark),
    );
  }
}

class _UgoLogoPainter extends CustomPainter {
  final bool onDark;
  const _UgoLogoPainter({required this.onDark});

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;

    // Background
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.215),
    );

    if (onDark) {
      canvas.drawRRect(bgRect, Paint()..color = Colors.white);
    } else {
      canvas.drawRRect(
        bgRect,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, w, h)),
      );
    }

    final fg = onDark ? const Color(0xFF1565C0) : Colors.white;
    final bg = onDark ? Colors.white : const Color(0xFF1565C0);
    final fgPaint = Paint()..color = fg;
    final bgPaint = Paint()..color = bg;

    // ── Location pin ──────────────────────────────────────────────────────────
    final pinCx = w * 0.5;
    final pinCy = h * 0.193;
    final pinR  = w * 0.080;

    // Bubble
    canvas.drawCircle(Offset(pinCx, pinCy), pinR, fgPaint);

    // Shoulder (smooth the bubble-to-tail transition)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(pinCx, h * 0.218),
        width: w * 0.113,
        height: h * 0.059,
      ),
      fgPaint,
    );

    // Tail
    final tail = Path()
      ..moveTo(pinCx - w * 0.041, h * 0.264)
      ..lineTo(pinCx,             h * 0.359)
      ..lineTo(pinCx + w * 0.041, h * 0.264)
      ..close();
    canvas.drawPath(tail, fgPaint);

    // Inner hole
    canvas.drawCircle(Offset(pinCx, h * 0.178), w * 0.029, bgPaint);

    // ── U letter ──────────────────────────────────────────────────────────────
    final uL     = w * 0.171;
    final uR     = w * 0.829;
    final stroke = w * 0.090;
    final uTop   = h * 0.396;
    final arcCy  = h * 0.674;
    final arcOR  = (uR - uL) / 2;
    final arcIR  = arcOR - stroke;
    final topRad = Radius.circular(stroke / 2);

    // Left bar (rounded top only)
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(uL, uTop, stroke, arcCy - uTop + stroke * 0.1),
        topLeft: topRad,
        topRight: topRad,
      ),
      fgPaint,
    );

    // Right bar (rounded top only)
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(uR - stroke, uTop, stroke, arcCy - uTop + stroke * 0.1),
        topLeft: topRad,
        topRight: topRad,
      ),
      fgPaint,
    );

    final arcCenter = Offset((uL + uR) / 2, arcCy);

    // Outer arc (bottom half, filled sector)
    canvas.drawArc(
      Rect.fromCircle(center: arcCenter, radius: arcOR),
      0, math.pi, true,
      fgPaint,
    );

    // Carve inner arc
    canvas.drawArc(
      Rect.fromCircle(center: arcCenter, radius: arcIR),
      0, math.pi, true,
      bgPaint,
    );

    // Fill inner U gap above arc
    canvas.drawRect(
      Rect.fromLTRB(uL + stroke, uTop, uR - stroke, arcCy),
      bgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _UgoLogoPainter old) => old.onDark != onDark;
}
