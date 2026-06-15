// lib/services/hive_service.dart
// Initializes Hive and registers all type adapters

import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';
import '../models/split_member_model.dart';
import '../models/split_expense_model.dart';
import '../models/budget_model.dart';
import '../core/constants/app_constants.dart';

class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();
    await _openBoxes();
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ExpenseModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SplitMemberModelAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SplitStatusAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(PayerTypeAdapter());
    if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(SplitExpenseModelAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(BudgetModelAdapter());
  }

  static Future<void> _openBoxes() async {
    await Hive.openBox<ExpenseModel>(AppConstants.expenseBox);
    await Hive.openBox<SplitExpenseModel>(AppConstants.splitBox);
    await Hive.openBox<BudgetModel>(AppConstants.budgetBox);
  }

  /// Get open expense box
  static Box<ExpenseModel> get expenseBox =>
      Hive.box<ExpenseModel>(AppConstants.expenseBox);

  /// Get open split box
  static Box<SplitExpenseModel> get splitBox =>
      Hive.box<SplitExpenseModel>(AppConstants.splitBox);

  /// Get open budget box
  static Box<BudgetModel> get budgetBox =>
      Hive.box<BudgetModel>(AppConstants.budgetBox);

  /// Close all boxes (call on app dispose)
  static Future<void> close() async {
    await Hive.close();
  }

  /// Clear all data (for testing/reset)
  static Future<void> clearAll() async {
    await expenseBox.clear();
    await splitBox.clear();
    await budgetBox.clear();
  }
}
