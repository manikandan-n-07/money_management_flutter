// lib/features/splits/add_split_screen.dart
// Multi-step wizard for adding a split expense

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../models/split_expense_model.dart';
import '../../models/split_member_model.dart';
import '../../providers/settings_provider.dart';
import '../../providers/split_provider.dart';

class AddSplitScreen extends ConsumerStatefulWidget {
  const AddSplitScreen({super.key});

  @override
  ConsumerState<AddSplitScreen> createState() => _AddSplitScreenState();
}

class _AddSplitScreenState extends ConsumerState<AddSplitScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  // Step 1: Payer
  PayerType _payerType = PayerType.me;
  final _friendNameCtrl = TextEditingController();

  // Step 2: Expense info
  final _totalAmountCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Step 3: Members
  final List<String> _memberNames = [];
  final _memberNameCtrl = TextEditingController();

  // Step 4: Split mode
  bool _isEqualSplit = true;
  final List<TextEditingController> _shareControllers = [];

  bool _isSaving = false;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _friendNameCtrl.dispose();
    _totalAmountCtrl.dispose();
    _descriptionCtrl.dispose();
    _memberNameCtrl.dispose();
    for (final c in _shareControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _goToPage(int page) {
    _pageCtrl.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = page);
  }

  bool _canProceedStep1() {
    if (_payerType == PayerType.friend) {
      return _friendNameCtrl.text.trim().isNotEmpty;
    }
    return true;
  }

  bool _canProceedStep2() {
    final amount =
        double.tryParse(_totalAmountCtrl.text.replaceAll(',', ''));
    return amount != null && amount > 0 && _descriptionCtrl.text.trim().isNotEmpty;
  }

  bool _canProceedStep3() => _memberNames.length >= 2;

  double get _totalAmount =>
      double.tryParse(_totalAmountCtrl.text.replaceAll(',', '')) ?? 0;

  double get _equalShare =>
      _memberNames.isEmpty ? 0 : _totalAmount / _memberNames.length;

  void _addMember(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _memberNames.contains(trimmed)) return;
    setState(() {
      _memberNames.add(trimmed);
      _shareControllers.add(TextEditingController(
          text: _equalShare.toStringAsFixed(2)));
    });
    _memberNameCtrl.clear();
  }

  void _removeMember(int index) {
    setState(() {
      _memberNames.removeAt(index);
      _shareControllers[index].dispose();
      _shareControllers.removeAt(index);
    });
  }

  void _updateShareControllers() {
    final share = _equalShare;
    for (final c in _shareControllers) {
      c.text = share.toStringAsFixed(2);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final settings = ref.read(settingsNotifierProvider);

    final members = _memberNames.asMap().entries.map((entry) {
      double share;
      if (_isEqualSplit) {
        share = _equalShare;
      } else {
        share = double.tryParse(_shareControllers[entry.key].text) ?? 0;
      }
      return SplitMemberModel(name: entry.value, shareAmount: share);
    }).toList();

    await ref.read(splitNotifierProvider.notifier).addSplit(
          payer: _payerType,
          friendName: _payerType == PayerType.friend
              ? _friendNameCtrl.text.trim()
              : null,
          totalAmount: _totalAmount,
          description: _descriptionCtrl.text.trim(),
          dateTime: _selectedDate,
          members: members,
          isEqualSplit: _isEqualSplit,
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
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle()),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / 4,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
        ),
      ),
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _Step1Payer(
            payerType: _payerType,
            friendNameCtrl: _friendNameCtrl,
            onPayerChanged: (p) => setState(() => _payerType = p),
          ),
          _Step2ExpenseInfo(
            totalAmountCtrl: _totalAmountCtrl,
            descriptionCtrl: _descriptionCtrl,
            selectedDate: _selectedDate,
            symbol: settings.currency,
            onDateChanged: (d) => setState(() => _selectedDate = d),
          ),
          _Step3Members(
            memberNames: _memberNames,
            memberNameCtrl: _memberNameCtrl,
            totalAmount: _totalAmount,
            equalShare: _equalShare,
            symbol: settings.currency,
            onAdd: _addMember,
            onRemove: _removeMember,
          ),
          _Step4SplitMode(
            memberNames: _memberNames,
            shareControllers: _shareControllers,
            totalAmount: _totalAmount,
            equalShare: _equalShare,
            isEqualSplit: _isEqualSplit,
            symbol: settings.currency,
            onModeChanged: (v) {
              setState(() {
                _isEqualSplit = v;
                if (v) _updateShareControllers();
              });
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Row(
          children: [
            if (_currentPage > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _goToPage(_currentPage - 1),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back'),
                ),
              ),
            if (_currentPage > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _canProceedCurrentStep()
                    ? (_currentPage == 3
                        ? (_isSaving ? null : _save)
                        : () => _goToPage(_currentPage + 1))
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _currentPage == 3 ? 'Create Split' : 'Next',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stepTitle() {
    switch (_currentPage) {
      case 0: return 'Who Paid?';
      case 1: return 'Expense Details';
      case 2: return 'Add Members';
      case 3: return 'Split Mode';
      default: return 'Split Expense';
    }
  }

  bool _canProceedCurrentStep() {
    switch (_currentPage) {
      case 0: return _canProceedStep1();
      case 1: return _canProceedStep2();
      case 2: return _canProceedStep3();
      case 3: return true;
      default: return false;
    }
  }
}

// === Step 1: Who Paid? ===
class _Step1Payer extends StatelessWidget {
  final PayerType payerType;
  final TextEditingController friendNameCtrl;
  final Function(PayerType) onPayerChanged;

  const _Step1Payer({
    required this.payerType,
    required this.friendNameCtrl,
    required this.onPayerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Who paid for this expense?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 8),
          Text('Select who covered the full cost.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          _PayerOption(
            label: 'Me',
            subtitle: 'I paid for everyone',
            icon: Icons.person_rounded,
            color: AppColors.primary,
            selected: payerType == PayerType.me,
            onTap: () => onPayerChanged(PayerType.me),
          ),
          const SizedBox(height: 12),
          _PayerOption(
            label: 'A Friend',
            subtitle: 'Someone else paid',
            icon: Icons.group_rounded,
            color: AppColors.secondary,
            selected: payerType == PayerType.friend,
            onTap: () => onPayerChanged(PayerType.friend),
          ),
          if (payerType == PayerType.friend) ...[
            const SizedBox(height: 20),
            TextField(
              controller: friendNameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Friend\'s Name',
                hintText: 'e.g. Rahul, Sarah...',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ],
      ),
    );
  }
}

class _PayerOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _PayerOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : AppColors.darkCardBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: color),
          ],
        ),
      ),
    );
  }
}

