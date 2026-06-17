// lib/providers/banner_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBanner {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;
  final DateTime timestamp;

  AppBanner({
    required this.message,
    this.actionLabel,
    this.onAction,
    this.duration = const Duration(seconds: 10),
  }) : timestamp = DateTime.now();
}

class BannerNotifier extends StateNotifier<AppBanner?> {
  BannerNotifier() : super(null);
  Timer? _timer;

  void show({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 10),
  }) {
    _timer?.cancel();
    state = AppBanner(
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    );
    _timer = Timer(duration, () {
      if (state?.message == message) {
        state = null;
      }
    });
  }

  void dismiss() {
    _timer?.cancel();
    state = null;
  }
}

final bannerNotifierProvider = StateNotifierProvider<BannerNotifier, AppBanner?>((ref) {
  return BannerNotifier();
});
