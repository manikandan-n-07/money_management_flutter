// lib/features/notifications/notification_settings_screen.dart
// Comedy Notification Hub — because boring notifications are a crime 😂

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/settings_provider.dart';
import '../../services/notification_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late Animation<double> _headerAnim;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  String? _lastTestedType;
  bool _isShowingFeedback = false;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _headerAnim = CurvedAnimation(parent: _headerCtrl, curve: Curves.elasticOut);
    _headerCtrl.forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _testNotification(String type) async {
    setState(() {
      _lastTestedType = type;
      _isShowingFeedback = true;
    });
    await NotificationService.requestPermissions();
    await NotificationService.showTestNotification(type);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isShowingFeedback = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A1A) : const Color(0xFFF5F5FF),
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(),
              collapseMode: CollapseMode.parallax,
            ),
            title: const Text(
              '🔔 Notifications',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Intro joke card
                  _buildJokeCard(),
                  const SizedBox(height: 24),

                  // Toggle section
                  _buildSectionTitle('📳 What Bugs You?'),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    emoji: '⏰',
                    title: 'Daily Roast Reminder',
                    subtitle: 'We\'ll roast you every day til you log expenses',
                    value: settings.notifDaily,
                    color: AppColors.primary,
                    onChanged: (v) {
                      ref
                          .read(settingsNotifierProvider.notifier)
                          .setNotifDaily(v);
                      if (v) NotificationService.scheduleDailyReminder();
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildToggleCard(
                    emoji: '💸',
                    title: 'Budget Meltdown Alerts',
                    subtitle: 'We panic-text you when money gets scary',
                    value: settings.notifBudget,
                    color: AppColors.warning,
                    onChanged: (v) => ref
                        .read(settingsNotifierProvider.notifier)
                        .setNotifBudget(v),
                  ),
                  const SizedBox(height: 10),
                  _buildToggleCard(
                    emoji: '📊',
                    title: 'Monthly Damage Report',
                    subtitle: 'A monthly summary nobody asked for',
                    value: settings.notifMonthly,
                    color: AppColors.secondary,
                    onChanged: (v) => ref
                        .read(settingsNotifierProvider.notifier)
                        .setNotifMonthly(v),
                  ),

                  const SizedBox(height: 28),

                  // Test notification section
                  _buildSectionTitle('🧪 Test The Comedy'),
                  const SizedBox(height: 4),
                  Text(
                    'Fire a test notification to see if your phone can handle the roast',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTestGrid(),

                  // Feedback snackbar-style card
                  if (_isShowingFeedback) ...[
                    const SizedBox(height: 16),
                    _buildFeedbackCard(),
                  ],

                  const SizedBox(height: 28),

                  // Comedy credits
                  _buildCreditsCard(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ScaleTransition(
      scale: _headerAnim,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.secondary,
              Color(0xFF7C3AED),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background emoji pattern
            ...List.generate(10, (i) {
              final emojis = ['💸', '🤑', '😂', '💀', '🎭', '🔔', '📊', '🚨', '🏆', '🤦'];
              return Positioned(
                top: (i * 37.0) % 180,
                left: (i * 83.0) % 340,
                child: Opacity(
                  opacity: 0.07,
                  child: Text(emojis[i], style: const TextStyle(fontSize: 36)),
                ),
              );
            }),
            // Content
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🔔', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 8),
                    Text(
                      'Comedy Notification Central',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Because boring alerts are a crime.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
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

  Widget _buildJokeCard() {
    final jokes = [
      ('🤔', 'Why did the expense tracker go to therapy?', 'Because it had too many unresolved issues.'),
      ('😂', 'What\'s a spender\'s favourite song?', '"Money Money Money" — on repeat, in shame.'),
      ('💀', 'How do you know you\'re broke?', 'When Cashier cries before you do.'),
      ('🎭', 'What did the budget say to the wallet?', '"Stop letting people walk all over me!"'),
    ];
    final joke = jokes[DateTime.now().day % jokes.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.secondary.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(joke.$1, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Joke of the Day 😏',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            joke.$2,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            joke.$3,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 17,
      ),
    );
  }

  Widget _buildToggleCard({
    required String emoji,
    required String title,
    required String subtitle,
    required bool value,
    required Color color,
    required Function(bool) onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: value
            ? color.withValues(alpha: 0.12)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: value
              ? color.withValues(alpha: 0.35)
              : Colors.grey.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          if (value)
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildTestGrid() {
    final tests = [
      ('⏰', 'Daily Roast', 'daily', AppColors.primary),
      ('💸', 'Budget Panic', 'budget', AppColors.warning),
      ('💀', 'Budget GONE', 'budget_exceeded', AppColors.error),
      ('📊', 'Monthly Trauma', 'monthly', AppColors.secondary),
      ('🏆', 'You\'re Amazing', 'good_job', const Color(0xFF10B981)),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: tests.map((t) {
        final isActive = _lastTestedType == t.$3 && _isShowingFeedback;
        return GestureDetector(
          onTap: () => _testNotification(t.$3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? t.$4.withValues(alpha: 0.2)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? t.$4
                    : Colors.grey.withValues(alpha: 0.2),
                width: 1.5,
              ),
              boxShadow: [
                if (isActive)
                  BoxShadow(
                    color: t.$4.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t.$1, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  t.$2,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isActive ? t.$4 : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedbackCard() {
    return ScaleTransition(
      scale: _pulseAnim,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.2),
              AppColors.secondary.withValues(alpha: 0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
        ),
        child: const Row(
          children: [
            Text('🚀', style: TextStyle(fontSize: 24)),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Fired! 🎯',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  Text(
                    'Check your notification panel. Brace yourself. 😂',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const Text('🤡', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          const Text(
            'Comedy Notification Engine v1.0',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Powered by genuine financial anxiety\nand a healthy sense of humor.',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black45,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '100% Offline · No cloud · Just roasts',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
