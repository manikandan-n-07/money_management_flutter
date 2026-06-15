// lib/features/home/home_screen.dart
// Premium home screen — welcome header, quick stats, recent expenses,
// recent splits, budget progress, spending chart, quick-add FAB

import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/split_provider.dart';
import '../../services/expense_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/budget_progress_bar.dart';
import '../../widgets/expense_card.dart';
import '../../widgets/split_card.dart';
import '../../widgets/app_logo.dart';
import '../expenses/add_expense_screen.dart';
import '../expenses/expense_list_screen.dart';
import '../search/search_screen.dart';
import '../splits/add_split_screen.dart';
import '../splits/split_detail_screen.dart';
import '../splits/splits_list_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _fabExpanded = false;
  late AnimationController _fabCtrl;
  late Animation<double> _fabAnim;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fabCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _fabAnim = CurvedAnimation(parent: _fabCtrl, curve: Curves.easeOut);
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(settingsNotifierProvider);
      if (settings.userName.isEmpty) {
        _showNameAndNotifDialog();
      }
    });
  }

  void _showNameAndNotifDialog() {
    final controller = TextEditingController();
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Welcome Onboarding',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        final scale = Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
        );
        final slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
        );
        return SlideTransition(
          position: slide,
          child: ScaleTransition(
            scale: scale,
            child: FadeTransition(
              opacity: anim1,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Row(
                  children: [
                    AppLogo(size: 32),
                    SizedBox(width: 10),
                    Text('Welcome to Cashier!'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Please enter your name to personalize your offline dashboard:',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Your Name',
                        hintText: 'Enter name...',
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'We also need notification permissions to remind you of your daily logs and budget alerts locally.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                actions: [
                  FilledButton(
                    onPressed: () async {
                      final name = controller.text.trim();
                      if (name.isNotEmpty) {
                        await ref
                            .read(settingsNotifierProvider.notifier)
                            .setUserName(name);
                        await NotificationService.requestPermissions();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text('Get Started'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final currentName = ref.read(settingsNotifierProvider).userName;
    final controller = TextEditingController(text: currentName);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Edit Name',
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        final scale = Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
        );
        final slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
        );
        return SlideTransition(
          position: slide,
          child: ScaleTransition(
            scale: scale,
            child: FadeTransition(
              opacity: anim1,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('Edit Name'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      final name = controller.text.trim();
                      if (name.isNotEmpty) {
                        await ref
                            .read(settingsNotifierProvider.notifier)
                            .setUserName(name);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _fabCtrl.dispose();
    _timer?.cancel();
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final symbol = ref.watch(currencySymbolProvider);
    final todayTotal = ref.watch(todayTotalProvider);
    final weekTotal = ref.watch(thisWeekTotalProvider);
    final monthTotal = ref.watch(thisMonthTotalProvider);
    final recentExpenses = ref.watch(allExpensesProvider).take(5).toList();
    final recentSplits = ref.watch(pendingSplitsProvider).take(3).toList();
    final budget = ref.watch(currentBudgetProvider);
    final spent = ref.watch(thisMonthSpentProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // === App Bar ===
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(
                  theme, isDark, symbol, todayTotal, weekTotal, monthTotal),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SearchScreen(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () {},
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // === Budget Progress ===
                if (budget != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isDark
                              ? AppColors.darkCardBorder
                              : AppColors.lightCardBorder),
                    ),
                    child: BudgetProgressBar(
                      budget: budget.monthlyBudget,
                      spent: spent,
                      symbol: symbol,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // === Mini Spending Chart ===
                _MiniSpendingChart(symbol: symbol),
                const SizedBox(height: 20),

                // === Recent Expenses ===
                _SectionHeader(
                  title: 'Recent Expenses',
                  onSeeAll: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ExpenseListScreen()),
                  ),
                ),
                const SizedBox(height: 8),
                if (recentExpenses.isEmpty)
                  _EmptyCard(
                    icon: '💸',
                    message: 'No expenses yet. Add your first one!',
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const AddExpenseScreen()),
                    ),
                    actionLabel: 'Add Expense',
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isDark
                                ? AppColors.darkCardBorder
                                : AppColors.lightCardBorder),
                      ),
                      child: Column(
                        children: recentExpenses.map((e) {
                          return ExpenseCard(expense: e);
                        }).toList(),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // === Recent Splits ===
                if (recentSplits.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Pending Splits',
                    onSeeAll: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const SplitsListScreen()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...recentSplits.map((s) => SplitCard(
                        split: s,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SplitDetailScreen(splitId: s.id),
                          ),
                        ),
                      )),
                  const SizedBox(height: 20),
                ],

                // === Quick Categories ===
                const _SectionHeader(title: 'Quick Add'),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: AppConstants.categories.take(7).map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddExpenseScreen(initialCategory: cat.id),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: cat.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: cat.color.withValues(alpha: 0.25)),
                                ),
                                child:
                                    Icon(cat.icon, color: cat.color, size: 24),
                              ),
                              const SizedBox(height: 6),
                              Text(cat.name,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                  )),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      // === Speed-dial FAB ===
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Split FAB (hidden unless expanded)
          ScaleTransition(
            scale: _fabAnim,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                heroTag: 'fab_split',
                shape: const StadiumBorder(),
                onPressed: () {
                  _toggleFab();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddSplitScreen()),
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
          // Expense FAB (hidden unless expanded)
          ScaleTransition(
            scale: _fabAnim,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FloatingActionButton.extended(
                heroTag: 'fab_expense',
                shape: const StadiumBorder(),
                onPressed: () {
                  _toggleFab();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
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
            heroTag: 'fab_main',
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

  Widget _buildHeader(ThemeData theme, bool isDark, String symbol,
      double todayTotal, double weekTotal, double monthTotal) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.darkGradient
            : const LinearGradient(
                colors: [AppColors.lightBackground, AppColors.lightBackground],
              ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${_greeting()}, ${ref.watch(settingsNotifierProvider).userName.isNotEmpty ? ref.watch(settingsNotifierProvider).userName : 'User'}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _showEditNameDialog(context),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(AppConstants.appName,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  )),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd MMMM yyyy, hh:mm a').format(DateTime.now()),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Quick stats row
          Row(
            children: [
              _QuickStatItem(
                  label: 'Today',
                  value: CurrencyFormatter.formatCompact(todayTotal,
                      symbol: symbol),
                  color: AppColors.accent),
              Container(
                  width: 1,
                  height: 32,
                  color: AppColors.primary.withValues(alpha: 0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 12)),
              _QuickStatItem(
                  label: 'Week',
                  value: CurrencyFormatter.formatCompact(weekTotal,
                      symbol: symbol),
                  color: AppColors.primary),
              Container(
                  width: 1,
                  height: 32,
                  color: AppColors.primary.withValues(alpha: 0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 12)),
              _QuickStatItem(
                  label: 'Month',
                  value: CurrencyFormatter.formatCompact(monthTotal,
                      symbol: symbol),
                  color: AppColors.secondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _QuickStatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                )),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w800, fontSize: 16)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See All',
                style: TextStyle(color: AppColors.primary, fontSize: 13)),
          ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String icon;
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;

  const _EmptyCard({
    required this.icon,
    required this.message,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color:
                isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
      ),
      child: Center(
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 10),
            Text(message,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
            if (onAction != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(actionLabel ?? 'Add'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// === Mini Spending Chart for Home ===
class _MiniSpendingChart extends ConsumerWidget {
  final String symbol;
  const _MiniSpendingChart({required this.symbol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(expenseNotifierProvider);
    final data = ExpenseService.getDailyTotals(days: 7);
    final entries = data.entries.toList();
    final maxY = entries.isEmpty
        ? 100.0
        : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color:
                isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('7-Day Trend',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              Text('This week', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: maxY == 0
                ? const Center(
                    child: Text('No spending this week',
                        style: TextStyle(color: Colors.grey)))
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY * 1.3,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              final idx = val.toInt();
                              if (idx < 0 || idx >= entries.length) {
                                return const SizedBox.shrink();
                              }
                              final key = entries[idx].key;
                              final parts = key.split('-');
                              final dt = DateTime(int.parse(parts[0]),
                                  int.parse(parts[1]), int.parse(parts[2]));
                              return Text(
                                DateFormat('E').format(dt),
                                style: const TextStyle(
                                    fontSize: 9, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: entries.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.value);
                          }).toList(),
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 2.5,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, _, __, ___) =>
                                FlDotCirclePainter(
                              radius: 3,
                              color: AppColors.primary,
                              strokeColor: Colors.white,
                              strokeWidth: 1.5,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.25),
                                AppColors.primary.withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
