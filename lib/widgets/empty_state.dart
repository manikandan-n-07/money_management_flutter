// lib/widgets/empty_state.dart
// Beautiful empty state widgets for empty lists

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated emoji container
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 44)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: Column(
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (action != null) ...[
                    const SizedBox(height: 24),
                    action!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pre-built empty states
class EmptyExpenses extends StatelessWidget {
  final VoidCallback? onAdd;
  const EmptyExpenses({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: '💸',
      title: 'No expenses yet',
      subtitle: 'Start tracking your spending by adding your first expense!',
      action: onAdd != null
          ? FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Expense'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          : null,
    );
  }
}

class EmptySplits extends StatelessWidget {
  final VoidCallback? onAdd;
  const EmptySplits({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: '🤝',
      title: 'No split expenses',
      subtitle: 'Split bills with friends or colleagues and track settlements.',
      action: onAdd != null
          ? FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.group_add_rounded),
              label: const Text('Split Expense'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          : null,
    );
  }
}

class EmptySearch extends StatelessWidget {
  final String query;
  const EmptySearch({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      emoji: '🔍',
      title: 'No results found',
      subtitle: 'No expenses match "$query". Try a different search term.',
    );
  }
}

class EmptyInsights extends StatelessWidget {
  const EmptyInsights({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      emoji: '🧠',
      title: 'Not enough data yet',
      subtitle:
          'Add more expenses over time to unlock smart insights about your spending habits.',
    );
  }
}
