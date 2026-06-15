// lib/widgets/skeleton_loader.dart
// Shimmer skeleton loader widgets for loading states

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/constants/app_colors.dart';

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A4A) : const Color(0xFFE8E8F0),
      highlightColor: isDark ? const Color(0xFF3A3A5A) : const Color(0xFFF8F8FF),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A4A) : const Color(0xFFE8E8F0),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton for an expense card
class ExpenseCardSkeleton extends StatelessWidget {
  const ExpenseCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          SkeletonBox(width: 48, height: 48, borderRadius: 14),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 14, borderRadius: 4),
                SizedBox(height: 6),
                SkeletonBox(width: 120, height: 10, borderRadius: 4),
              ],
            ),
          ),
          SizedBox(width: 12),
          SkeletonBox(width: 70, height: 18, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Skeleton for a stat card
class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkCardBorder
              : AppColors.lightCardBorder,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 80, height: 10, borderRadius: 4),
          SizedBox(height: 8),
          SkeletonBox(width: 100, height: 22, borderRadius: 4),
          SizedBox(height: 4),
          SkeletonBox(width: 60, height: 8, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Full page skeleton loader
class PageSkeletonLoader extends StatelessWidget {
  const PageSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (_, __) => const ExpenseCardSkeleton(),
    );
  }
}
