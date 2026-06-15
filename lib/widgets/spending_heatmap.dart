// lib/widgets/spending_heatmap.dart
// GitHub-style spending heatmap for the statistics screen

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/currency_formatter.dart';

class SpendingHeatmap extends StatelessWidget {
  final Map<DateTime, double> data;
  final String symbol;

  const SpendingHeatmap({
    super.key,
    required this.data,
    this.symbol = '₹',
  });

  double get _maxAmount {
    if (data.isEmpty) return 1;
    return data.values.reduce((a, b) => a > b ? a : b);
  }

  Color _cellColor(double amount, bool isDark) {
    if (amount <= 0) {
      return isDark
          ? const Color(0xFF1E1E3A)
          : const Color(0xFFEEEEF8);
    }
    final intensity = (amount / _maxAmount).clamp(0.1, 1.0);
    return AppColors.primary.withValues(alpha: intensity);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();

    // Build 52 weeks (364 days) + today
    final startDate = now.subtract(const Duration(days: 364));

    // Group by week column
    final List<List<_DayCell>> weeks = [];
    List<_DayCell> currentWeek = [];

    // Pad start to Monday
    var cursor = startDate;
    while (cursor.weekday != DateTime.monday) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    while (cursor.isBefore(now.add(const Duration(days: 1)))) {
      final key = DateTime(cursor.year, cursor.month, cursor.day);
      final amount = data[key] ?? 0;
      currentWeek.add(_DayCell(date: key, amount: amount));

      if (cursor.weekday == DateTime.sunday || cursor == now) {
        weeks.add(List.from(currentWeek));
        currentWeek = [];
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    if (currentWeek.isNotEmpty) weeks.add(currentWeek);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month labels
              SizedBox(
                height: 16,
                child: Row(
                  children: weeks.map((week) {
                    if (week.isEmpty) return const SizedBox(width: 12);
                    final firstDay = week.first.date;
                    String label = '';
                    if (firstDay.day <= 7) {
                      label = DateFormat('MMM').format(firstDay);
                    }
                    return SizedBox(
                      width: 12,
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 8, color: Colors.grey),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 4),
              // Grid
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: weeks.map((week) {
                  return Column(
                    children: [
                      ...List.generate(7, (dayIndex) {
                        if (dayIndex >= week.length) {
                          return Container(
                            width: 10, height: 10,
                            margin: const EdgeInsets.all(1),
                          );
                        }
                        final cell = week[dayIndex];
                        return Tooltip(
                          message: cell.amount > 0
                              ? '${DateFormat('dd MMM').format(cell.date)}: ${CurrencyFormatter.format(cell.amount, symbol: symbol)}'
                              : DateFormat('dd MMM').format(cell.date),
                          child: Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: _cellColor(cell.amount, isDark),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('Less', style: TextStyle(fontSize: 9, color: Colors.grey)),
            const SizedBox(width: 4),
            ...List.generate(5, (i) {
              final opacity = 0.1 + (i * 0.2);
              return Container(
                width: 10, height: 10,
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: opacity),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
            const SizedBox(width: 4),
            const Text('More', style: TextStyle(fontSize: 9, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}

class _DayCell {
  final DateTime date;
  final double amount;
  const _DayCell({required this.date, required this.amount});
}
