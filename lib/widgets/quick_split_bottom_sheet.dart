// lib/widgets/quick_split_bottom_sheet.dart
// Premium glassmorphic quick split bottom sheet overlay with custom numpad input

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/split_expense_model.dart';
import '../models/split_member_model.dart';
import '../providers/split_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/banner_provider.dart';

class QuickSplitBottomSheet extends ConsumerStatefulWidget {
  final String categoryId;
  const QuickSplitBottomSheet({super.key, required this.categoryId});

  @override
  ConsumerState<QuickSplitBottomSheet> createState() => _QuickSplitBottomSheetState();
}

class _QuickSplitBottomSheetState extends ConsumerState<QuickSplitBottomSheet> {
  String _amountStr = '0';
  final _descCtrl = TextEditingController();
  final _friendCtrl = TextEditingController(text: 'Friend');
  PayerType _payer = PayerType.me;

  @override
  void initState() {
    super.initState();
    final category = AppConstants.getCategoryById(widget.categoryId);
    _descCtrl.text = '${category.name} Split';
  }

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

    final description = _descCtrl.text.trim();
    final friendName = _friendCtrl.text.trim();
    final settings = ref.read(settingsNotifierProvider);

    final members = [
      SplitMemberModel(
        name: 'Me',
        shareAmount: amount / 2,
        isPaid: _payer == PayerType.me,
        paidAt: _payer == PayerType.me ? DateTime.now() : null,
      ),
      SplitMemberModel(
        name: friendName.isNotEmpty ? friendName : 'Friend',
        shareAmount: amount / 2,
        isPaid: _payer == PayerType.friend,
        paidAt: _payer == PayerType.friend ? DateTime.now() : null,
      ),
    ];

    await ref.read(splitNotifierProvider.notifier).addSplit(
          payer: _payer,
          friendName: friendName.isNotEmpty ? friendName : 'Friend',
          totalAmount: amount,
          description: description.isNotEmpty ? description : 'Quick Split',
          dateTime: DateTime.now(),
          members: members,
          isEqualSplit: true,
          currency: settings.currency,
          currencyCode: settings.currencyCode,
        );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _friendCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsNotifierProvider);
    final category = AppConstants.getCategoryById(widget.categoryId);
    final amount = double.tryParse(_amountStr) ?? 0.0;
    final halfAmount = amount / 2;

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
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
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

            // Header: Preset Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: category.color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        'QUICK SPLIT',
                        style: TextStyle(
                          color: category.color,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Real-Time Split Display
            Center(
              child: Text(
                '${settings.currency} $_amountStr',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: category.color,
                  letterSpacing: -1,
                ),
              ),
            ),
            if (amount > 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Split 50/50: ${settings.currency}${halfAmount.toStringAsFixed(0)} each',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Form Fields: Friend + Description
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _friendCtrl,
                    style: isDark ? const TextStyle(color: Colors.white, fontSize: 13) : const TextStyle(color: Colors.black, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'With Who',
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12),
                      prefixIcon: const Icon(Icons.person_rounded, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _descCtrl,
                    style: isDark ? const TextStyle(color: Colors.white, fontSize: 13) : const TextStyle(color: Colors.black, fontSize: 13),
                    decoration: InputDecoration(
                      labelText: 'For What',
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 12),
                      prefixIcon: const Icon(Icons.description_rounded, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Who Paid Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Who Paid:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('I Paid', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      selected: _payer == PayerType.me,
                      onSelected: (sel) {
                        if (sel) setState(() => _payer = PayerType.me);
                      },
                      selectedColor: category.color.withValues(alpha: 0.2),
                      labelStyle: TextStyle(color: _payer == PayerType.me ? category.color : Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('They Paid', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      selected: _payer == PayerType.friend,
                      onSelected: (sel) {
                        if (sel) setState(() => _payer = PayerType.friend);
                      },
                      selectedColor: category.color.withValues(alpha: 0.2),
                      labelStyle: TextStyle(color: _payer == PayerType.friend ? category.color : Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

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
              icon: const Icon(Icons.group_add_rounded, size: 20),
              label: const Text(
                'LOG QUICK SPLIT',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: category.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Center(
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 16,
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
