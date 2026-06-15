// lib/services/notification_service.dart
// Local notifications for reminders and budget alerts

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/constants/app_constants.dart';

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  static Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Schedule daily expense reminder
  static Future<void> scheduleDailyReminder({
    int hour = 21,
    int minute = 0,
  }) async {
    await _plugin.cancel(AppConstants.dailyNotifId);

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminder',
      channelDescription: 'Daily expense tracking reminder',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    // Show immediately as a daily reminder (simplified — no timezone dep)
    await _plugin.show(
      AppConstants.dailyNotifId,
      '💰 Track your expenses!',
      'Don\'t forget to log today\'s expenses in Cashier.',
      details,
    );
  }

  /// Show budget warning
  static Future<void> showBudgetWarning(
      double spent, double budget, String symbol) async {
    final pct = ((spent / budget) * 100).toStringAsFixed(0);

    const androidDetails = AndroidNotificationDetails(
      'budget_warning',
      'Budget Warning',
      channelDescription: 'Alerts when budget is running low',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      AppConstants.budgetNotifId,
      '⚠️ Budget Alert: $pct% used',
      'You\'ve spent $symbol${spent.toStringAsFixed(0)} of your $symbol${budget.toStringAsFixed(0)} budget.',
      details,
    );
  }

  /// Show monthly summary
  static Future<void> showMonthlySummary(double total, String symbol) async {
    const androidDetails = AndroidNotificationDetails(
      'monthly_summary',
      'Monthly Summary',
      channelDescription: 'Monthly expense summary',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      AppConstants.monthlyNotifId,
      '📊 Monthly Report Ready',
      'Total expenses this month: $symbol${total.toStringAsFixed(0)}. Tap to view report.',
      details,
    );
  }

  /// Show daily comparison report
  static Future<void> showDailyComparison(
      double todayTotal, double yesterdayTotal, String symbol) async {
    final diff = todayTotal - yesterdayTotal;
    final diffPct = yesterdayTotal > 0
        ? (diff / yesterdayTotal * 100).abs().toStringAsFixed(0)
        : '100';

    String body;
    if (diff > 0) {
      body =
          'Spent $symbol${diff.toStringAsFixed(0)} ($diffPct%) MORE today compared to yesterday ($symbol${yesterdayTotal.toStringAsFixed(0)}).';
    } else if (diff < 0) {
      body =
          'Great! Spent $symbol${diff.abs().toStringAsFixed(0)} ($diffPct%) LESS today compared to yesterday ($symbol${yesterdayTotal.toStringAsFixed(0)}).';
    } else {
      body =
          'Spent the exact same today as yesterday ($symbol${todayTotal.toStringAsFixed(0)}).';
    }

    const androidDetails = AndroidNotificationDetails(
      'spending_comparison',
      'Spending Comparison',
      channelDescription: 'Alerts with daily spending comparisons',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      AppConstants.dailyNotifId + 1,
      '📊 Spending Comparison',
      body,
      details,
    );
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
