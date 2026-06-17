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
import '../notifications/notification_settings_screen.dart';
import '../search/search_screen.dart';
import '../splits/split_detail_screen.dart';
import 'package:flutter/services.dart';
import '../splits/splits_list_screen.dart';
import '../../widgets/flow_entrance_animation.dart';
import '../../widgets/flowing_background_header.dart';
import '../../widgets/quick_add_bottom_sheet.dart';
import '../../widgets/category_more_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _timer;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
    // Dialog is triggered reactively via ref.listen in build, not here
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
        final slide =
            Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
                .animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
        );
        return SlideTransition(
          position: slide,
          child: ScaleTransition(
            scale: scale,
            child: FadeTransition(
              opacity: anim1,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
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
        final slide =
            Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
                .animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
        );
        return SlideTransition(
          position: slide,
          child: ScaleTransition(
            scale: scale,
            child: FadeTransition(
              opacity: anim1,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
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
    _timer?.cancel();
    super.dispose();
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
    final settings = ref.watch(settingsNotifierProvider);
    final symbol = ref.watch(currencySymbolProvider);
    final todayTotal = ref.watch(todayTotalProvider);
    final weekTotal = ref.watch(thisWeekTotalProvider);
    final monthTotal = ref.watch(thisMonthTotalProvider);
    final recentExpenses = ref.watch(allExpensesProvider).take(5).toList();
    final recentSplits = ref.watch(pendingSplitsProvider).take(3).toList();
    final budget = ref.watch(currentBudgetProvider);
    final spent = ref.watch(thisMonthSpentProvider);

    // Show onboarding dialog only once after settings have loaded from storage
    if (!_dialogShown && settings.isLoaded && settings.userName.isEmpty) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showNameAndNotifDialog();
      });
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // === App Bar ===
          SliverAppBar(
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
            ),
            expandedHeight: 270,
            pinned: false,
            floating: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(
                  theme, isDark, symbol, todayTotal, weekTotal, monthTotal),
              collapseMode: CollapseMode.pin,
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // === Budget Progress ===
                if (budget != null)
                  FlowEntranceAnimation(
                    delay: const Duration(milliseconds: 50),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCard
                                : AppColors.lightCard,
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
                    ),
                  ),

                // === Mini Spending Chart ===
                FlowEntranceAnimation(
                  delay: const Duration(milliseconds: 100),
                  child: Column(
                    children: [
                      _MiniSpendingChart(symbol: symbol),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // === Recent Expenses ===
                FlowEntranceAnimation(
                  delay: const Duration(milliseconds: 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              color: isDark
                                  ? AppColors.darkCard
                                  : AppColors.lightCard,
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
                    ],
                  ),
                ),

                // === Recent Splits ===
                if (recentSplits.isNotEmpty)
                  FlowEntranceAnimation(
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                  builder: (_) =>
                                      SplitDetailScreen(splitId: s.id),
                                ),
                              ),
                            )),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),

                // === Quick Categories ===
                FlowEntranceAnimation(
                  delay: const Duration(milliseconds: 250),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeader(title: 'Quick Add'),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            ...AppConstants.categories.take(7).map((cat) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => QuickAddBottomSheet(
                                          categoryId: cat.id),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color:
                                              cat.color.withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: cat.color
                                                  .withValues(alpha: 0.25)),
                                        ),
                                        child: Icon(cat.icon,
                                            color: cat.color, size: 24),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        cat.name,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            // Others / Plus Item
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => const CategoryMoreSheet(
                                        isQuickSplit: false),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.25)),
                                      ),
                                      child: Icon(Icons.add_rounded,
                                          color: theme.colorScheme.primary,
                                          size: 24),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Others',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark, String symbol,
      double todayTotal, double weekTotal, double monthTotal) {
    final userName = ref.watch(settingsNotifierProvider).userName;
    final greeting = _greeting();
    final now = DateTime.now();
    final hour = now.hour;
    final greetEmoji = hour < 12 ? '🌅' : (hour < 17 ? '☀️' : '🌙');

    return ClipPath(
      clipper: _HeaderWaveClipper(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF2A1B54),
                    Color(0xFF1F2B5B),
                    Color(0xFF163E30),
                  ]
                : const [
                    Color(0xFF4842B0),
                    Color(0xFF5A3896),
                    Color(0xFF178768),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // ── Decorative animated blobs ───────────────────────
            FloatingOrb(
              size: 180,
              color: isDark ? const Color(0xFF6C63FF) : Colors.white,
              opacity: isDark ? 0.06 : 0.08,
              startX: MediaQuery.of(context).size.width * 0.7,
              startY: -40,
              dx: -40,
              dy: 30,
              duration: const Duration(seconds: 10),
            ),
            FloatingOrb(
              size: 220,
              color: isDark ? const Color(0xFF00FFB2) : Colors.white,
              opacity: isDark ? 0.04 : 0.06,
              startX: -30,
              startY: 120,
              dx: 30,
              dy: -40,
              duration: const Duration(seconds: 8),
            ),
            FloatingOrb(
              size: 90,
              color: isDark ? const Color(0xFFFF6B6B) : Colors.white,
              opacity: isDark ? 0.03 : 0.04,
              startX: MediaQuery.of(context).size.width * 0.4,
              startY: 60,
              dx: 25,
              dy: 30,
              duration: const Duration(seconds: 7),
            ),

            // ── Main content ────────────────────────────────────
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top row: logo+greeting pill  |  action buttons
                    Row(
                      children: [
                        // Greeting pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(greetEmoji,
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                '$greeting, ${userName.isNotEmpty ? userName.split(' ').first : 'User'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => _showEditNameDialog(context),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Search button
                        _GlassIconButton(
                          icon: Icons.search_rounded,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const SearchScreen()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Notification button
                        _GlassIconButton(
                          icon: Icons.notifications_outlined,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const NotificationSettingsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // App name + tagline
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const AppLogo(size: 42),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.appName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                                height: 1,
                              ),
                            ),
                            Text(
                              AppConstants.appTagline,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Date badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('dd').format(now),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                              Text(
                                DateFormat('MMM').format(now).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Glassmorphic stat cards row ─────────────
                    Row(
                      children: [
                        _GlassStatCard(
                          label: 'TODAY',
                          value: CurrencyFormatter.formatCompact(todayTotal,
                              symbol: symbol),
                          icon: '⚡',
                          color: const Color(0xFFFF6B6B),
                        ),
                        const SizedBox(width: 10),
                        _GlassStatCard(
                          label: 'THIS WEEK',
                          value: CurrencyFormatter.formatCompact(weekTotal,
                              symbol: symbol),
                          icon: '📅',
                          color: const Color(0xFFFFD32A),
                        ),
                        const SizedBox(width: 10),
                        _GlassStatCard(
                          label: 'THIS MONTH',
                          value: CurrencyFormatter.formatCompact(monthTotal,
                              symbol: symbol),
                          icon: '📊',
                          color: const Color(0xFF00D4AA),
                        ),
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
}

// ── Wave Clipper ────────────────────────────────────────────────────────────
class _HeaderWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 36);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 20,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 40,
      size.width,
      size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_HeaderWaveClipper oldClipper) => false;
}

// ── Glass Icon Button ────────────────────────────────────────────────────────
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ── Glass Stat Card ──────────────────────────────────────────────────────────
class _GlassStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const _GlassStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
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
