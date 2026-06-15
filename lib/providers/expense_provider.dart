import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';
import '../services/notification_service.dart';
import '../core/utils/date_formatter.dart';

// === Notifier ===

class ExpenseNotifier extends StateNotifier<List<ExpenseModel>> {
  ExpenseNotifier() : super(ExpenseService.getAllExpenses());

  void refresh() {
    state = ExpenseService.getAllExpenses();
  }

  Future<void> _triggerComparisonNotification(String currency) async {
    final expenses = state;
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final todayTotal = expenses
        .where((e) => DateFormatter.isSameDay(e.dateTime, today))
        .fold(0.0, (s, e) => s + e.amount);

    final yesterdayTotal = expenses
        .where((e) => DateFormatter.isSameDay(e.dateTime, yesterday))
        .fold(0.0, (s, e) => s + e.amount);

    await NotificationService.showDailyComparison(todayTotal, yesterdayTotal, currency);
  }

  Future<void> addExpense({
    required double amount,
    required String category,
    required String place,
    String notes = '',
    required DateTime dateTime,
    List<String> tags = const [],
    String currency = '₹',
    String currencyCode = 'INR',
  }) async {
    await ExpenseService.addExpense(
      amount: amount,
      category: category,
      place: place,
      notes: notes,
      dateTime: dateTime,
      tags: tags,
      currency: currency,
      currencyCode: currencyCode,
    );
    refresh();
    await _triggerComparisonNotification(currency);
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await ExpenseService.updateExpense(expense);
    refresh();
    await _triggerComparisonNotification(expense.currency);
  }

  Future<void> deleteExpense(String id) async {
    final expense = state.firstWhere((e) => e.id == id);
    await ExpenseService.deleteExpense(id);
    refresh();
    await _triggerComparisonNotification(expense.currency);
  }

  // Undo delete — re-add an expense
  Future<void> undoDelete(ExpenseModel expense) async {
    await ExpenseService.updateExpense(expense);
    refresh();
    await _triggerComparisonNotification(expense.currency);
  }
}

// === Providers ===

final expenseNotifierProvider =
    StateNotifierProvider<ExpenseNotifier, List<ExpenseModel>>((ref) {
  return ExpenseNotifier();
});

/// All expenses sorted by date desc
final allExpensesProvider = Provider<List<ExpenseModel>>((ref) {
  return ref.watch(expenseNotifierProvider);
});

/// Today's expenses
final todayExpensesProvider = Provider<List<ExpenseModel>>((ref) {
  return ref.watch(expenseNotifierProvider)
      .where((e) => _isToday(e.dateTime))
      .toList();
});

/// This week's expenses
final thisWeekExpensesProvider = Provider<List<ExpenseModel>>((ref) {
  return ref.watch(expenseNotifierProvider)
      .where((e) => _isThisWeek(e.dateTime))
      .toList();
});

/// This month's expenses
final thisMonthExpensesProvider = Provider<List<ExpenseModel>>((ref) {
  return ref.watch(expenseNotifierProvider)
      .where((e) => _isThisMonth(e.dateTime))
      .toList();
});

/// Today's total
final todayTotalProvider = Provider<double>((ref) {
  final expenses = ref.watch(todayExpensesProvider);
  return expenses.fold(0.0, (s, e) => s + e.amount);
});

/// This week's total
final thisWeekTotalProvider = Provider<double>((ref) {
  final expenses = ref.watch(thisWeekExpensesProvider);
  return expenses.fold(0.0, (s, e) => s + e.amount);
});

/// This month's total
final thisMonthTotalProvider = Provider<double>((ref) {
  final expenses = ref.watch(thisMonthExpensesProvider);
  return expenses.fold(0.0, (s, e) => s + e.amount);
});

/// Grand total
final grandTotalProvider = Provider<double>((ref) {
  final expenses = ref.watch(allExpensesProvider);
  return expenses.fold(0.0, (s, e) => s + e.amount);
});

/// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered expenses from search
final filteredExpensesProvider = Provider<List<ExpenseModel>>((ref) {
  final expenses = ref.watch(allExpensesProvider);
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return expenses;
  final q = query.toLowerCase();
  return expenses.where((e) {
    return e.place.toLowerCase().contains(q) ||
        e.notes.toLowerCase().contains(q) ||
        e.category.toLowerCase().contains(q) ||
        e.amount.toString().contains(q) ||
        e.tags.any((t) => t.toLowerCase().contains(q));
  }).toList();
});

/// Date filter state: 'all', 'today', 'week', 'month', 'year', 'custom'
final dateFilterProvider = StateProvider<String>((ref) => 'all');

/// Custom range
final customRangeProvider = StateProvider<DateRange?>((ref) => null);

class DateRange {
  final DateTime start;
  final DateTime end;
  const DateRange(this.start, this.end);
}

// Helper functions
bool _isToday(DateTime dt) {
  final now = DateTime.now();
  return dt.year == now.year && dt.month == now.month && dt.day == now.day;
}

bool _isThisWeek(DateTime dt) {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  return dt.isAfter(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)
      .subtract(const Duration(seconds: 1)));
}

bool _isThisMonth(DateTime dt) {
  final now = DateTime.now();
  return dt.year == now.year && dt.month == now.month;
}
