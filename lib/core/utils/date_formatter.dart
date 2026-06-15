// lib/core/utils/date_formatter.dart
// Date and time formatting utilities

import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(DateTime dt) {
    return DateFormat('dd MMM yyyy').format(dt);
  }

  static String formatDateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  static String formatShortDateTime(DateTime dt) {
    return DateFormat('dd MMM, hh:mm a').format(dt);
  }

  static String formatTime(DateTime dt) {
    return DateFormat('hh:mm a').format(dt);
  }

  static String formatMonthYear(DateTime dt) {
    return DateFormat('MMMM yyyy').format(dt);
  }

  static String formatShortDate(DateTime dt) {
    return DateFormat('dd MMM').format(dt);
  }

  static String formatDayOfWeek(DateTime dt) {
    return DateFormat('EEE').format(dt);
  }

  static String formatMonthShort(DateTime dt) {
    return DateFormat('MMM').format(dt);
  }

  static String relativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(dt);
  }

  static String groupHeader(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    if (now.difference(dt).inDays < 7) return DateFormat('EEEE').format(dt);
    return DateFormat('dd MMMM yyyy').format(dt);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime dt) => isSameDay(dt, DateTime.now());

  static bool isThisWeek(DateTime dt) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return dt.isAfter(startOfWeek.subtract(const Duration(days: 1)));
  }

  static bool isThisMonth(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month;
  }

  static bool isThisYear(DateTime dt) {
    return dt.year == DateTime.now().year;
  }

  static DateTime startOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  static DateTime endOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day, 23, 59, 59);

  static DateTime startOfWeek(DateTime dt) {
    return dt.subtract(Duration(days: dt.weekday - 1));
  }

  static DateTime startOfMonth(DateTime dt) =>
      DateTime(dt.year, dt.month, 1);

  static DateTime endOfMonth(DateTime dt) =>
      DateTime(dt.year, dt.month + 1, 0, 23, 59, 59);

  static DateTime startOfYear(DateTime dt) => DateTime(dt.year, 1, 1);

  static List<DateTime> getLast7Days() {
    final now = DateTime.now();
    return List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
  }

  static List<DateTime> getLast12Months() {
    final now = DateTime.now();
    return List.generate(
        12, (i) => DateTime(now.year, now.month - 11 + i, 1));
  }
}
