// lib/widgets/premium_app_bar.dart
// Shared premium glassmorphic app bar — used across all main screens

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../features/notifications/notification_settings_screen.dart';
import 'flowing_background_header.dart';

class PremiumSliverAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String emoji;
  final Widget? action;
  final double expandedHeight;
  final List<Color>? lightColors;
  final List<Color>? darkColors;

  const PremiumSliverAppBar({
    super.key,
    required this.title,
    required this.emoji,
    this.subtitle,
    this.action,
    this.expandedHeight = 150,
    this.lightColors,
    this.darkColors,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradLight = lightColors ??
        const [Color(0xFF4842B0), Color(0xFF5A3896), Color(0xFF178768)];
    final gradDark = darkColors ??
        const [Color(0xFF2A1B54), Color(0xFF1F2B5B), Color(0xFF163E30)];

    return SliverAppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Always light icons on our gradient header backgrounds
        statusBarBrightness: Brightness.dark,
      ),
      expandedHeight: expandedHeight,
      pinned: false,
      floating: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: ClipPath(
          clipper: _SmallWaveClipper(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark ? gradDark : gradLight,
              ),
            ),
            child: Stack(
              children: [
                // Decorative animated orbs
                FloatingOrb(
                  size: 130,
                  color: Colors.white,
                  opacity: isDark ? 0.02 : 0.04,
                  startX: MediaQuery.of(context).size.width * 0.7,
                  startY: -20,
                  dx: -25,
                  dy: 20,
                  duration: const Duration(seconds: 10),
                ),
                FloatingOrb(
                  size: 100,
                  color: Colors.white,
                  opacity: isDark ? 0.02 : 0.03,
                  startX: -20,
                  startY: 50,
                  dx: 20,
                  dy: -25,
                  duration: const Duration(seconds: 8),
                ),

                // Content
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Back button if can pop
                        if (Navigator.canPop(context)) ...[
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
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
                          const SizedBox(width: 12),
                        ],

                        // Emoji badge
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Center(
                            child:
                                Text(emoji, style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title + subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
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
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Optional action + notification bell
                        if (action != null) ...[action!, const SizedBox(width: 8)],
                        _GlassBtn(
                          icon: Icons.notifications_outlined,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const NotificationSettingsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Small wave clipper (less dramatic than home) ──────────────────────────────
class _SmallWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 24);
    path.quadraticBezierTo(
      size.width * 0.3, size.height,
      size.width * 0.6, size.height - 18,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height - 30,
      size.width, size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_SmallWaveClipper old) => false;
}

// ── Glass button ──────────────────────────────────────────────────────────────
class _GlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ── Action button helper (green/add) ─────────────────────────────────────────
class PremiumActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const PremiumActionButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
