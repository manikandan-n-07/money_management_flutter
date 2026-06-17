// lib/features/settings/settings_screen.dart
// App settings: theme, currency, notifications, about

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/premium_app_bar.dart';
import '../../widgets/flow_entrance_animation.dart';
import '../backup/backup_screen.dart';
import '../budget/budget_screen.dart';
import '../insights/insights_screen.dart';
import '../notifications/notification_settings_screen.dart';
import '../reports/reports_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          PremiumSliverAppBar(
            title: settings.userName.isNotEmpty ? settings.userName : 'More',
            subtitle: 'Settings & preferences',
            emoji: '⚙️',
            expandedHeight: 140,
            lightColors: const [
              Color(0xFF2C3E7A),
              Color(0xFF1A4E6E),
              Color(0xFF0E3B52),
            ],
            darkColors: const [
              Color(0xFF0A0E28),
              Color(0xFF080E20),
              Color(0xFF060C18),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Profile card
                FlowEntranceAnimation(
                  delay: const Duration(milliseconds: 50),
                  child: GestureDetector(
                    onTap: () =>
                        _showEditNameDialog(context, ref, settings.userName),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_rounded,
                                color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  settings.userName.isNotEmpty
                                      ? settings.userName
                                      : 'User',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17)),
                              const Text('Tap to edit profile',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Appearance
                FlowEntranceAnimation(
                  delay: const Duration(milliseconds: 100),
                  child: Column(
                    children: [
                      const _SectionHeader('Appearance'),
                      _SettingsItem(
                        icon: Icons.dark_mode_rounded,
                        title: 'Dark Mode',
                        subtitle: 'Currently: ${isDark ? "On" : "Off"}',
                        color: AppColors.primary,
                        trailing: Switch(
                          value: isDark,
                          onChanged: (_) => ref.read(themeNotifierProvider.notifier).toggleTheme(),
                          activeThumbColor: AppColors.primary,
                        ),
                        onTap: () => ref.read(themeNotifierProvider.notifier).toggleTheme(),
                      ),
                    ],
                  ),
                ),

                // Typography
                FlowEntranceAnimation(
                  delay: const Duration(milliseconds: 125),
                  child: Column(
                    children: [
                      const _SectionHeader('Typography'),
                      _SettingsItem(
                        icon: Icons.text_fields_rounded,
                        title: 'Font Family',
                        subtitle: settings.fontFamily,
                        color: AppColors.catEntertainment,
                        onTap: () => _showFontPicker(context, ref, settings.fontFamily),
                      ),
                      _SettingsItem(
                        icon: Icons.format_size_rounded,
                        title: 'Font Size',
                        subtitle: '${(settings.textScale * 100).toInt()}%',
                        color: AppColors.catPersonal,
                        onTap: () => _showFontSizePicker(context, ref, settings.textScale),
                      ),
                    ],
                  ),
                ),

                // Currency
                FlowEntranceAnimation(
                  delay: const Duration(milliseconds: 150),
                  child: Column(
                    children: [
                      const _SectionHeader('Currency'),
                      _SettingsItem(
                        icon: Icons.currency_exchange_rounded,
                        title: 'Currency',
                        subtitle: '${settings.currencyCode} (${settings.currency})',
                        color: AppColors.secondary,
                        onTap: () => _showCurrencyPicker(context, ref),
                      ),
                    ],
                  ),
                ),

                // Tools
                FlowEntranceAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
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
                    ],
                  ),
                ),

                // Notifications
                FlowEntranceAnimation(
                  delay: const Duration(milliseconds: 250),
                  child: Column(
                    children: [
                      const _SectionHeader('Notifications'),
                      _SettingsItem(
                        icon: Icons.notifications_active_rounded,
                        title: '😂 Comedy Notifications',
                        subtitle: 'Roasts, jokes & budget panic alerts — tap to customise',
                        color: AppColors.primary,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const NotificationSettingsScreen()),
                        ),
                      ),
                    ],
                  ),
                ),

                // About
                FlowEntranceAnimation(
                  delay: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      const _SectionHeader('About'),
                      _SettingsItem(
                        icon: Icons.info_outline_rounded,
                        title: 'About ${AppConstants.appName}',
                        subtitle: 'Version 1.0.0',
                        color: AppColors.primary,
                        onTap: () => _showAbout(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
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
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1),
          ...AppConstants.currencies.map((c) => ListTile(
                leading:
                    Text(c['symbol']!, style: const TextStyle(fontSize: 22)),
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

  void _showFontPicker(BuildContext context, WidgetRef ref, String currentFont) {
    final fonts = ['Poppins', 'Inter', 'Roboto', 'Lato', 'Montserrat'];
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
            child: Text('Select Font Family',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const Divider(height: 1),
          ...fonts.map((f) => ListTile(
                title: Text(f, style: TextStyle(fontFamily: f)),
                trailing: currentFont == f
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(settingsNotifierProvider.notifier).setFontFamily(f);
                  Navigator.of(context).pop();
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showFontSizePicker(BuildContext context, WidgetRef ref, double currentScale) {
    double scale = currentScale;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Adjust Font Size',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  const Text('A', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Slider(
                      value: scale,
                      min: 0.8,
                      max: 1.4,
                      divisions: 6,
                      activeColor: AppColors.primary,
                      label: '${(scale * 100).toInt()}%',
                      onChanged: (val) {
                        setState(() => scale = val);
                        ref.read(settingsNotifierProvider.notifier).setTextScale(val);
                      },
                    ),
                  ),
                  const Text('A', style: TextStyle(fontSize: 24)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
        child: Text(
          title.toUpperCase(),
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
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
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.trailing,
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
      title: Text(
          title,
          textAlign: TextAlign.left,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(
          subtitle,
          textAlign: TextAlign.left,
          style: const TextStyle(fontSize: 12)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }
}



