// lib/features/expenses/expense_list_screen.dart
// Grouped expense list with date headers, swipe actions, undo delete

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/expense_card.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';
import '../splits/add_split_screen.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen>
    with SingleTickerProviderStateMixin {
  String _dateFilter = 'all';
  Timer? _timer;
  bool _fabExpanded = false;
  late AnimationController _fabCtrl;
  late Animation<double> _fabAnim;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
    _fabCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _fabAnim = CurvedAnimation(parent: _fabCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fabCtrl.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _fabExpanded = !_fabExpanded;
      if (_fabExpanded) {
        _fabCtrl.forward();
      } else {
        _fabCtrl.reverse();
      }
    });
  }

  List<ExpenseModel> _applyFilter(List<ExpenseModel> expenses) {
    switch (_dateFilter) {
      case 'today':
        return expenses
            .where((e) => DateFormatter.isToday(e.dateTime))
            .toList();
      case 'week':
        return expenses
            .where((e) => DateFormatter.isThisWeek(e.dateTime))
            .toList();
      case 'month':
        return expenses
            .where((e) => DateFormatter.isThisMonth(e.dateTime))
            .toList();
      case 'year':
        return expenses
            .where((e) => DateFormatter.isThisYear(e.dateTime))
            .toList();
      default:
        return expenses;
    }
  }

  /// Group expenses by day
  Map<String, List<ExpenseModel>> _groupByDay(List<ExpenseModel> expenses) {
    final Map<String, List<ExpenseModel>> grouped = {};
    for (final e in expenses) {
      final key = DateFormatter.groupHeader(e.dateTime);
      grouped.putIfAbsent(key, () => []).add(e);
    }
    return grouped;
  }

  Future<void> _deleteWithUndo(ExpenseModel expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Expense?'),
        content: Text('Are you sure you want to permanently delete "${expense.place.isNotEmpty ? expense.place : 'this expense'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(expenseNotifierProvider.notifier).deleteExpense(expense.id);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Expense deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                ref.read(expenseNotifierProvider.notifier).undoDelete(expense);
              },
            ),
            duration: AppConstants.undoDeleteDuration,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allExpenses = ref.watch(allExpensesProvider);
    final filtered = _applyFilter(allExpenses);
    final grouped = _groupByDay(filtered);
    final symbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Expenses'),
            const SizedBox(height: 2),
            Text(
              DateFormat('dd MMMM yyyy, hh:mm a').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _FilterBar(
            selected: _dateFilter,
            onChanged: (f) => setState(() => _dateFilter = f),
          ),
        ),
      ),
      body: filtered.isEmpty
          ? EmptyExpenses(
              onAdd: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
              ),
            )
          : ListView.builder(
              itemCount: grouped.keys.length,
              padding: const EdgeInsets.only(bottom: 80),
              itemBuilder: (context, groupIndex) {
                final dateKey = grouped.keys.elementAt(groupIndex);
                final dayExpenses = grouped[dateKey]!;
                final dayTotal = dayExpenses.fold(0.0, (s, e) => s + e.amount);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date group header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateKey,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                          ),
                          Text(
                            '$symbol${dayTotal.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Expense cards
                    ...dayExpenses.map((e) => ExpenseCard(
                          expense: e,
                          onDelete: () => _deleteWithUndo(e),
                          onEdit: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditExpenseScreen(expense: e),
                              ),
                            );
                          },
                        )),
                    const Divider(height: 1),
                  ],
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Split FAB
          ScaleTransition(
            scale: _fabAnim,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                heroTag: 'fab_expense_list_split',
                shape: const StadiumBorder(),
                onPressed: () {
                  _toggleFab();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const AddSplitScreen()),
                  );
                },
                icon: const Icon(Icons.group_add_rounded),
                label: const Text('Split'),
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                elevation: 4,
              ),
            ),
          ),
          // Expense FAB
          ScaleTransition(
            scale: _fabAnim,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                heroTag: 'fab_expense_list_expense',
                shape: const StadiumBorder(),
                onPressed: () {
                  _toggleFab();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const AddExpenseScreen()),
                  );
                },
                icon: const Icon(Icons.receipt_long_rounded),
                label: const Text('Expense'),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
              ),
            ),
          ),
          // Main FAB
          FloatingActionButton(
            heroTag: 'fab_expense_list_main',
            onPressed: _toggleFab,
            backgroundColor: _fabExpanded ? AppColors.error : AppColors.primary,
            child: AnimatedRotation(
              turns: _fabExpanded ? 0.125 : 0,
              duration: const Duration(milliseconds: 250),
              child: const Icon(Icons.add_rounded, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const _FilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filters = ['all', 'today', 'week', 'month', 'year'];
    final labels = ['All', 'Today', 'Week', 'Month', 'Year'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(filters.length, (i) {
          final isSelected = selected == filters[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(labels[i]),
              onSelected: (_) => onChanged(filters[i]),
            ),
          );
        }),
      ),
    );
  }
}
