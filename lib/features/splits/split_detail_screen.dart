// lib/features/splits/split_detail_screen.dart
// Detailed view of a split expense with member settlement actions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/split_expense_model.dart';
import '../../models/split_member_model.dart';
import '../../providers/split_provider.dart';
import '../../services/split_service.dart';

class SplitDetailScreen extends ConsumerWidget {
  final String splitId;
  const SplitDetailScreen({super.key, required this.splitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splits = ref.watch(allSplitsProvider);
    final split = splits.firstWhere(
      (s) => s.id == splitId,
      orElse: () => SplitService.getSplit(splitId)!,
    );
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(split.description, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => showEditSplitDialog(context, ref, split),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete Split?'),
                  content: const Text(
                      'This will permanently delete this split expense.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                ref.read(splitNotifierProvider.notifier).deleteSplit(splitId);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.secondary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Text(
                    CurrencyFormatter.format(split.totalAmount,
                        symbol: split.currency),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(split.description,
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${split.payer == PayerType.me ? "Paid by me" : "Paid by ${split.friendName}"} · ${DateFormatter.formatDate(split.dateTime)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _InfoChip(
                          label: 'Paid',
                          value: CurrencyFormatter.format(split.paidAmount,
                              symbol: split.currency),
                          color: AppColors.success),
                      const SizedBox(width: 8),
                      _InfoChip(
                          label: 'Pending',
                          value: CurrencyFormatter.format(split.pendingAmount,
                              symbol: split.currency),
                          color: AppColors.error),
                      const SizedBox(width: 8),
                      _InfoChip(
                          label: 'Members',
                          value: '${split.memberCount}',
                          color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Settlement Status',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            // Member list with toggle buttons
            ...split.members.asMap().entries.map((entry) {
              final i = entry.key;
              final member = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: member.isPaid
                        ? AppColors.success.withValues(alpha: 0.4)
                        : (isDark
                            ? AppColors.darkCardBorder
                            : AppColors.lightCardBorder),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: (member.isPaid
                              ? AppColors.success
                              : AppColors.error)
                          .withValues(alpha: 0.15),
                      child: Text(
                        member.name.isNotEmpty
                            ? member.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: member.isPaid
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(member.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600)),
                          Text(
                            CurrencyFormatter.format(member.shareAmount,
                                symbol: split.currency),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (member.isPaid && member.paidAt != null)
                            Text(
                              'Paid ${DateFormatter.relativeTime(member.paidAt!)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.success),
                            ),
                        ],
                      ),
                    ),
                    Switch(
                      value: member.isPaid,
                      onChanged: (v) {
                        if (v) {
                          ref
                              .read(splitNotifierProvider.notifier)
                              .markMemberPaid(splitId, i);
                        } else {
                          ref
                              .read(splitNotifierProvider.notifier)
                              .markMemberUnpaid(splitId, i);
                        }
                      },
                      activeThumbColor: AppColors.success,
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            if (split.derivedStatus != SplitStatus.settled)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.done_all_rounded),
                  label: const Text('Mark All as Paid',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    for (int i = 0; i < split.members.length; i++) {
                      await ref
                          .read(splitNotifierProvider.notifier)
                          .markMemberPaid(splitId, i);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  static void showEditSplitDialog(BuildContext context, WidgetRef ref, SplitExpenseModel split) {
    final descController = TextEditingController(text: split.description);
    final amountController = TextEditingController(text: split.totalAmount.toStringAsFixed(2));
    final friendNameController = TextEditingController(text: split.friendName ?? '');
    PayerType tempPayer = split.payer;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Split Expense'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Total Amount',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<PayerType>(
                      initialValue: tempPayer,
                      decoration: const InputDecoration(
                        labelText: 'Payer',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: PayerType.me,
                          child: Text('Me'),
                        ),
                        DropdownMenuItem(
                          value: PayerType.friend,
                          child: Text('Friend'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            tempPayer = val;
                          });
                        }
                      },
                    ),
                    if (tempPayer == PayerType.friend) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: friendNameController,
                        decoration: const InputDecoration(
                          labelText: 'Friend Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final desc = descController.text.trim();
                    final amount = double.tryParse(amountController.text) ?? 0.0;
                    final friendName = tempPayer == PayerType.friend ? friendNameController.text.trim() : null;

                    if (desc.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a description')),
                      );
                      return;
                    }
                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid amount')),
                      );
                      return;
                    }
                    if (tempPayer == PayerType.friend && (friendName == null || friendName.isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter friend name')),
                      );
                      return;
                    }

                    // Calculate updated members shares
                    final List<SplitMemberModel> updatedMembers = [];
                    if (split.isEqualSplit) {
                      final equalShare = amount / split.members.length;
                      for (final m in split.members) {
                        updatedMembers.add(m.copyWith(shareAmount: equalShare));
                      }
                    } else {
                      final double scale = split.totalAmount > 0 ? (amount / split.totalAmount) : 1.0;
                      for (final m in split.members) {
                        updatedMembers.add(m.copyWith(shareAmount: m.shareAmount * scale));
                      }
                    }

                    final updatedSplit = split.copyWith(
                      description: desc,
                      totalAmount: amount,
                      payer: tempPayer,
                      friendName: friendName,
                      members: updatedMembers,
                    );

                    await ref.read(splitNotifierProvider.notifier).updateSplit(updatedSplit);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 13)),
            Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
