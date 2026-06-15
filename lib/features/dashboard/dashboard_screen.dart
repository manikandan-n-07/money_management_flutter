// lib/features/dashboard/dashboard_screen.dart
// Powerful dashboard with 6 stat cards, spending overview

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/split_provider.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symbol = ref.watch(currencySymbolProvider);
    final todayTotal = ref.watch(todayTotalProvider);
    final weekTotal = ref.watch(thisWeekTotalProvider);
    final monthTotal = ref.watch(thisMonthTotalProvider);
    final grandTotal = ref.watch(grandTotalProvider);
    final splitTotal = ref.watch(totalSplitAmountProvider);
    final pendingTotal = ref.watch(totalPendingAmountProvider);

    final now = DateTime.now();

    // This year total
    final allExpenses = ref.watch(allExpensesProvider);
    final yearTotal = allExpenses
        .where((e) => DateFormatter.isThisYear(e.dateTime))
        .fold(0.0, (s, e) => s + e.amount);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                DateFormatter.formatMonthYear(now),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(expenseNotifierProvider);
          ref.invalidate(splitNotifierProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section: My Spending
              Text('My Spending',
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  StatCard(
                    label: "Today's Spending",
                    amount: todayTotal,
                    symbol: symbol,
                    color: AppColors.accent,
                    icon: Icons.today_rounded,
                    subtitle: 'Total for today',
                  ),
                  StatCard(
                    label: 'This Week',
                    amount: weekTotal,
                    symbol: symbol,
                    color: AppColors.primary,
                    icon: Icons.date_range_rounded,
                    subtitle: '7-day total',
                  ),
                  StatCard(
                    label: 'This Month',
                    amount: monthTotal,
                    symbol: symbol,
                    color: AppColors.secondary,
                    icon: Icons.calendar_month_rounded,
                    subtitle: DateFormatter.formatMonthYear(now),
                  ),
                  StatCard(
                    label: 'This Year',
                    amount: yearTotal,
                    symbol: symbol,
                    color: AppColors.accentOrange,
                    icon: Icons.calendar_today_rounded,
                    subtitle: '${now.year}',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text('All Time',
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  StatCard(
                    label: 'Total Expenses',
                    amount: grandTotal,
                    symbol: symbol,
                    color: AppColors.accentBlue,
                    icon: Icons.account_balance_wallet_rounded,
                    subtitle: '${allExpenses.length} transactions',
                  ),
                  StatCard(
                    label: 'Total Split',
                    amount: splitTotal,
                    symbol: symbol,
                    color: AppColors.catGifts,
                    icon: Icons.group_rounded,
                    subtitle: '${ref.watch(allSplitsProvider).length} splits',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Split pending
              if (pendingTotal > 0)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF9F43)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          color: Colors.white, size: 32),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pending Split Amount',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            Text(
                              '$symbol${pendingTotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.white70, size: 16),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Quick stats summary
              _QuickStatsSummary(
                  expenses: allExpenses.length,
                  splits: ref.watch(allSplitsProvider).length,
                  avgDaily: allExpenses.isEmpty
                      ? 0
                      : grandTotal /
                          (DateTime.now()
                                  .difference(
                                      allExpenses.isNotEmpty
                                          ? allExpenses.last.dateTime
                                          : DateTime.now())
                                  .inDays +
                              1),
                  symbol: symbol),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStatsSummary extends StatelessWidget {
  final int expenses;
  final int splits;
  final double avgDaily;
  final String symbol;

  const _QuickStatsSummary({
    required this.expenses,
    required this.splits,
    required this.avgDaily,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Summary',
              style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: MiniStatChip(
                  label: 'Expenses',
                  value: '$expenses',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MiniStatChip(
                  label: 'Splits',
                  value: '$splits',
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MiniStatChip(
                  label: 'Daily Avg',
                  value: '$symbol${avgDaily.toStringAsFixed(0)}',
                  color: AppColors.accentOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
