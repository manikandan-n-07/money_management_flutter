// lib/widgets/budget_progress_bar.dart
// Budget progress bar with animated fill and color states

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/currency_formatter.dart';

class BudgetProgressBar extends StatelessWidget {
  final double budget;
  final double spent;
  final String symbol;
  final bool showLabels;

  const BudgetProgressBar({
    super.key,
    required this.budget,
    required this.spent,
    this.symbol = '₹',
    this.showLabels = true,
  });

  double get _progress => budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0;

  Color get _progressColor {
    if (_progress >= 0.85) return AppColors.budgetDanger;
    if (_progress >= 0.60) return AppColors.budgetWarning;
    return AppColors.budgetSafe;
  }

  String get _statusText {
    if (_progress >= 0.85) return '⚠️ Over budget!';
    if (_progress >= 0.60) return '🔶 Spending high';
    return '✅ On track';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = (budget - spent).clamp(0.0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabels) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Budget',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _statusText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _progressColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        // Animated progress bar
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: _progress),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOut,
          builder: (context, value, _) {
            return Stack(
              children: [
                // Track
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: _progressColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Fill
                FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_progressColor, _progressColor.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: _progressColor.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (showLabels) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AmountLabel(
                  label: 'Spent',
                  amount: spent,
                  symbol: symbol,
                  color: _progressColor),
              _AmountLabel(
                  label: 'Remaining',
                  amount: remaining,
                  symbol: symbol,
                  color: AppColors.success,
                  alignEnd: true),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Budget: ${CurrencyFormatter.format(budget, symbol: symbol)} · ${(_progress * 100).toStringAsFixed(0)}% used',
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
        ],
      ],
    );
  }
}

class _AmountLabel extends StatelessWidget {
  final String label;
  final double amount;
  final String symbol;
  final Color color;
  final bool alignEnd;

  const _AmountLabel({
    required this.label,
    required this.amount,
    required this.symbol,
    required this.color,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          CurrencyFormatter.format(amount, symbol: symbol),
          style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 14),
        ),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
      ],
    );
  }
}