// === Step 2: Expense Info ===
class _Step2ExpenseInfo extends StatelessWidget {
  final TextEditingController totalAmountCtrl;
  final TextEditingController descriptionCtrl;
  final DateTime selectedDate;
  final String symbol;
  final Function(DateTime) onDateChanged;

  const _Step2ExpenseInfo({
    required this.totalAmountCtrl,
    required this.descriptionCtrl,
    required this.selectedDate,
    required this.symbol,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Expense Details',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 32),
          // Amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(symbol,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      )),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: totalAmountCtrl,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          TextField(
            controller: descriptionCtrl,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'e.g. Dinner at Barbeque Nation...',
              prefixIcon: Icon(Icons.description_rounded),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) onDateChanged(picked);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                prefixIcon: Icon(Icons.calendar_today_rounded),
              ),
              child: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
            ),
          ),
        ],
      ),
    );
  }
}

// === Step 3: Members ===
class _Step3Members extends StatelessWidget {
  final List<String> memberNames;
  final TextEditingController memberNameCtrl;
  final double totalAmount;
  final double equalShare;
  final String symbol;
  final Function(String) onAdd;
  final Function(int) onRemove;

  const _Step3Members({
    required this.memberNames,
    required this.memberNameCtrl,
    required this.totalAmount,
    required this.equalShare,
    required this.symbol,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Who\'s splitting?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
          Text('Add at least 2 people including yourself.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          if (totalAmount > 0 && memberNames.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total: $symbol${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                      '${memberNames.length} people · $symbol${equalShare.toStringAsFixed(2)} each',
                      style: const TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: memberNameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Add person\'s name...',
                    prefixIcon: Icon(Icons.person_add_rounded),
                    isDense: true,
                  ),
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: onAdd,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => onAdd(memberNameCtrl.text),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(48, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: memberNames.isEmpty
                ? Center(
                    child: Text('Add members above',
                        style: Theme.of(context).textTheme.bodyMedium),
                  )
                : ListView.builder(
                    itemCount: memberNames.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          child: Text(
                            memberNames[index][0].toUpperCase(),
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        title: Text(memberNames[index]),
                        subtitle: totalAmount > 0
                            ? Text('$symbol${equalShare.toStringAsFixed(2)}')
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_rounded,
                              color: AppColors.error),
                          onPressed: () => onRemove(index),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// === Step 4: Split Mode ===
class _Step4SplitMode extends StatelessWidget {
  final List<String> memberNames;
  final List<TextEditingController> shareControllers;
  final double totalAmount;
  final double equalShare;
  final bool isEqualSplit;
  final String symbol;
  final Function(bool) onModeChanged;

  const _Step4SplitMode({
    required this.memberNames,
    required this.shareControllers,
    required this.totalAmount,
    required this.equalShare,
    required this.isEqualSplit,
    required this.symbol,
    required this.onModeChanged,
  });

  double get _assignedTotal => shareControllers.fold(
      0.0,
      (s, c) => s + (double.tryParse(c.text) ?? 0));

  @override
  Widget build(BuildContext context) {
    final remaining = totalAmount - _assignedTotal;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How to split?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 20),
          // Mode toggle
          Row(
            children: [
              Expanded(
                child: _ModeButton(
                  label: 'Equal Split',
                  icon: Icons.balance_rounded,
                  selected: isEqualSplit,
                  color: AppColors.primary,
                  onTap: () => onModeChanged(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModeButton(
                  label: 'Custom Split',
                  icon: Icons.tune_rounded,
                  selected: !isEqualSplit,
                  color: AppColors.secondary,
                  onTap: () => onModeChanged(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!isEqualSplit)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (remaining.abs() < 0.01
                        ? AppColors.success
                        : AppColors.error)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total: $symbol${totalAmount.toStringAsFixed(2)}'),
                  Text(
                    remaining.abs() < 0.01
                        ? '✅ Balanced'
                        : '${remaining > 0 ? "Unassigned" : "Over"}: $symbol${remaining.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      color: remaining.abs() < 0.01
                          ? AppColors.success
                          : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: memberNames.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        child: Text(
                          memberNames[index][0].toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(memberNames[index],
                            style: Theme.of(context).textTheme.titleSmall),
                      ),
                      SizedBox(
                        width: 110,
                        child: TextField(
                          controller: shareControllers[index],
                          enabled: !isEqualSplit,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                          ],
                          decoration: InputDecoration(
                            prefixText: symbol,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 10),
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? color : AppColors.darkCardBorder,
              width: selected ? 2 : 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : null),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    color: selected ? color : null,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
