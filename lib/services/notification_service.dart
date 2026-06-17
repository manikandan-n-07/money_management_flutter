// lib/services/notification_service.dart
// Comedy notification system — because money management should be fun!

import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/constants/app_constants.dart';

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static final _rand = Random();

  // ─────────────────────────────────────────────
  //  COMEDY MESSAGES — Roast-level humor 😂
  // ─────────────────────────────────────────────

  static const List<String> _dailyTitles = [
    '💸 Oi! Your wallet is crying!',
    '🤑 Money don\'t grow on trees, bro!',
    '😤 Where did all the money go?!',
    '🕵️ Cashier detective is on the case!',
    '🐷 Your piggy bank called. It\'s lonely.',
    '🚨 EXPENSE ALERT: Human detected!',
    '💰 Your future self is judging you.',
    '😅 We both know you spent today...',
  ];

  static const List<String> _dailyBodies = [
    'Log your expenses before they log YOU out of your savings account! 📊',
    'That coffee you had? Yeah... add it. Every sip counts, champ. ☕',
    'Your bank statement won\'t judge you. But we both know it should. 😂',
    'Spent money today? Of course you did. Open Cashier and confess! 🙏',
    'Future you is begging present you to track expenses. Don\'t ghost them! 👻',
    'The money you spent today isn\'t logging itself. Unlike your Netflix binges. 📺',
    'Remember: untracked expenses are just... trust fund for your regrets. 💀',
    'Open Cashier. Just look at what you did. No judgement. (There is judgement.) 👀',
  ];

  static const List<String> _budgetWarnTitles = [
    '🚨 RED ALERT: Wallet Emergency!',
    '😱 Your budget is having a meltdown!',
    '🔥 Budget on FIRE! Not the cool kind.',
    '📉 Your savings are crying right now.',
    '🆘 Budget SOS! Man overboard!',
    '😤 You did it again, didn\'t you?',
    '💸 Houston, we have a spending problem.',
    '🤯 The audacity. The absolute audacity.',
  ];

  static const List<String> _budgetWarnBodies = [
    'You\'ve burned through %PCT%% of your budget. At this rate, you\'ll be eating air by month-end. 🫙',
    '%PCT%% gone. Your budget didn\'t sign up for this abuse. It has feelings, you know! 😭',
    'Spent %PCT%% already?! Your wallet has filed a missing persons report. 🚔',
    'Budget status: Hanging by a thread 🧵 Spent: %PCT%%. Please stop. Please.',
    '%PCT%% of budget used. The remaining %REM%% is literally trembling with fear. 😰',
    'Congratulations on spending %PCT%% of your budget! Your trophy is a sad, empty wallet. 🏆',
    'You: I\'ll save money this month. Also you: *spends %PCT%% of budget*. Interesting. 🤔',
    'Your budget wants to speak to your manager. You ARE the manager. This is on you. 📋',
  ];

  static const List<String> _monthlyTitles = [
    '📊 Monthly Damage Report is Ready!',
    '🎭 The Financial Horror Story — Chapter This Month',
    '🏁 And... that\'s a wrap on your wallet!',
    '📜 Your Monthly Spending Confession',
    '🎪 The Greatest Show: Your Expenses!',
    '📉 Monthly financial autopsy complete.',
    '🧾 Month\'s receipts are piling up!',
  ];

  static const List<String> _monthlyBodies = [
    'Total spent: %AMT%. Don\'t panic. (Panic a little.) 😅',
    'This month you spent %AMT%. Your bank account needs a hug and a therapist. 🛋️',
    'Monthly report: %AMT% gone. Memories priceless. Savings account: not so much. 💔',
    'You spent %AMT% this month. That\'s like buying %COFFEES% coffees. Wow. Just... wow. ☕',
    'BREAKING NEWS: Local person spends %AMT% in a single month. Experts baffled. 📰',
    'Monthly finale: %AMT% disappeared. No witnesses. Tap to investigate! 🔍',
    'The numbers are in and they are... a journey. Total: %AMT%. Open for the full trauma. 😬',
  ];

  static const List<String> _budgetExceededTitles = [
    '💀 Budget has LEFT the chat!',
    '🚫 Budget? What budget? It\'s gone!',
    '🤡 Plot twist: Budget = 0',
    '☠️ RIP Budget 2024-2024',
    '🏴‍☠️ Your budget walked so you could run... past it.',
  ];

  static const List<String> _budgetExceededBodies = [
    'You\'ve EXCEEDED your budget. Your budget is now in a better place. 🌈',
    'Budget: Obliterated. Wallet: In shambles. You: Probably buying something right now. 🛒',
    'Congratulations! You have officially broken your own budget. New personal record! 🎉',
    'You exceeded your budget. In other news, water is wet and the sky is blue. 🌊',
    'Budget status: Deceased. Next of kin (future you) has been notified. ⚰️',
  ];

  static const List<String> _goodJobTitles = [
    '🎉 Wow, you\'re actually saving money?!',
    '🏆 Achievement Unlocked: Financial Adult!',
    '😲 Are you... being responsible?',
    '✨ Your budget is thriving and so are you!',
    '🌟 Look at you go, money wizard!',
  ];

  static const List<String> _goodJobBodies = [
    'You\'re under budget! Take a moment to feel smug about it. You\'ve earned it. 😏',
    'Under budget this month! Your future self is throwing a party for you. 🎊',
    'Financial discipline detected! This is suspicious. But we\'re proud. 🤨❤️',
    'You saved money! Go celebrate... responsibly. Within budget. You know the rules. 📏',
    'Budget goals: Crushed. You\'re basically a financial superhero now. No cape required. 🦸',
  ];

  // ─────────────────────────────────────────────
  //  INIT
  // ─────────────────────────────────────────────

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

  // ─────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────

  static String _pick(List<String> list) =>
      list[_rand.nextInt(list.length)];

  static AndroidNotificationDetails _androidDetails(
      String channelId, String channelName, String channelDesc) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: const BigTextStyleInformation(''),
    );
  }

  static NotificationDetails _details(
      String channelId, String channelName, String channelDesc) {
    return NotificationDetails(
      android: _androidDetails(channelId, channelName, channelDesc),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  DAILY REMINDER (Comedy roast version)
  // ─────────────────────────────────────────────

  static Future<void> scheduleDailyReminder({
    int hour = 21,
    int minute = 0,
  }) async {
    await _plugin.cancel(AppConstants.dailyNotifId);

    final title = _pick(_dailyTitles);
    final body = _pick(_dailyBodies);

    await _plugin.show(
      AppConstants.dailyNotifId,
      title,
      body,
      _details('daily_reminder', 'Daily Reminder',
          'Daily expense tracking reminder (comedy edition)'),
    );
  }

  // ─────────────────────────────────────────────
  //  BUDGET WARNING (Roast-level alert)
  // ─────────────────────────────────────────────

  static Future<void> showBudgetWarning(
      double spent, double budget, String symbol) async {
    final pct = ((spent / budget) * 100).toStringAsFixed(0);
    final remaining = (100 - (spent / budget) * 100).clamp(0, 100).toStringAsFixed(0);

    // Choose titles/bodies based on severity
    final exceeded = spent >= budget;
    final title = exceeded
        ? _pick(_budgetExceededTitles)
        : _pick(_budgetWarnTitles);

    String body = exceeded
        ? _pick(_budgetExceededBodies)
        : _pick(_budgetWarnBodies)
            .replaceAll('%PCT%', pct)
            .replaceAll('%REM%', remaining);

    // Add actual amount info at end
    body += '\n💰 Spent: $symbol${spent.toStringAsFixed(0)} / $symbol${budget.toStringAsFixed(0)}';

    await _plugin.show(
      AppConstants.budgetNotifId,
      title,
      body,
      _details('budget_warning', 'Budget Warning',
          'Alerts when budget is running low (with comedy)'),
    );
  }

  // ─────────────────────────────────────────────
  //  MONTHLY SUMMARY
  // ─────────────────────────────────────────────

  static Future<void> showMonthlySummary(double total, String symbol) async {
    final coffees = (total / 150).toStringAsFixed(0); // avg coffee price
    final title = _pick(_monthlyTitles);
    final body = _pick(_monthlyBodies)
        .replaceAll('%AMT%', '$symbol${total.toStringAsFixed(0)}')
        .replaceAll('%COFFEES%', coffees);

    await _plugin.show(
      AppConstants.monthlyNotifId,
      title,
      body,
      _details('monthly_summary', 'Monthly Summary',
          'Monthly expense summary (comedy edition)'),
    );
  }

  // ─────────────────────────────────────────────
  //  GOOD JOB (Under-budget reward)
  // ─────────────────────────────────────────────

  static Future<void> showGoodJob(
      double saved, double budget, String symbol) async {
    final title = _pick(_goodJobTitles);
    final body = _pick(_goodJobBodies);

    await _plugin.show(
      AppConstants.goodJobNotifId,
      '$title\n💚 Saved: $symbol${saved.toStringAsFixed(0)}',
      body,
      _details('good_job', 'Savings Cheer',
          'Congratulations for staying under budget!'),
    );
  }

  // ─────────────────────────────────────────────
  //  TEST NOTIFICATION (for settings screen)
  // ─────────────────────────────────────────────

  static Future<void> showTestNotification(String type) async {
    switch (type) {
      case 'daily':
        await scheduleDailyReminder();
        break;
      case 'budget':
        await showBudgetWarning(7500, 10000, '₹');
        break;
      case 'budget_exceeded':
        await showBudgetWarning(11000, 10000, '₹');
        break;
      case 'monthly':
        await showMonthlySummary(24500, '₹');
        break;
      case 'good_job':
        await showGoodJob(3500, 10000, '₹');
        break;
    }
  }

  // ─────────────────────────────────────────────
  //  DAILY COMPARISON
  // ─────────────────────────────────────────────

  static Future<void> showDailyComparison(
      double todayTotal, double yesterdayTotal, String symbol) async {
    final diff = todayTotal - yesterdayTotal;
    final diffPct = yesterdayTotal > 0
        ? (diff / yesterdayTotal * 100).abs().toStringAsFixed(0)
        : '100';

    String title;
    String body;

    if (diff > 0) {
      title = '📈 Spending UP $diffPct% today... interesting.';
      body =
          'Spent $symbol${diff.toStringAsFixed(0)} more than yesterday ($symbol${yesterdayTotal.toStringAsFixed(0)}). Plot twist: you have a problem. 😅';
    } else if (diff < 0) {
      title = '📉 Down $diffPct%! A miracle has occurred!';
      body =
          'Spent $symbol${diff.abs().toStringAsFixed(0)} LESS than yesterday. Scientists are baffled. Keep it up! 🧑‍🔬';
    } else {
      title = '😐 Exactly the same as yesterday. Every. Single. Day.';
      body =
          'Same as yesterday: $symbol${todayTotal.toStringAsFixed(0)}. Your spending is a perfectly consistent disaster. 🔁';
    }

    await _plugin.show(
      AppConstants.dailyNotifId + 1,
      title,
      body,
      _details('spending_comparison', 'Spending Comparison',
          'Daily spending comparison (comedy edition)'),
    );
  }

  // ─────────────────────────────────────────────
  //  CANCEL ALL
  // ─────────────────────────────────────────────

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
