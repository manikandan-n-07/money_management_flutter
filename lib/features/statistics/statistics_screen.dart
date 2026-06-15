// lib/features/statistics/statistics_screen.dart
// Professional analytics: line chart, bar chart, pie chart, heatmap, top categories

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/expense_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/spending_heatmap.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(expenseNotifierProvider);
    final symbol = ref.watch(currencySymbolProvider);
    final allExpenses = ref.watch(allExpensesProvider);

    if (allExpenses.isEmpty) {
      return const Scaffold(
        appBar: null,
        body: EmptyInsights(),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ChartCard(
            title: 'Weekly Spending',
            subtitle: 'Last 7 days',
            child: _WeeklyLineChart(symbol: symbol),
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: 'Monthly Spending',
            subtitle: 'Last 12 months',
            child: _MonthlyBarChart(symbol: symbol),
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: 'Category Distribution',
            subtitle: 'This month',
            child: _CategoryPieChart(symbol: symbol),
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: 'Top Categories',
            subtitle: 'By spending this month',
            child: _TopCategoriesList(symbol: symbol),
          ),
          const SizedBox(height: 16),
          _ChartCard(
            title: 'Spending Heatmap',
            subtitle: 'Last 365 days',
            child: SpendingHeatmap(
              data: ExpenseService.getHeatmapData(),
              symbol: symbol,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          Text(subtitle, style: theme.textTheme.bodySmall),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

// === Weekly Line Chart ===
class _WeeklyLineChart extends StatelessWidget {
  final String symbol;
  const _WeeklyLineChart({required this.symbol});

  @override
  Widget build(BuildContext context) {
    final data = ExpenseService.getDailyTotals(days: 7);
    final entries = data.entries.toList();
    final maxY = entries.isEmpty
        ? 100.0
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    if (maxY == 0) {
      return const Center(
          child: Text('No spending this week',
              style: TextStyle(color: Colors.grey)));
    }

    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY * 1.2,
          gridData: FlGridData(
            show: true,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (val) => FlLine(
              color: AppColors.primary.withValues(alpha: 0.08),
              strokeWidth: 1,
            ),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (val, meta) => Text(
                  CurrencyFormatter.formatCompact(val, symbol: symbol),
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  final key = entries[idx].key;
                  final parts = key.split('-');
                  final day = DateTime(
                      int.parse(parts[0]),
                      int.parse(parts[1]),
                      int.parse(parts[2]));
                  return Text(
                    DateFormat('E').format(day),
                    style:
                        const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeColor: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) {
                return LineTooltipItem(
                  CurrencyFormatter.format(s.y, symbol: symbol),
                  const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// === Monthly Bar Chart ===
class _MonthlyBarChart extends StatelessWidget {
  final String symbol;
  const _MonthlyBarChart({required this.symbol});

  @override
  Widget build(BuildContext context) {
    final data = ExpenseService.getMonthlyTotals(months: 12);
    final entries = data.entries.toList();
    final maxY = entries.isEmpty
        ? 100.0
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    if (maxY == 0) {
      return const Center(
          child: Text('No spending data',
              style: TextStyle(color: Colors.grey)));
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (val) => FlLine(
              color: AppColors.primary.withValues(alpha: 0.08),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (val, meta) => Text(
                  CurrencyFormatter.formatCompact(val, symbol: symbol),
                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  final key = entries[idx].key;
                  final parts = key.split('-');
                  final month =
                      DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
                  return Text(
                    DateFormat('MMM').format(month),
                    style:
                        const TextStyle(fontSize: 9, color: Colors.grey),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: entries.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 12,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                CurrencyFormatter.format(rod.toY, symbol: symbol),
                const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// === Category Pie Chart ===
class _CategoryPieChart extends StatefulWidget {
  final String symbol;
  const _CategoryPieChart({required this.symbol});

  @override
  State<_CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<_CategoryPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final categoryTotals = ExpenseService.getCategoryTotalsThisMonth();
    if (categoryTotals.isEmpty) {
      return const Center(
          child: Text('No spending this month',
              style: TextStyle(color: Colors.grey)));
    }

    final total = categoryTotals.values.fold(0.0, (s, v) => s + v);
    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sections = sorted.asMap().entries.map((entry) {
      final i = entry.key;
      final e = entry.value;
      final cat = AppConstants.getCategoryById(e.key);
      final pct = e.value / total * 100;
      final isTouched = i == _touchedIndex;

      return PieChartSectionData(
        value: e.value,
        title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
        color: AppColors.chartPalette[i % AppColors.chartPalette.length],
        radius: isTouched ? 70 : 58,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
        badgeWidget: isTouched ? null : Text(cat.emoji, style: const TextStyle(fontSize: 12)),
        badgePositionPercentageOffset: 0.9,
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = response
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Legend
              SizedBox(
                width: 130,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sorted.take(7).toList().asMap().entries.map((entry) {
                    final i = entry.key;
                    final e = entry.value;
                    final cat = AppConstants.getCategoryById(e.key);
                    final pct = (e.value / total * 100).toStringAsFixed(0);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.chartPalette[
                                  i % AppColors.chartPalette.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${cat.name} $pct%',
                              style: const TextStyle(fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// === Top Categories List ===
class _TopCategoriesList extends StatelessWidget {
  final String symbol;
  const _TopCategoriesList({required this.symbol});

  @override
  Widget build(BuildContext context) {
    final categoryTotals = ExpenseService.getCategoryTotalsThisMonth();
    if (categoryTotals.isEmpty) {
      return const Text('No data', style: TextStyle(color: Colors.grey));
    }

    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = sorted.first.value;

    return Column(
      children: sorted.take(6).toList().asMap().entries.map((entry) {
        final e = entry.value;
        final cat = AppConstants.getCategoryById(e.key);
        final progress = e.value / maxVal;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: cat.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(cat.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                            Text(
                              CurrencyFormatter.format(e.value,
                                  symbol: symbol),
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: cat.color),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor:
                                cat.color.withValues(alpha: 0.1),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(cat.color),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
