// lib/services/backup_service.dart
// JSON backup and restore for all app data

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense_model.dart';
import '../models/split_expense_model.dart';
import '../models/budget_model.dart';
import 'hive_service.dart';
import 'expense_service.dart';
import 'split_service.dart';

class BackupService {
  BackupService._();

  /// Export all data as JSON and share
  static Future<String?> exportBackup() async {
    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'expenses': ExpenseService.getAllExpenses()
          .map((e) => e.toJson())
          .toList(),
      'splits': SplitService.getAllSplits()
          .map((s) => s.toJson())
          .toList(),
      'budgets': HiveService.budgetBox.values
          .map((b) => b.toJson())
          .toList(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .substring(0, 19);
    final file = File('${dir.path}/cashier_backup_$timestamp.json');
    await file.writeAsString(jsonStr);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Cashier Backup - $timestamp',
    );

    return file.path;
  }

  /// Import backup from a JSON file
  static Future<BackupResult> importBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return BackupResult(
            success: false, message: 'No file selected');
      }

      final file = File(result.files.first.path!);
      final jsonStr = await file.readAsString();
      final Map<String, dynamic> data = json.decode(jsonStr);

      // Validate format
      if (!data.containsKey('expenses') || !data.containsKey('splits')) {
        return BackupResult(
            success: false, message: 'Invalid backup file format');
      }

      // Clear existing data
      await HiveService.clearAll();

      // Restore expenses
      int expenseCount = 0;
      final expenses = data['expenses'] as List;
      for (final e in expenses) {
        final expense =
            ExpenseModel.fromJson(e as Map<String, dynamic>);
        await HiveService.expenseBox.put(expense.id, expense);
        expenseCount++;
      }

      // Restore splits
      int splitCount = 0;
      final splits = data['splits'] as List;
      for (final s in splits) {
        final split = SplitExpenseModel.fromJson(s as Map<String, dynamic>);
        await HiveService.splitBox.put(split.id, split);
        splitCount++;
      }

      // Restore budgets
      int budgetCount = 0;
      if (data.containsKey('budgets')) {
        final budgets = data['budgets'] as List;
        for (final b in budgets) {
          final budget = BudgetModel.fromJson(b as Map<String, dynamic>);
          await HiveService.budgetBox.put(budget.id, budget);
          budgetCount++;
        }
      }

      return BackupResult(
        success: true,
        message:
            'Restored $expenseCount expenses, $splitCount splits, $budgetCount budgets.',
        expenseCount: expenseCount,
        splitCount: splitCount,
        budgetCount: budgetCount,
      );
    } catch (e) {
      return BackupResult(
          success: false, message: 'Failed to import: ${e.toString()}');
    }
  }
}

class BackupResult {
  final bool success;
  final String message;
  final int expenseCount;
  final int splitCount;
  final int budgetCount;

  BackupResult({
    required this.success,
    required this.message,
    this.expenseCount = 0,
    this.splitCount = 0,
    this.budgetCount = 0,
  });
}
