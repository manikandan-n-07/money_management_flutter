// lib/widgets/app_logo.dart
// Custom premium app logo rendered using Flutter Widgets & Canvas

import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool flatCorners;
  const AppLogo({super.key, this.size = 200, this.flatCorners = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = constraints.maxWidth / 200;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Base background container with gradient
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: flatCorners
                          ? null
                          : BorderRadius.circular(44 * scale),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1D9E75), Color(0xFF534AB7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                // Bar 1
                Positioned(
                  left: 30 * scale,
                  top: 120 * scale,
                  width: 28 * scale,
                  height: 50 * scale,
                  child: Opacity(
                    opacity: 0.55,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6 * scale),
                      ),
                    ),
                  ),
                ),
                // Bar 2
                Positioned(
                  left: 68 * scale,
                  top: 90 * scale,
                  width: 28 * scale,
                  height: 80 * scale,
                  child: Opacity(
                    opacity: 0.75,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6 * scale),
                      ),
                    ),
                  ),
                ),
                // Bar 3
                Positioned(
                  left: 106 * scale,
                  top: 55 * scale,
                  width: 28 * scale,
                  height: 115 * scale,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6 * scale),
                    ),
                  ),
                ),
                // Bar 4
                Positioned(
                  left: 144 * scale,
                  top: 75 * scale,
                  width: 28 * scale,
                  height: 95 * scale,
                  child: Opacity(
                    opacity: 0.85,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6 * scale),
                      ),
                    ),
                  ),
                ),
                // Checkmark Badge Circle
                Positioned(
                  left: 136 * scale,
                  top: 36 * scale,
                  width: 44 * scale,
                  height: 44 * scale,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAEEDA),
                      shape: BoxShape.circle,
                    ),
                    child: CustomPaint(
                      painter: _CheckmarkPainter(scale: scale),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double scale;
  _CheckmarkPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF854F0B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(12 * scale, 22 * scale);
    path.lineTo(20 * scale, 31 * scale);
    path.lineTo(34 * scale, 13 * scale);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
