// lib/widgets/flowing_background_header.dart
// Premium animated background orbs that float smoothly in a continuous loop

import 'package:flutter/material.dart';

class FloatingOrb extends StatefulWidget {
  final double size;
  final Color color;
  final double opacity;
  final double startX;
  final double startY;
  final double dx;
  final double dy;
  final Duration duration;

  const FloatingOrb({
    super.key,
    required this.size,
    required this.color,
    required this.opacity,
    this.startX = 0,
    this.startY = 0,
    this.dx = 30,
    this.dy = 30,
    this.duration = const Duration(seconds: 8),
  });

  @override
  State<FloatingOrb> createState() => _FloatingOrbState();
}

class _FloatingOrbState extends State<FloatingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentX = widget.startX + (widget.dx * _animation.value);
        final currentY = widget.startY + (widget.dy * _animation.value);

        return Positioned(
          left: currentX,
          top: currentY,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: widget.opacity),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: widget.opacity * 1.6),
                  blurRadius: widget.size * 0.45,
                  spreadRadius: widget.size * 0.08,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
