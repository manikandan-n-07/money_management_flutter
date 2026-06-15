// lib/widgets/split_card.dart
// Split expense card with status chips and settlement info

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../models/split_expense_model.dart';

class SplitCard extends StatelessWidget {
  final SplitExpenseModel split;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const SplitCard({
    super.key,
    required this.split,
    this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = split.derivedStatus;

    Widget card = GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _statusColor(status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    split.payer == PayerType.me
                        ? Icons.person_rounded
                        : Icons.group_rounded,
                    color: _statusColor(status),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        split.description,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        split.payer == PayerType.friend && split.friendName != null
                            ? 'Paid by ${split.friendName}'
                            : 'Paid by Me',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(split.totalAmount,
                          symbol: split.currency),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StatusChip(status: status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Member avatars row
            Row(
              children: [
                Expanded(
                  child: _MemberAvatarRow(split: split),
                ),
                Text(
                  DateFormatter.formatShortDate(split.dateTime),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            // Settlement bar
            if (status != SplitStatus.settled) ...[
              const SizedBox(height: 10),
              _SettlementBar(split: split),
            ],
          ],
        ),
      ),
    );

    if (onDelete != null || onEdit != null) {
      return Dismissible(
        key: ValueKey(split.id),
        background: _buildEditBackground(),
        secondaryBackground: _buildDeleteBackground(),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd && onEdit != null) {
            onEdit!();
            return false;
          }
          if (direction == DismissDirection.endToStart && onDelete != null) {
            onDelete!();
            return false;
          }
          return false;
        },
        child: card,
      );
    }

    return card;
  }

  Widget _buildEditBackground() {
    return Container(
      color: AppColors.info.withValues(alpha: 0.15),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      child: const Row(
        children: [
          Icon(Icons.edit_rounded, color: AppColors.info),
          SizedBox(width: 8),
          Text('Edit',
              style: TextStyle(
                  color: AppColors.info, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      color: AppColors.error.withValues(alpha: 0.15),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Delete',
              style: TextStyle(
                  color: AppColors.error, fontWeight: FontWeight.w600)),
          SizedBox(width: 8),
          Icon(Icons.delete_rounded, color: AppColors.error),
        ],
      ),
    );
  }

  Color _statusColor(SplitStatus status) {
    switch (status) {
      case SplitStatus.pending:
        return AppColors.error;
      case SplitStatus.partiallyPaid:
        return AppColors.warning;
      case SplitStatus.settled:
        return AppColors.success;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final SplitStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case SplitStatus.pending:
        color = AppColors.error;
        label = 'Pending';
        icon = Icons.schedule_rounded;
        break;
      case SplitStatus.partiallyPaid:
        color = AppColors.warning;
        label = 'Partial';
        icon = Icons.hourglass_bottom_rounded;
        break;
      case SplitStatus.settled:
        color = AppColors.success;
        label = 'Settled';
        icon = Icons.check_circle_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberAvatarRow extends StatelessWidget {
  final SplitExpenseModel split;
  const _MemberAvatarRow({required this.split});

  @override
  Widget build(BuildContext context) {
    final members = split.members;
    return Row(
      children: [
        ...members.take(5).map((m) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Tooltip(
                message: '${m.name}: ${m.isPaid ? "Paid" : "Pending"}',
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: m.isPaid
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.error.withValues(alpha: 0.2),
                  child: Text(
                    m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: m.isPaid ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ),
            )),
        if (members.length > 5)
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              '+${members.length - 5}',
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary),
            ),
          ),
        const SizedBox(width: 8),
        Text(
          '${split.paidCount}/${members.length} paid',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _SettlementBar extends StatelessWidget {
  final SplitExpenseModel split;
  const _SettlementBar({required this.split});

  @override
  Widget build(BuildContext context) {
    final progress =
        split.totalAmount > 0 ? split.paidAmount / split.totalAmount : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Collected: ${split.currency}${split.paidAmount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              'Pending: ${split.currency}${split.pendingAmount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.error.withValues(alpha: 0.15),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.success),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}
