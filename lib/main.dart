// lib/main.dart
// PennyWise — Premium Offline Expense Management App
// Entry point: Hive init, Riverpod, theme, routing

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/settings_provider.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'features/home/home_screen.dart';
import 'features/expenses/expense_list_screen.dart';
import 'features/splits/splits_list_screen.dart';
import 'features/statistics/statistics_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/splash/splash_screen.dart';
import 'widgets/app_bottom_nav.dart';
import 'widgets/floating_banner_overlay.dart';
import 'features/expenses/add_expense_screen.dart';
import 'features/splits/add_split_screen.dart';
import 'core/constants/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive init — must happen before any box access
  await HiveService.init();

  // Notification service init
  await NotificationService.init();

  // Status bar overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: CashierApp(),
    ),
  );
}

class CashierApp extends ConsumerWidget {
  const CashierApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final settings = ref.watch(settingsNotifierProvider);

    return MaterialApp(
      title: 'Cashier',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightTheme(settings.fontFamily),
      darkTheme: AppTheme.getDarkTheme(settings.fontFamily),
      themeMode: themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.textScale),
          ),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}

/// Main shell with bottom navigation
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _fabExpanded = false;
  late AnimationController _fabCtrl;
  late Animation<double> _fabAnim;

  final List<Widget> _pages = const [
    HomeScreen(),
    ExpenseListScreen(),
    SplitsListScreen(),
    StatisticsScreen(),
    MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fabAnim = CurvedAnimation(parent: _fabCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
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

  Widget _buildSpeedDialFab() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Split FAB (hidden unless expanded)
        ScaleTransition(
          scale: _fabAnim,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(
              heroTag: 'shell_fab_split',
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
              heroTag: 'shell_fab_expense',
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
          heroTag: 'shell_fab_main',
          onPressed: _toggleFab,
          backgroundColor: _fabExpanded ? AppColors.error : AppColors.primary,
          child: AnimatedRotation(
            turns: _fabExpanded ? 0.125 : 0,
            duration: const Duration(milliseconds: 250),
            child: const Icon(Icons.add_rounded, size: 28),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
            const FloatingBannerOverlay(),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (_fabExpanded) {
              _toggleFab();
            }
            setState(() => _currentIndex = index);
          },
        ),
        floatingActionButton:
            (_currentIndex == 0 || _currentIndex == 1 || _currentIndex == 2)
                ? _buildSpeedDialFab()
                : null,
      ),
    );
  }
}
