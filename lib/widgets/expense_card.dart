// lib/widgets/expense_card.dart
// Premium expense card with swipe actions (delete left, edit right)

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../models/expense_model.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = AppConstants.getCategoryById(expense.category);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget card = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(category.icon, color: category.color, size: 22),
            ),
            const SizedBox(width: 13),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.place.isEmpty ? category.name : expense.place,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          category.name,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: category.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          DateFormatter.formatShortDateTime(expense.dateTime),
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  // Tags
                  if (expense.tags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      expense.tags.join(' '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.format(expense.amount,
                      symbol: expense.currency),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    fontSize: 15,
                  ),
                ),
                if (expense.notes.isNotEmpty)
                  Text(
                    expense.notes.length > 18
                        ? '${expense.notes.substring(0, 18)}...'
                        : expense.notes,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    // Swipe to delete/edit
    if (onDelete != null || onEdit != null) {
      return Dismissible(
        key: ValueKey(expense.id),
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
}
