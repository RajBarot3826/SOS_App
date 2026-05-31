/// Countdown Timer Widget — Circular animated countdown with sound/vibration/flash
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safereach/config/theme.dart';

class CountdownTimerWidget extends StatelessWidget {
  final int secondsRemaining;
  final int totalSeconds;
  final double size;
  final bool showCancel;
  final VoidCallback? onCancel;

  const CountdownTimerWidget({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
    this.size = 200,
    this.showCancel = true,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? secondsRemaining / totalSeconds : 0.0;

    return Semantics(
      label: 'Countdown: $secondsRemaining seconds remaining. Tap cancel to stop.',
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _CountdownPainter(progress: progress),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$secondsRemaining',
                      style: TextStyle(
                        fontSize: size * 0.35,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'seconds',
                      style: TextStyle(
                        fontSize: size * 0.08,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showCancel && onCancel != null) ...[
            const SizedBox(height: 32),
            Semantics(
              label: 'Cancel SOS alert',
              button: true,
              child: SizedBox(
                width: size * 0.8,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onCancel?.call();
                  },
                  icon: const Icon(Icons.close, size: 24),
                  label: const Text('CANCEL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CountdownPainter extends CustomPainter {
  final double progress;

  _CountdownPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Progress arc
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      Paint()
        ..color = SafeReachTheme.sosRed
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );

    // Glow effect
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      Paint()
        ..color = SafeReachTheme.sosRed.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  @override
  bool shouldRepaint(covariant _CountdownPainter old) => old.progress != progress;
}
