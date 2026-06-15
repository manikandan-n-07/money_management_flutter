// lib/services/expense_service.dart
// CRUD + query operations for expenses

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../core/utils/date_formatter.dart';
import 'hive_service.dart';

class ExpenseService {
  ExpenseService._();
  static const _uuid = Uuid();

  static Box<ExpenseModel> get _box => HiveService.expenseBox;

  // === CRUD ===

  /// Add a new expense
  static Future<ExpenseModel> addExpense({
    required double amount,
    required String category,
    required String place,
    String notes = '',
    required DateTime dateTime,
    List<String> tags = const [],
    String currency = '₹',
    String currencyCode = 'INR',
  }) async {
    final expense = ExpenseModel(
      id: _uuid.v4(),
      amount: amount,
      category: category,
      place: place,
      notes: notes,
      dateTime: dateTime,
      tags: tags,
      currency: currency,
      currencyCode: currencyCode,
    );
    await _box.put(expense.id, expense);
    return expense;
  }

  /// Update an existing expense
  static Future<void> updateExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense);
  }

  /// Delete an expense by ID
  static Future<void> deleteExpense(String id) async {
    await _box.delete(id);
  }

  /// Get all expenses sorted by date descending
  static List<ExpenseModel> getAllExpenses() {
    final expenses = _box.values.toList();
    expenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return expenses;
  }

  /// Get expense by ID
  static ExpenseModel? getExpense(String id) => _box.get(id);

  // === Queries ===

  /// Get today's expenses
  static List<ExpenseModel> getTodayExpenses() {
    return getAllExpenses()
        .where((e) => DateFormatter.isToday(e.dateTime))
        .toList();
  }

  /// Get this week's expenses
  static List<ExpenseModel> getThisWeekExpenses() {
    return getAllExpenses()
        .where((e) => DateFormatter.isThisWeek(e.dateTime))
        .toList();
  }

  /// Get this month's expenses
  static List<ExpenseModel> getThisMonthExpenses() {
    return getAllExpenses()
        .where((e) => DateFormatter.isThisMonth(e.dateTime))
        .toList();
  }

  /// Get this year's expenses
  static List<ExpenseModel> getThisYearExpenses() {
    return getAllExpenses()
        .where((e) => DateFormatter.isThisYear(e.dateTime))
        .toList();
  }

  /// Get expenses within a date range
  static List<ExpenseModel> getExpensesInRange(DateTime start, DateTime end) {
    return getAllExpenses()
        .where((e) =>
            e.dateTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
            e.dateTime.isBefore(end.add(const Duration(seconds: 1))))
        .toList();
  }

  /// Get expenses by category
  static List<ExpenseModel> getByCategory(String categoryId) {
    return getAllExpenses()
        .where((e) => e.category == categoryId)
        .toList();
  }

  // === Aggregates ===

  /// Sum of expenses in a list
  static double sumExpenses(List<ExpenseModel> expenses) {
    return expenses.fold(0, (s, e) => s + e.amount);
  }

  /// Total today
  static double getTodayTotal() => sumExpenses(getTodayExpenses());

  /// Total this week
  static double getThisWeekTotal() => sumExpenses(getThisWeekExpenses());

  /// Total this month
  static double getThisMonthTotal() => sumExpenses(getThisMonthExpenses());

  /// Total this year
  static double getThisYearTotal() => sumExpenses(getThisYearExpenses());

  /// Grand total
  static double getGrandTotal() => sumExpenses(getAllExpenses());

  /// Spending per category (this month)
  static Map<String, double> getCategoryTotalsThisMonth() {
    final expenses = getThisMonthExpenses();
    final Map<String, double> totals = {};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  /// Spending per day for last N days
  static Map<String, double> getDailyTotals({int days = 7}) {
    final now = DateTime.now();
    final Map<String, double> dailyMap = {};
    for (int i = days - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.year}-${day.month.toString().padLeft(2,'0')}-${day.day.toString().padLeft(2,'0')}';
      dailyMap[key] = 0;
    }
    final expenses = getExpensesInRange(
      now.subtract(Duration(days: days - 1)),
      now,
    );
    for (final e in expenses) {
      final key =
          '${e.dateTime.year}-${e.dateTime.month.toString().padLeft(2,'0')}-${e.dateTime.day.toString().padLeft(2,'0')}';
      if (dailyMap.containsKey(key)) {
        dailyMap[key] = (dailyMap[key] ?? 0) + e.amount;
      }
    }
    return dailyMap;
  }

  /// Spending per month for last 12 months
  static Map<String, double> getMonthlyTotals({int months = 12}) {
    final now = DateTime.now();
    final Map<String, double> monthMap = {};
    for (int i = months - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final key = '${date.year}-${date.month.toString().padLeft(2,'0')}';
      monthMap[key] = 0;
    }
    final start = DateTime(now.year, now.month - months + 1, 1);
    final expenses = getExpensesInRange(start, now);
    for (final e in expenses) {
      final key =
          '${e.dateTime.year}-${e.dateTime.month.toString().padLeft(2,'0')}';
      if (monthMap.containsKey(key)) {
        monthMap[key] = (monthMap[key] ?? 0) + e.amount;
      }
    }
    return monthMap;
  }

  /// Spending heatmap data — returns day -> amount for last 365 days
  static Map<DateTime, double> getHeatmapData() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 364));
    final expenses = getExpensesInRange(start, now);
    final Map<DateTime, double> heatmap = {};
    for (final e in expenses) {
      final day = DateFormatter.startOfDay(e.dateTime);
      heatmap[day] = (heatmap[day] ?? 0) + e.amount;
    }
    return heatmap;
  }

  /// Most visited place
  static String? getMostVisitedPlace() {
    final expenses = getAllExpenses().where((e) => e.place.isNotEmpty).toList();
    if (expenses.isEmpty) return null;
    final Map<String, int> placeCounts = {};
    for (final e in expenses) {
      placeCounts[e.place] = (placeCounts[e.place] ?? 0) + 1;
    }
    return placeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Search expenses by query
  static List<ExpenseModel> search(String query) {
    if (query.isEmpty) return getAllExpenses();
    final q = query.toLowerCase();
    return getAllExpenses().where((e) {
      return e.place.toLowerCase().contains(q) ||
          e.notes.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q) ||
          e.amount.toString().contains(q) ||
          e.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }
}
