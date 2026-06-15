// lib/providers/budget_provider.dart
// Riverpod providers for budget state

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';

class BudgetNotifier extends StateNotifier<BudgetModel?> {
  BudgetNotifier() : super(BudgetService.getCurrentMonthBudget());

  void refresh() {
    state = BudgetService.getCurrentMonthBudget();
  }

  Future<void> setBudget({
    required double monthlyBudget,
    double savingsGoal = 0.0,
  }) async {
    await BudgetService.setMonthlyBudget(
      monthlyBudget: monthlyBudget,
      savingsGoal: savingsGoal,
    );
    refresh();
  }

  Future<void> deleteBudget(String id) async {
    await BudgetService.deleteBudget(id);
    refresh();
  }
}

final budgetNotifierProvider =
    StateNotifierProvider<BudgetNotifier, BudgetModel?>((ref) {
  return BudgetNotifier();
});

final currentBudgetProvider = Provider<BudgetModel?>((ref) {
  return ref.watch(budgetNotifierProvider);
});

final budgetProgressProvider = Provider<double>((ref) {
  ref.watch(budgetNotifierProvider);
  return BudgetService.getMonthlyProgress();
});

final budgetLevelProvider = Provider<String>((ref) {
  ref.watch(budgetNotifierProvider);
  return BudgetService.getBudgetLevel();
});

final thisMonthSpentProvider = Provider<double>((ref) {
  ref.watch(budgetNotifierProvider);
  return BudgetService.getThisMonthSpent();
});

final thisMonthRemainingProvider = Provider<double>((ref) {
  ref.watch(budgetNotifierProvider);
  return BudgetService.getThisMonthRemaining();
});
