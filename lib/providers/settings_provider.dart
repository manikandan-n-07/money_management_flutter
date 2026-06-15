// lib/providers/settings_provider.dart
// App settings backed by SharedPreferences

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class SettingsState {
  final String currency;
  final String currencyCode;
  final bool notifDaily;
  final bool notifBudget;
  final bool notifMonthly;
  final int dailyReminderHour;
  final int dailyReminderMin;
  final String userName;

  const SettingsState({
    this.currency = '₹',
    this.currencyCode = 'INR',
    this.notifDaily = true,
    this.notifBudget = true,
    this.notifMonthly = true,
    this.dailyReminderHour = 21,
    this.dailyReminderMin = 0,
    this.userName = '',
  });

  SettingsState copyWith({
    String? currency,
    String? currencyCode,
    bool? notifDaily,
    bool? notifBudget,
    bool? notifMonthly,
    int? dailyReminderHour,
    int? dailyReminderMin,
    String? userName,
  }) {
    return SettingsState(
      currency: currency ?? this.currency,
      currencyCode: currencyCode ?? this.currencyCode,
      notifDaily: notifDaily ?? this.notifDaily,
      notifBudget: notifBudget ?? this.notifBudget,
      notifMonthly: notifMonthly ?? this.notifMonthly,
      dailyReminderHour: dailyReminderHour ?? this.dailyReminderHour,
      dailyReminderMin: dailyReminderMin ?? this.dailyReminderMin,
      userName: userName ?? this.userName,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      currency: prefs.getString(AppConstants.currencyKey) ?? '₹',
      currencyCode: prefs.getString('currency_code') ?? 'INR',
      notifDaily: prefs.getBool(AppConstants.notifDailyKey) ?? true,
      notifBudget: prefs.getBool(AppConstants.notifBudgetKey) ?? true,
      notifMonthly: prefs.getBool(AppConstants.notifMonthlyKey) ?? true,
      dailyReminderHour: prefs.getInt(AppConstants.dailyReminderHourKey) ?? 21,
      dailyReminderMin: prefs.getInt(AppConstants.dailyReminderMinKey) ?? 0,
      userName: prefs.getString('user_name') ?? '',
    );
  }

  Future<void> setUserName(String name) async {
    state = state.copyWith(userName: name);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  Future<void> setCurrency(String symbol, String code) async {
    state = state.copyWith(currency: symbol, currencyCode: code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.currencyKey, symbol);
    await prefs.setString('currency_code', code);
  }

  Future<void> setNotifDaily(bool value) async {
    state = state.copyWith(notifDaily: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.notifDailyKey, value);
  }

  Future<void> setNotifBudget(bool value) async {
    state = state.copyWith(notifBudget: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.notifBudgetKey, value);
  }

  Future<void> setNotifMonthly(bool value) async {
    state = state.copyWith(notifMonthly: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.notifMonthlyKey, value);
  }

  Future<void> setDailyReminderTime(int hour, int minute) async {
    state = state.copyWith(dailyReminderHour: hour, dailyReminderMin: minute);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.dailyReminderHourKey, hour);
    await prefs.setInt(AppConstants.dailyReminderMinKey, minute);
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

final currencySymbolProvider = Provider<String>((ref) {
  return ref.watch(settingsNotifierProvider).currency;
});
