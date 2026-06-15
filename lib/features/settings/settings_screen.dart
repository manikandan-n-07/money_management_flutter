// lib/features/settings/settings_screen.dart
// App settings: theme, currency, notifications, about

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/notification_service.dart';
import '../backup/backup_screen.dart';
import '../budget/budget_screen.dart';
import '../insights/insights_screen.dart';
import '../reports/reports_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        children: [
          // Profile-ish header
          GestureDetector(
            onTap: () => _showEditNameDialog(context, ref, settings.userName),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(settings.userName.isNotEmpty ? settings.userName : 'User',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18)),
                      const Text('Tap to edit profile',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Appearance
          const _SectionHeader('Appearance'),
          _SettingsItem(
            icon: isDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            title: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            subtitle: 'Currently: ${isDark ? "Dark" : "Light"} mode',
            color: AppColors.primary,
            onTap: () =>
                ref.read(themeNotifierProvider.notifier).toggleTheme(),
          ),

          // Currency
          const _SectionHeader('Currency'),
          _SettingsItem(
            icon: Icons.currency_exchange_rounded,
            title: 'Currency',
            subtitle:
                '${settings.currencyCode} (${settings.currency})',
            color: AppColors.secondary,
            onTap: () => _showCurrencyPicker(context, ref),
          ),

          // Tools
          const _SectionHeader('Tools'),
          _SettingsItem(
            icon: Icons.savings_rounded,
            title: 'Budget Planner',
            subtitle: 'Set and manage monthly budget',
            color: AppColors.accentOrange,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BudgetScreen()),
            ),
          ),
          _SettingsItem(
            icon: Icons.lightbulb_rounded,
            title: 'Smart Insights',
            subtitle: 'See spending patterns & analysis',
            color: AppColors.catFestival,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InsightsScreen()),
            ),
          ),
          _SettingsItem(
            icon: Icons.assessment_rounded,
            title: 'Reports',
            subtitle: 'Export PDF & Excel reports',
            color: AppColors.error,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ReportsScreen()),
            ),
          ),
          _SettingsItem(
            icon: Icons.backup_rounded,
            title: 'Backup & Restore',
            subtitle: 'Export or import your data',
            color: AppColors.accentBlue,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BackupScreen()),
            ),
          ),

          // Notifications
          const _SectionHeader('Notifications'),
          _ToggleItem(
            icon: Icons.notifications_rounded,
            title: 'Daily Reminder',
            subtitle: 'Remind to log expenses daily',
            value: settings.notifDaily,
            color: AppColors.primary,
            onChanged: (v) {
              ref.read(settingsNotifierProvider.notifier).setNotifDaily(v);
              if (v) {
                NotificationService.scheduleDailyReminder();
              }
            },
          ),
          _ToggleItem(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Budget Warning',
            subtitle: 'Alert when budget runs low',
            value: settings.notifBudget,
            color: AppColors.warning,
            onChanged: (v) =>
                ref.read(settingsNotifierProvider.notifier).setNotifBudget(v),
          ),
          _ToggleItem(
            icon: Icons.calendar_month_rounded,
            title: 'Monthly Summary',
            subtitle: 'Monthly spending notification',
            value: settings.notifMonthly,
            color: AppColors.secondary,
            onChanged: (v) => ref
                .read(settingsNotifierProvider.notifier)
                .setNotifMonthly(v),
          ),

          // About
          const _SectionHeader('About'),
          _SettingsItem(
            icon: Icons.info_outline_rounded,
            title: 'About ${AppConstants.appName}',
            subtitle: 'Version 1.0.0',
            color: AppColors.primary,
            onTap: () => _showAbout(context),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Select Currency',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1),
          ...AppConstants.currencies.map((c) => ListTile(
                leading: Text(c['symbol']!,
                    style: const TextStyle(fontSize: 22)),
                title: Text(c['name']!),
                subtitle: Text(c['code']!),
                onTap: () {
                  ref
                      .read(settingsNotifierProvider.notifier)
                      .setCurrency(c['symbol']!, c['code']!);
                  Navigator.of(context).pop();
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 ${AppConstants.appName}. 100% Offline.',
      children: [
        const SizedBox(height: 12),
        const Text(
            '${AppConstants.appName} is a premium offline expense management app. No cloud, no server, just your data on your device.'),
      ],
    );
  }

  void _showEditNameDialog(
      BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Profile'),
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12)),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color color;
  final Function(bool) onChanged;

  const _ToggleItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: color,
      ),
    );
  }
}
