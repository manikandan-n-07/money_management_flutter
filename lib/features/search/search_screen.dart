// lib/features/search/search_screen.dart
// Global search with live filtering, date range filters, premium header, and flow animations

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/split_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/split_card.dart';
import '../../widgets/flow_entrance_animation.dart';
import '../../widgets/flowing_background_header.dart';

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
    // Clear search queries on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchQueryProvider.notifier).state = '';
      ref.read(splitSearchQueryProvider.notifier).state = '';
    });
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
    setState(() {}); // Rebuild to update suffix icon clear button
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
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return expenses
            .where((e) => e.dateTime.isAfter(
                DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)))
            .toList();
      case 'month':
        return expenses
            .where((e) =>
                e.dateTime.year == now.year && e.dateTime.month == now.month)
            .toList();
      case 'year':
        return expenses.where((e) => e.dateTime.year == now.year).toList();
      case 'custom':
        if (_customRange == null) return expenses;
        return expenses
            .where((e) =>
                e.dateTime.isAfter(
                    _customRange!.start.subtract(const Duration(days: 1))) &&
                e.dateTime
                    .isBefore(_customRange!.end.add(const Duration(days: 1))))
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

  Widget _buildSearchHeader(BuildContext context, bool isDark) {
    const gradLight = [Color(0xFF5A54D4), Color(0xFF7047B8), Color(0xFF1DA882)];
    const gradDark = [Color(0xFF14082E), Color(0xFF0B1640), Color(0xFF082218)];

    return ClipPath(
      clipper: _SearchHeaderClipper(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? gradDark : gradLight,
          ),
        ),
        child: Stack(
          children: [
            // Decorative animated blobs
            FloatingOrb(
              size: 130,
              color: Colors.white,
              opacity: isDark ? 0.05 : 0.10,
              startX: MediaQuery.of(context).size.width * 0.75,
              startY: -25,
              dx: -20,
              dy: 15,
              duration: const Duration(seconds: 10),
            ),
            FloatingOrb(
              size: 90,
              color: Colors.white,
              opacity: isDark ? 0.04 : 0.08,
              startX: -15,
              startY: 60,
              dx: 20,
              dy: -20,
              duration: const Duration(seconds: 8),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  children: [
                    // Top Row: Back Button + Title
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: _applySearch,
                        autofocus: true,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Search expenses, places, notes...',
                          hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70, size: 20),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: Colors.white70, size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _applySearch('');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // TabBar
                    TabBar(
                      controller: _tabCtrl,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      indicatorColor: Colors.white,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorWeight: 3,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Expenses'),
                        Tab(text: 'Splits'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final symbol = ref.watch(currencySymbolProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: Column(
          children: [
            _buildSearchHeader(context, isDark),
            // Filter bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  Consumer(builder: (context, ref, _) {
                    final all = ref.watch(filteredExpensesProvider);
                    final results = _applyDateFilter(all);
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
                            padding: const EdgeInsets.only(bottom: 24),
                            itemBuilder: (_, i) => FlowEntranceAnimation(
                              delay: Duration(milliseconds: 35 * i),
                              child: ExpenseCard(expense: results[i]),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  // Splits tab
                  Consumer(builder: (context, ref, _) {
                    final results = ref.watch(filteredSplitsProvider);
                    if (results.isEmpty) {
                      return _searchCtrl.text.isNotEmpty
                          ? EmptySearch(query: _searchCtrl.text)
                          : const EmptySplits();
                    }
                    return ListView.builder(
                      itemCount: results.length,
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (_, i) => FlowEntranceAnimation(
                        delay: Duration(milliseconds: 35 * i),
                        child: SplitCard(split: results[i]),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 20);
    path.quadraticBezierTo(
      size.width * 0.3, size.height,
      size.width * 0.6, size.height - 10,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height - 18,
      size.width, size.height - 5,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_SearchHeaderClipper old) => false;
}
