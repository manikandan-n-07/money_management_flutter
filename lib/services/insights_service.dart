// lib/services/insights_service.dart
// Generates local smart insights from expense data (no AI/API)

import '../core/constants/app_constants.dart';
import '../core/utils/date_formatter.dart';
import 'expense_service.dart';

class Insight {
  final String title;
  final String description;
  final String emoji;
  final InsightType type;
  final double? value;

  const Insight({
    required this.title,
    required this.description,
    required this.emoji,
    this.type = InsightType.info,
    this.value,
  });
}

enum InsightType { positive, negative, warning, info }

class InsightsService {
  InsightsService._();

  /// Generate all insights
  static List<Insight> generateInsights() {
    final insights = <Insight>[];
    insights.addAll(_categoryInsights());
    insights.addAll(_spendingPatternInsights());
    insights.addAll(_placeInsights());
    insights.addAll(_weekdayInsights());
    return insights;
  }

  static List<Insight> _categoryInsights() {
    final thisMonth = ExpenseService.getCategoryTotalsThisMonth();
    if (thisMonth.isEmpty) return [];

    final insights = <Insight>[];

    // Compare with last month
    final now = DateTime.now();
    final lastMonthStart =
        DateFormatter.startOfMonth(DateTime(now.year, now.month - 1, 1));
    final lastMonthEnd = DateFormatter.endOfMonth(lastMonthStart);
    final lastMonthExpenses =
        ExpenseService.getExpensesInRange(lastMonthStart, lastMonthEnd);
    final lastMonthTotals = <String, double>{};
    for (final e in lastMonthExpenses) {
      lastMonthTotals[e.category] =
          (lastMonthTotals[e.category] ?? 0) + e.amount;
    }

    for (final entry in thisMonth.entries) {
      final catName = AppConstants.getCategoryById(entry.key).name;
      final thisAmt = entry.value;
      final lastAmt = lastMonthTotals[entry.key] ?? 0;

      if (lastAmt > 0) {
        final changePct = ((thisAmt - lastAmt) / lastAmt) * 100;
        if (changePct > 20) {
          insights.add(Insight(
            title: '$catName spending up',
            description:
                'You spent ${changePct.toStringAsFixed(0)}% more on $catName this month.',
            emoji: '📈',
            type: InsightType.warning,
            value: changePct,
          ));
        } else if (changePct < -10) {
          insights.add(Insight(
            title: '$catName spending reduced',
            description:
                '$catName expenses reduced by ${changePct.abs().toStringAsFixed(0)}% vs last month. Great job!',
            emoji: '📉',
            type: InsightType.positive,
            value: changePct,
          ));
        }
      }
    }

    // Top category
    if (thisMonth.isNotEmpty) {
      final top = thisMonth.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      final catName = AppConstants.getCategoryById(top.key).name;
      final totalThisMonth = thisMonth.values.fold(0.0, (a, b) => a + b);
      final pct = (top.value / totalThisMonth * 100).toStringAsFixed(0);
      insights.add(Insight(
        title: 'Top spending: $catName',
        description:
            '$catName is your biggest expense this month ($pct% of total).',
        emoji: AppConstants.getCategoryById(top.key).emoji,
        type: InsightType.info,
      ));
    }

    return insights;
  }

  static List<Insight> _spendingPatternInsights() {
    final insights = <Insight>[];
    final thisWeekExpenses = ExpenseService.getThisWeekExpenses();
    final lastWeekStart = DateTime.now().subtract(const Duration(days: 14));
    final lastWeekEnd = DateTime.now().subtract(const Duration(days: 7));
    final lastWeekExpenses =
        ExpenseService.getExpensesInRange(lastWeekStart, lastWeekEnd);

    final thisWeekTotal = ExpenseService.sumExpenses(thisWeekExpenses);
    final lastWeekTotal = ExpenseService.sumExpenses(lastWeekExpenses);

    if (lastWeekTotal > 0) {
      final change = ((thisWeekTotal - lastWeekTotal) / lastWeekTotal) * 100;
      if (change > 25) {
        insights.add(Insight(
          title: 'Weekly spending spike',
          description:
              'You\'ve spent ${change.toStringAsFixed(0)}% more this week compared to last week.',
          emoji: '⚠️',
          type: InsightType.warning,
          value: change,
        ));
      } else if (change < -15) {
        insights.add(Insight(
          title: 'Great savings this week!',
          description:
              'Your spending is ${change.abs().toStringAsFixed(0)}% lower than last week.',
          emoji: '🎉',
          type: InsightType.positive,
          value: change,
        ));
      }
    }

    // Daily average
    final now = DateTime.now();
    final dayOfMonth = now.day;
    if (dayOfMonth > 5) {
      final monthTotal = ExpenseService.getThisMonthTotal();
      final dailyAvg = monthTotal / dayOfMonth;
      insights.add(Insight(
        title: 'Daily average this month',
        description:
            'Your average daily spend this month is ₹${dailyAvg.toStringAsFixed(0)}.',
        emoji: '📊',
        type: InsightType.info,
        value: dailyAvg,
      ));
    }

    return insights;
  }

  static List<Insight> _placeInsights() {
    final insights = <Insight>[];
    final place = ExpenseService.getMostVisitedPlace();
    if (place != null && place.isNotEmpty) {
      insights.add(Insight(
        title: 'Most visited place',
        description:
            'You spend most frequently at "$place". Consider tracking if it\'s worth it!',
        emoji: '📍',
        type: InsightType.info,
      ));
    }
    return insights;
  }

  static List<Insight> _weekdayInsights() {
    final insights = <Insight>[];
    final expenses = ExpenseService.getThisMonthExpenses();
    if (expenses.length < 5) return insights;

    // Find highest spending day of week
    final Map<int, double> dayTotals = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    final Map<int, int> dayCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (final e in expenses) {
      final weekday = e.dateTime.weekday;
      dayTotals[weekday] = (dayTotals[weekday] ?? 0) + e.amount;
      dayCounts[weekday] = (dayCounts[weekday] ?? 0) + 1;
    }

    final topDay = dayTotals.entries
        .reduce((a, b) => a.value > b.value ? a : b);
    final dayNames = {
      1: 'Monday', 2: 'Tuesday', 3: 'Wednesday', 4: 'Thursday',
      5: 'Friday', 6: 'Saturday', 7: 'Sunday'
    };

    insights.add(Insight(
      title: 'Highest spending day',
      description:
          'You spend the most on ${dayNames[topDay.key]}s this month. Plan ahead for the weekend!',
      emoji: '📅',
      type: InsightType.info,
    ));

    return insights;
  }
}
