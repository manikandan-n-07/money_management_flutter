// lib/features/expenses/edit_expense_screen.dart
// Edit an existing expense — pre-populated form

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/category_selector.dart';
import '../../providers/banner_provider.dart';

class EditExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseModel expense;
  const EditExpenseScreen({super.key, required this.expense});

  @override
  ConsumerState<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends ConsumerState<EditExpenseScreen> {
  late TextEditingController _amountCtrl;
  late TextEditingController _placeCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _tagCtrl;

  late String _selectedCategory;
  late DateTime _selectedDate;
  late List<String> _tags;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _amountCtrl = TextEditingController(text: e.amount.toStringAsFixed(2));
    _placeCtrl = TextEditingController(text: e.place);
    _notesCtrl = TextEditingController(text: e.notes);
    _tagCtrl = TextEditingController();
    _selectedCategory = e.category;
    _selectedDate = e.dateTime;
    _tags = List.from(e.tags);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _placeCtrl.dispose();
    _notesCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _addTag(String tag) {
    final trimmed = tag.trim();
    if (trimmed.isNotEmpty && !_tags.contains(trimmed)) {
      setState(() {
        _tags.add(trimmed.startsWith('#') ? trimmed : '#$trimmed');
      });
    }
    _tagCtrl.clear();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ref.read(bannerNotifierProvider.notifier).show(
        message: 'Enter a valid amount',
      );
      return;
    }

    setState(() => _isSaving = true);

    final updated = widget.expense.copyWith(
      amount: amount,
      category: _selectedCategory,
      place: _placeCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
      dateTime: _selectedDate,
      tags: _tags,
    );

    await ref.read(expenseNotifierProvider.notifier).updateExpense(updated);

    if (mounted) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsNotifierProvider);
    final category = AppConstants.getCategoryById(_selectedCategory);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: const Text('Save',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: category.color.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(settings.currency,
                      style: theme.textTheme.headlineLarge?.copyWith(
                          color: category.color, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: IntrinsicWidth(
                      child: TextField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                        ],
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: category.color,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                        ),
                        textAlign: TextAlign.center,
                        autofocus: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Category',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 12),
            CategorySelector(
              selectedCategoryId: _selectedCategory,
              onSelected: (id) => setState(() => _selectedCategory = id),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _placeCtrl,
              decoration: const InputDecoration(
                labelText: 'Place / Merchant',
                prefixIcon: Icon(Icons.location_on_rounded, size: 20),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  prefixIcon: Icon(Icons.calendar_today_rounded, size: 20),
                ),
                child: Text(
                  DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes',
                prefixIcon: Icon(Icons.notes_rounded, size: 20),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tagCtrl,
              decoration: InputDecoration(
                labelText: 'Add Tag',
                prefixIcon: const Icon(Icons.tag_rounded, size: 20),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
                  onPressed: () => _addTag(_tagCtrl.text),
                ),
              ),
              onSubmitted: _addTag,
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tags.map((tag) => Chip(
                      label: Text(tag,
                          style: const TextStyle(color: AppColors.primary, fontSize: 12)),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => setState(() => _tags.remove(tag)),
                    )).toList(),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Update Expense',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
