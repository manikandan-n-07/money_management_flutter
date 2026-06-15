// lib/core/utils/currency_formatter.dart
// Currency and number formatting utilities

import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format amount with currency symbol
  static String format(double amount, {String symbol = '₹'}) {
    final formatter = NumberFormat('#,##,##0.##', 'en_IN');
    return '$symbol${formatter.format(amount)}';
  }

  /// Format compact (e.g. ₹1.2K, ₹3.5L)
  static String formatCompact(double amount, {String symbol = '₹'}) {
    if (amount >= 10000000) {
      return '$symbol${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '$symbol${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, symbol: symbol);
  }

  /// Format percentage
  static String formatPercent(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  /// Format with sign (+/-)
  static String formatWithSign(double amount, {String symbol = '₹'}) {
    if (amount >= 0) return '+${format(amount, symbol: symbol)}';
    return format(amount, symbol: symbol);
  }

  /// Parse string to double safely
  static double parse(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
