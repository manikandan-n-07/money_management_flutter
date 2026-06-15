// lib/services/budget_service.dart
// Budget CRUD and progress calculation

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/budget_model.dart';
import '../core/constants/app_constants.dart';
import 'hive_service.dart';
import 'expense_service.dart';

class BudgetService {
  BudgetService._();
  static const _uuid = Uuid();

  static Box<BudgetModel> get _box => HiveService.budgetBox;

  // === CRUD ===

  static Future<BudgetModel> setMonthlyBudget({
    required double monthlyBudget,
    double savingsGoal = 0.0,
    int? month,
    int? year,
  }) async {
    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear = year ?? now.year;

    // Check if budget exists for this month
    final existing = getBudgetForMonth(targetMonth, targetYear);
    if (existing != null) {
      final updated = existing.copyWith(
        monthlyBudget: monthlyBudget,
        savingsGoal: savingsGoal,
      );
      await _box.put(updated.id, updated);
      return updated;
    }

    final budget = BudgetModel(
      id: _uuid.v4(),
      monthlyBudget: monthlyBudget,
      month: targetMonth,
      year: targetYear,
      savingsGoal: savingsGoal,
      createdAt: DateTime.now(),
    );
    await _box.put(budget.id, budget);
    return budget;
  }

  static BudgetModel? getBudgetForMonth(int month, int year) {
    try {
      return _box.values.firstWhere(
          (b) => b.month == month && b.year == year);
    } catch (_) {
      return null;
    }
  }

  static BudgetModel? getCurrentMonthBudget() {
    final now = DateTime.now();
    return getBudgetForMonth(now.month, now.year);
  }

  static Future<void> deleteBudget(String id) async {
    await _box.delete(id);
  }

  // === Progress ===

  /// Returns [0.0, 1.0] of how much of the budget has been spent this month
  static double getMonthlyProgress() {
    final budget = getCurrentMonthBudget();
    if (budget == null || budget.monthlyBudget <= 0) return 0;
    final spent = ExpenseService.getThisMonthTotal();
    return (spent / budget.monthlyBudget).clamp(0.0, 1.0);
  }

  static double getThisMonthSpent() => ExpenseService.getThisMonthTotal();

  static double getThisMonthRemaining() {
    final budget = getCurrentMonthBudget();
    if (budget == null) return 0;
    final spent = getThisMonthSpent();
    return (budget.monthlyBudget - spent).clamp(0.0, double.infinity);
  }

  /// Budget warning level: 'safe', 'warning', 'danger'
  static String getBudgetLevel() {
    final progress = getMonthlyProgress();
    if (progress >= AppConstants.budgetDangerPct) return 'danger';
    if (progress >= AppConstants.budgetWarnPct) return 'warning';
    return 'safe';
  }

  /// Daily spending rate for this month
  static double getDailySpendRate() {
    final now = DateTime.now();
    final spent = getThisMonthSpent();
    return spent / now.day;
  }

  static double getProjectedMonthTotal() {
    final now = DateTime.now();
    // Days in current month
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    return getDailySpendRate() * daysInMonth;
  }
}
