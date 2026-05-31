/// SOS Button Widget — Large, animated, accessible emergency button
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safereach/config/theme.dart';

class SOSButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double size;
  final String semanticLabel;
  final bool isPulsing;
  final Alignment alignment;

  const SOSButton({
    super.key,
    required this.onPressed,
    this.size = 120,
    this.semanticLabel = 'Emergency SOS Button - tap to send alert',
    this.isPulsing = true,
    this.alignment = Alignment.center,
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _pressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.isPulsing) _pulseController.repeat(reverse: true);

    _pressController = AnimationController(duration: const Duration(milliseconds: 100), vsync: this);
    _pressAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(_pressController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: true,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _pressAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value * _pressAnimation.value,
            child: child,
          );
        },
        child: GestureDetector(
          onTapDown: (_) => _pressController.forward(),
          onTapUp: (_) {
            _pressController.reverse();
            HapticFeedback.heavyImpact();
            widget.onPressed();
          },
          onTapCancel: () => _pressController.reverse(),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF4444), Color(0xFFCC0000)],
              ),
              boxShadow: [
                BoxShadow(color: SafeReachTheme.sosRed.withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 4),
                BoxShadow(color: SafeReachTheme.sosRed.withValues(alpha: 0.2), blurRadius: 48, spreadRadius: 8),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.emergency, color: Colors.white, size: 36),
                  const SizedBox(height: 4),
                  Text('SOS', style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.size * 0.18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
