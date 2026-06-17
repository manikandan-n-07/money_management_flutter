// lib/features/expenses/expense_list_screen.dart
// Grouped expense list with date headers, swipe actions, undo delete

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';

import '../../core/utils/date_formatter.dart';
import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/premium_app_bar.dart';
import '../../widgets/flow_entrance_animation.dart';

import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';
import '../../providers/banner_provider.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  String _dateFilter = 'all';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
        content: Text(
            'Are you sure you want to permanently delete "${expense.place.isNotEmpty ? expense.place : 'this expense'}"?'),
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
        ref.read(bannerNotifierProvider.notifier).show(
          message: 'Expense deleted',
          actionLabel: 'Undo',
          onAction: () {
            ref.read(expenseNotifierProvider.notifier).undoDelete(expense);
          },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          PremiumSliverAppBar(
            title: 'Expenses',
            subtitle: DateFormat('dd MMM yyyy').format(DateTime.now()),
            emoji: '💸',
            expandedHeight: 140,
            lightColors: const [
              Color(0xFF2E86AB),
              Color(0xFF4A6FA5),
              Color(0xFF1A5276)
            ],
            darkColors: const [
              Color(0xFF0A1A2E),
              Color(0xFF0D2A40),
              Color(0xFF081A30)
            ],
            action: PremiumActionButton(
              icon: Icons.add_rounded,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
              ),
            ),
          ),

          // Filter bar
          SliverToBoxAdapter(
            child: FlowEntranceAnimation(
              delay: const Duration(milliseconds: 50),
              child: _FilterBar(
                selected: _dateFilter,
                onChanged: (f) => setState(() => _dateFilter = f),
              ),
            ),
          ),




          // Content
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: EmptyExpenses(
                onAdd: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, groupIndex) {
                  final dateKey = grouped.keys.elementAt(groupIndex);
                  final dayExpenses = grouped[dateKey]!;
                  final dayTotal =
                      dayExpenses.fold(0.0, (s, e) => s + e.amount);

                  return FlowEntranceAnimation(
                    delay: Duration(milliseconds: 100 + groupIndex * 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                    ),
                  );
                },
                childCount: grouped.keys.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: Navigator.canPop(context)
          ? FloatingActionButton(
              heroTag: 'fab_expense_list_add',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
              ),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
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
