// lib/widgets/wave_header.dart
import 'package:flutter/material.dart';
import 'flowing_background_header.dart';

class WaveHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget? bottom;
  final double height;

  const WaveHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.bottom,
    this.height = 140,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipPath(
      clipper: _HeaderWaveClipper(),
      child: Container(
        height: height + MediaQuery.of(context).padding.top,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF14082E),
                    Color(0xFF0B1640),
                    Color(0xFF082218),
                  ]
                : const [
                    Color(0xFF5A54D4),
                    Color(0xFF7047B8),
                    Color(0xFF1DA882),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Floating orbs
            FloatingOrb(
              size: 100,
              color: Colors.white,
              opacity: isDark ? 0.05 : 0.08,
              startX: MediaQuery.of(context).size.width * 0.75,
              startY: -10,
              dx: -20,
              dy: 15,
              duration: const Duration(seconds: 8),
            ),
            FloatingOrb(
              size: 80,
              color: Colors.white,
              opacity: isDark ? 0.04 : 0.06,
              startX: -10,
              startY: 30,
              dx: 15,
              dy: -20,
              duration: const Duration(seconds: 7),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Title/Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                  height: 1.1,
                                ),
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  subtitle!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (action != null) action!,
                      ],
                    ),
                    if (bottom != null) ...[
                      const Spacer(),
                      bottom!,
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 24);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 12,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 24,
      size.width,
      size.height - 6,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_HeaderWaveClipper oldClipper) => false;
}
