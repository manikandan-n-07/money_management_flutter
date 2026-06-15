// lib/features/insights/insights_screen.dart
// Smart locally-computed insights page

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/expense_provider.dart';
import '../../services/insights_service.dart';
import '../../widgets/empty_state.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(expenseNotifierProvider); // rebuild on expense changes
    final insights = InsightsService.generateInsights();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Insights'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: const Text('Local Only',
                  style: TextStyle(fontSize: 11, color: AppColors.secondary)),
              avatar: const Icon(Icons.offline_bolt_rounded,
                  size: 14, color: AppColors.secondary),
              backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
              side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3)),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
      body: insights.isEmpty
          ? const EmptyInsights()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: insights.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Based on your spending habits',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.brightness == Brightness.dark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    ),
                  );
                }
                final insight = insights[index - 1];
                return _InsightCard(insight: insight, isDark: isDark);
              },
            ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final Insight insight;
  final bool isDark;

  const _InsightCard({required this.insight, required this.isDark});

  Color get _typeColor {
    switch (insight.type) {
      case InsightType.positive: return AppColors.success;
      case InsightType.negative: return AppColors.error;
      case InsightType.warning: return AppColors.warning;
      case InsightType.info: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _typeColor.withValues(alpha: 0.25),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: _typeColor.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(insight.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        insight.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        insight.type.name.toUpperCase(),
                        style: TextStyle(
                          color: _typeColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
