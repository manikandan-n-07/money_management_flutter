// lib/core/constants/app_constants.dart
// All app-wide constants, categories, tags, currencies

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Cashier';
  static const String appTagline = 'Smart Money, Smarter You';
  static const String defaultCurrency = '₹';
  static const String defaultCurrencyCode = 'INR';

  // Hive box names
  static const String expenseBox = 'expenses';
  static const String splitBox = 'splits';
  static const String budgetBox = 'budgets';
  static const String settingsBox = 'settings';

  // Settings keys
  static const String themeKey = 'theme_mode';
  static const String currencyKey = 'currency';
  static const String budgetKey = 'monthly_budget';
  static const String notifDailyKey = 'notif_daily';
  static const String notifBudgetKey = 'notif_budget';
  static const String notifMonthlyKey = 'notif_monthly';
  static const String dailyReminderHourKey = 'reminder_hour';
  static const String dailyReminderMinKey = 'reminder_min';
  static const String onboardingDoneKey = 'onboarding_done';

  // Notification IDs
  static const int dailyNotifId = 1001;
  static const int budgetNotifId = 1002;
  static const int monthlyNotifId = 1003;

  // Budget warning thresholds
  static const double budgetWarnPct = 0.60;
  static const double budgetDangerPct = 0.85;

  // Undo delete duration
  static const Duration undoDeleteDuration = Duration(seconds: 10);

  // Supported currencies
  static const List<Map<String, String>> currencies = [
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'AED', 'symbol': 'د.إ', 'name': 'UAE Dirham'},
    {'code': 'SGD', 'symbol': 'S\$', 'name': 'Singapore Dollar'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
  ];

  // Category definitions
  static const List<ExpenseCategory> categories = [
    ExpenseCategory(
      id: 'food',
      name: 'Food',
      icon: Icons.restaurant_rounded,
      color: AppColors.catFood,
      emoji: '🍕',
    ),
    ExpenseCategory(
      id: 'travel',
      name: 'Travel',
      icon: Icons.flight_rounded,
      color: AppColors.catTravel,
      emoji: '✈️',
    ),
    ExpenseCategory(
      id: 'fuel',
      name: 'Fuel',
      icon: Icons.local_gas_station_rounded,
      color: AppColors.catFuel,
      emoji: '⛽',
    ),
    ExpenseCategory(
      id: 'shopping',
      name: 'Shopping',
      icon: Icons.shopping_bag_rounded,
      color: AppColors.catShopping,
      emoji: '🛍️',
    ),
    ExpenseCategory(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      color: AppColors.catEntertainment,
      emoji: '🎬',
    ),
    ExpenseCategory(
      id: 'education',
      name: 'Education',
      icon: Icons.school_rounded,
      color: AppColors.catEducation,
      emoji: '📚',
    ),
    ExpenseCategory(
      id: 'medical',
      name: 'Medical',
      icon: Icons.local_hospital_rounded,
      color: AppColors.catMedical,
      emoji: '🏥',
    ),
    ExpenseCategory(
      id: 'bills',
      name: 'Bills',
      icon: Icons.receipt_long_rounded,
      color: AppColors.catBills,
      emoji: '📄',
    ),
    ExpenseCategory(
      id: 'subscription',
      name: 'Subscription',
      icon: Icons.subscriptions_rounded,
      color: AppColors.catSubscription,
      emoji: '🔄',
    ),
    ExpenseCategory(
      id: 'festival',
      name: 'Festival',
      icon: Icons.celebration_rounded,
      color: AppColors.catFestival,
      emoji: '🎉',
    ),
    ExpenseCategory(
      id: 'gifts',
      name: 'Gifts',
      icon: Icons.card_giftcard_rounded,
      color: AppColors.catGifts,
      emoji: '🎁',
    ),
    ExpenseCategory(
      id: 'investment',
      name: 'Investment',
      icon: Icons.trending_up_rounded,
      color: AppColors.catInvestment,
      emoji: '📈',
    ),
    ExpenseCategory(
      id: 'personal',
      name: 'Personal',
      icon: Icons.person_rounded,
      color: AppColors.catPersonal,
      emoji: '👤',
    ),
    ExpenseCategory(
      id: 'others',
      name: 'Others',
      icon: Icons.more_horiz_rounded,
      color: AppColors.catOthers,
      emoji: '•••',
    ),
  ];

  static ExpenseCategory getCategoryById(String id) {
    return categories.firstWhere(
      (c) => c.id == id,
      orElse: () => categories.last,
    );
  }

  // Popular tags
  static const List<String> popularTags = [
    '#office',
    '#trip',
    '#festival',
    '#family',
    '#work',
    '#health',
    '#weekend',
    '#daily',
    '#emergency',
    '#treat',
    '#gym',
    '#online',
    '#cash',
    '#upi',
    '#card',
  ];
}

// Immutable category definition
class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String emoji;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.emoji,
  });
}
