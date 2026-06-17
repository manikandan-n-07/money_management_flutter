// lib/widgets/floating_banner_overlay.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../providers/banner_provider.dart';

class FloatingBannerOverlay extends ConsumerWidget {
  const FloatingBannerOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banner = ref.watch(bannerNotifierProvider);
    if (banner == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      left: 16,
      right: 16,
      bottom: MediaQuery.of(context).padding.bottom + 148, // Sits safely above the Speed Dial FAB
      child: Dismissible(
        key: ValueKey('${banner.timestamp.millisecondsSinceEpoch}_horizontal'),
        direction: DismissDirection.horizontal,
        onDismissed: (_) {
          ref.read(bannerNotifierProvider.notifier).dismiss();
        },
        child: Dismissible(
          key: ValueKey('${banner.timestamp.millisecondsSinceEpoch}_vertical'),
          direction: DismissDirection.vertical,
          onDismissed: (_) {
            ref.read(bannerNotifierProvider.notifier).dismiss();
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xE51E1E2E) : const Color(0xE5FFFFFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2C2C3E)
                    : Colors.grey.withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          banner.message,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (banner.actionLabel != null && banner.onAction != null) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            banner.onAction!();
                            ref.read(bannerNotifierProvider.notifier).dismiss();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: isDark ? const Color(0xFFB19FFB) : AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          child: Text(
                            banner.actionLabel!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
