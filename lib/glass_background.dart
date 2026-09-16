import 'dart:ui';

import 'package:flutter/material.dart';

class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F8F1),

      child: Stack(
        children: [
          // ========================================================
          // SOFT ORGANIC SHAPES
          // ========================================================

          Positioned(
            top: -100,
            right: -80,
            child: _SoftCircle(
              size: 260,
              color: const Color(0xFFE4F0E3),
            ),
          ),

          Positioned(
            top: 280,
            left: -120,
            child: _SoftCircle(
              size: 240,
              color: const Color(0xFFEDF4E9),
            ),
          ),

          Positioned(
            bottom: -100,
            right: -80,
            child: _SoftCircle(
              size: 260,
              color: const Color(0xFFE5F0E2),
            ),
          ),

          // ========================================================
          // BLURRED LIGHT
          // ========================================================

          Positioned(
            top: 100,
            right: 30,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 35,
                sigmaY: 35,
              ),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEEDC)
                      .withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // ========================================================
          // CONTENT
          // ========================================================

          child,
        ],
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.55),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}