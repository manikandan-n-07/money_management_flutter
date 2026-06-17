// lib/widgets/quick_add_bottom_sheet.dart
// Premium glassmorphic quick add bottom sheet overlay with custom numpad input

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/banner_provider.dart';

class QuickAddBottomSheet extends ConsumerStatefulWidget {
  final String categoryId;
  const QuickAddBottomSheet({super.key, required this.categoryId});

  @override
  ConsumerState<QuickAddBottomSheet> createState() =>
      _QuickAddBottomSheetState();
}

class _QuickAddBottomSheetState extends ConsumerState<QuickAddBottomSheet> {
  String _amountStr = '0';
  final _placeCtrl = TextEditingController();

  void _onKeyPress(String val) {
    setState(() {
      if (val == '⌫') {
        if (_amountStr.length > 1) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        } else {
          _amountStr = '0';
        }
      } else if (val == '.') {
        if (!_amountStr.contains('.')) {
          _amountStr += '.';
        }
      } else {
        if (_amountStr == '0') {
          _amountStr = val;
        } else {
          if (_amountStr.length < 8) {
            // Prevent overflow
            _amountStr += val;
          }
        }
      }
    });
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountStr) ?? 0.0;
    if (amount <= 0) {
      ref.read(bannerNotifierProvider.notifier).show(
            message: 'Please enter an amount greater than 0',
          );
      return;
    }

    final category = widget.categoryId;
    final place = _placeCtrl.text.trim();
    final settings = ref.read(settingsNotifierProvider);

    await ref.read(expenseNotifierProvider.notifier).addExpense(
          amount: amount,
          category: category,
          place: place.isNotEmpty ? place : 'Quick Log',
          dateTime: DateTime.now(),
          currency: settings.currency,
          currencyCode: settings.currencyCode,
        );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _placeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsNotifierProvider);
    final category = AppConstants.categories.firstWhere(
        (c) => c.id == widget.categoryId,
        orElse: () => AppConstants.categories.first);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xE514082E) : const Color(0xE5FFFFFF),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(
            color:
                isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header: Category Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: category.color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(category.icon, color: category.color, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        category.name.toUpperCase(),
                        style: TextStyle(
                          color: category.color,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Real-Time Amount Display
            Center(
              child: Text(
                '${settings.currency} $_amountStr',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: category.color,
                  letterSpacing: -1,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Place input field
            TextField(
              controller: _placeCtrl,
              autofocus: false,
              style: isDark
                  ? const TextStyle(color: Colors.white, fontSize: 14)
                  : const TextStyle(color: Colors.black, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Place / Note (e.g. Starbucks)',
                hintStyle:
                    TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                labelText: 'Note',
                labelStyle:
                    TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                prefixIcon: const Icon(Icons.edit_note_rounded),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Custom Numpad Grid
            Column(
              children: [
                _buildNumRow(['1', '2', '3']),
                const SizedBox(height: 8),
                _buildNumRow(['4', '5', '6']),
                const SizedBox(height: 8),
                _buildNumRow(['7', '8', '9']),
                const SizedBox(height: 8),
                _buildNumRow(['.', '0', '⌫']),
              ],
            ),
            const SizedBox(height: 18),

            // Save Action button
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check_circle_outline_rounded, size: 22),
              label: const Text(
                'LOG TRANSACTION',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    letterSpacing: 0.5),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: category.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildNumRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildNumKey(key)).toList(),
    );
  }

  Widget _buildNumKey(String key) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: () => _onKeyPress(key),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Center(
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
