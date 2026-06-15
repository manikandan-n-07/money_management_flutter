// lib/features/expenses/add_expense_screen.dart
// Premium expense entry form with large amount input, category grid, tags

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/category_selector.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const AddExpenseScreen({super.key, this.initialCategory});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen>
    with SingleTickerProviderStateMixin {
  final _amountCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();

  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  final List<String> _tags = [];
  bool _isSaving = false;

  late AnimationController _animCtrl;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'food';
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _placeCtrl.dispose();
    _notesCtrl.dispose();
    _tagCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
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
    final amountStr = _amountCtrl.text.replaceAll(',', '');
    final amount = double.tryParse(amountStr);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final settings = ref.read(settingsNotifierProvider);

    await ref.read(expenseNotifierProvider.notifier).addExpense(
          amount: amount,
          category: _selectedCategory!,
          place: _placeCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
          dateTime: _selectedDate,
          tags: _tags,
          currency: settings.currency,
          currencyCode: settings.currencyCode,
        );

    if (mounted) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsNotifierProvider);
    final category = _selectedCategory != null
        ? AppConstants.getCategoryById(_selectedCategory!)
        : null;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Add Expense'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _slideAnim,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 40 * _slideAnim.value),
            child: Opacity(
              opacity: (1 - _slideAnim.value).clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Amount Input ===
              _buildAmountSection(settings.currency, category),
              const SizedBox(height: 24),

              // === Category ===
              _buildSectionHeader('Category'),
              const SizedBox(height: 12),
              CategorySelector(
                selectedCategoryId: _selectedCategory,
                onSelected: (id) => setState(() => _selectedCategory = id),
              ),
              const SizedBox(height: 24),

              // === Place ===
              _buildSectionHeader('Place / Merchant'),
              const SizedBox(height: 8),
              TextField(
                controller: _placeCtrl,
                decoration: const InputDecoration(
                  hintText: 'e.g. Starbucks, Amazon, Zomato...',
                  prefixIcon: Icon(Icons.location_on_rounded, size: 20),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),

              // === Date ===
              _buildSectionHeader('Date'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isDark
                            ? AppColors.darkCardBorder
                            : AppColors.lightCardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy')
                            .format(_selectedDate),
                        style: theme.textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // === Notes ===
              _buildSectionHeader('Notes (Optional)'),
              const SizedBox(height: 8),
              TextField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  hintText: 'Add any notes...',
                  prefixIcon: Icon(Icons.notes_rounded, size: 20),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),

              // === Tags ===
              _buildSectionHeader('Tags (Optional)'),
              const SizedBox(height: 8),
              TextField(
                controller: _tagCtrl,
                decoration: InputDecoration(
                  hintText: '#office, #trip, #festival...',
                  prefixIcon:
                      const Icon(Icons.tag_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add_circle_rounded,
                        color: AppColors.primary),
                    onPressed: () => _addTag(_tagCtrl.text),
                  ),
                ),
                onSubmitted: _addTag,
              ),
              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _tags.map((tag) => Chip(
                    label: Text(tag,
                        style: const TextStyle(
                            color: AppColors.primary, fontSize: 12)),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    deleteIcon: const Icon(Icons.close, size: 14,
                        color: AppColors.primary),
                    onDeleted: () =>
                        setState(() => _tags.remove(tag)),
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
              ],
              const SizedBox(height: 8),
              // Popular tags
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: AppConstants.popularTags.take(8).map((tag) {
                  if (_tags.contains(tag)) return const SizedBox.shrink();
                  return GestureDetector(
                    onTap: () => _addTag(tag),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(tag,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary.withValues(alpha: 0.8),
                          )),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_rounded),
                  label: const Text('Save Expense',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountSection(String symbol, ExpenseCategory? category) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: category != null
            ? LinearGradient(
                colors: [
                  category.color.withValues(alpha: 0.15),
                  category.color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: category == null
            ? (isDark ? AppColors.darkCard : AppColors.lightCard)
            : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: category != null
              ? category.color.withValues(alpha: 0.3)
              : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
        ),
      ),
      child: Column(
        children: [
          if (category != null) ...[
            Icon(category.icon, color: category.color, size: 32),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                symbol,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: category?.color ?? AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: IntrinsicWidth(
                  child: TextField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[\d.]')),
                    ],
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: category?.color ?? AppColors.primary,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textAlign: TextAlign.center,
                    autofocus: true,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
    );
  }
}
