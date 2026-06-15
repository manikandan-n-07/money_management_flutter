// lib/providers/theme_provider.dart
// Theme mode provider backed by SharedPreferences

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> with WidgetsBindingObserver {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.themeKey);
    if (saved == 'light') {
      state = ThemeMode.light;
    } else if (saved == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  @override
  void didChangePlatformBrightness() {
    if (state == ThemeMode.system) {
      // Trigger a state update so Riverpod consumers rebuild reactively
      state = ThemeMode.system;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeKey, mode.name);
  }

  Future<void> toggleTheme() async {
    final currentIsDark = state == ThemeMode.system
        ? (PlatformDispatcher.instance.platformBrightness == Brightness.dark)
        : (state == ThemeMode.dark);
    final next = currentIsDark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(next);
  }

  bool get isDark {
    if (state == ThemeMode.system) {
      return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    }
    return state == ThemeMode.dark;
  }
}

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

final isDarkModeProvider = Provider<bool>((ref) {
  final mode = ref.watch(themeNotifierProvider);
  if (mode == ThemeMode.system) {
    return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
  }
  return mode == ThemeMode.dark;
});
