// lib/features/search/search_screen.dart
// Global search with live filtering and date range filters

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/split_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/split_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late TabController _tabCtrl;
  String _dateFilter = 'all';
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  void _applySearch(String q) {
    ref.read(searchQueryProvider.notifier).state = q;
    ref.read(splitSearchQueryProvider.notifier).state = q;
  }

  List get _filteredExpenses {
    final all = ref.watch(filteredExpensesProvider);
    return _applyDateFilter(all);
  }

  List _applyDateFilter(List expenses) {
    final now = DateTime.now();
    switch (_dateFilter) {
      case 'today':
        return expenses.where((e) {
          return e.dateTime.year == now.year &&
              e.dateTime.month == now.month &&
              e.dateTime.day == now.day;
        }).toList();
      case 'week':
        final startOfWeek =
            now.subtract(Duration(days: now.weekday - 1));
        return expenses
            .where((e) => e.dateTime.isAfter(
                DateTime(startOfWeek.year, startOfWeek.month,
                    startOfWeek.day)))
            .toList();
      case 'month':
        return expenses
            .where((e) =>
                e.dateTime.year == now.year && e.dateTime.month == now.month)
            .toList();
      case 'year':
        return expenses
            .where((e) => e.dateTime.year == now.year)
            .toList();
      case 'custom':
        if (_customRange == null) return expenses;
        return expenses
            .where((e) =>
                e.dateTime.isAfter(
                    _customRange!.start.subtract(const Duration(days: 1))) &&
                e.dateTime.isBefore(
                    _customRange!.end.add(const Duration(days: 1))))
            .toList();
      default:
        return expenses;
    }
  }

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customRange,
    );
    if (range != null) {
      setState(() {
        _customRange = range;
        _dateFilter = 'custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final symbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          onChanged: _applySearch,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search expenses, places, notes...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      _applySearch('');
                      setState(() {});
                    },
                  )
                : null,
          ),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: const [
            Tab(text: 'Expenses'),
            Tab(text: 'Splits'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ...[
                  ('All', 'all'),
                  ('Today', 'today'),
                  ('Week', 'week'),
                  ('Month', 'month'),
                  ('Year', 'year'),
                ].map((item) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: _dateFilter == item.$2,
                        label: Text(item.$1),
                        onSelected: (_) =>
                            setState(() => _dateFilter = item.$2),
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: _dateFilter == 'custom',
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.date_range_rounded, size: 14),
                        const SizedBox(width: 4),
                        Text(_customRange != null
                            ? '${DateFormat('dd MMM').format(_customRange!.start)} - ${DateFormat('dd MMM').format(_customRange!.end)}'
                            : 'Custom'),
                      ],
                    ),
                    onSelected: (_) => _pickCustomRange(),
                  ),
                ),
              ],
            ),
          ),
          // Search results
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // Expenses tab
                Builder(builder: (context) {
                  final results = _filteredExpenses;
                  if (results.isEmpty) {
                    return _searchCtrl.text.isNotEmpty
                        ? EmptySearch(query: _searchCtrl.text)
                        : const EmptyExpenses();
                  }
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${results.length} results',
                                style: Theme.of(context).textTheme.bodySmall),
                            Text(
                              '$symbol${results.fold(0.0, (s, e) => s + e.amount).toStringAsFixed(0)}',
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (_, i) =>
                              ExpenseCard(expense: results[i]),
                        ),
                      ),
                    ],
                  );
                }),
                // Splits tab
                Builder(builder: (context) {
                  final results = ref.watch(filteredSplitsProvider);
                  if (results.isEmpty) {
                    return _searchCtrl.text.isNotEmpty
                        ? EmptySearch(query: _searchCtrl.text)
                        : const EmptySplits();
                  }
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (_, i) => SplitCard(split: results[i]),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
