// lib/features/budget/budget_screen.dart
// Monthly budget planner with progress and projections

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/budget_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/budget_service.dart';
import '../../widgets/budget_progress_bar.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _budgetCtrl = TextEditingController();
  final _savingsCtrl = TextEditingController();
  bool _showForm = false;

  @override
  void dispose() {
    _budgetCtrl.dispose();
    _savingsCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    final budget = double.tryParse(_budgetCtrl.text.replaceAll(',', ''));
    final savings =
        double.tryParse(_savingsCtrl.text.replaceAll(',', '')) ?? 0.0;

    if (budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid budget amount')),
      );
      return;
    }

    await ref.read(budgetNotifierProvider.notifier).setBudget(
          monthlyBudget: budget,
          savingsGoal: savings,
        );

    if (mounted) {
      setState(() => _showForm = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Budget updated!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final symbol = ref.watch(currencySymbolProvider);
    final budget = ref.watch(currentBudgetProvider);
    final spent = ref.watch(thisMonthSpentProvider);
    final progress = ref.watch(budgetProgressProvider);
    final level = ref.watch(budgetLevelProvider);

    final projectedTotal = BudgetService.getProjectedMonthTotal();
    final dailyRate = BudgetService.getDailySpendRate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Planner'),
        actions: [
          IconButton(
            icon: Icon(
              _showForm ? Icons.close_rounded : Icons.edit_rounded,
              color: AppColors.primary,
            ),
            onPressed: () {
              if (budget != null) {
                _budgetCtrl.text = budget.monthlyBudget.toStringAsFixed(0);
                _savingsCtrl.text = budget.savingsGoal.toStringAsFixed(0);
              }
              setState(() => _showForm = !_showForm);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget form
            if (_showForm) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Set Monthly Budget',
                        style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _budgetCtrl,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Monthly Budget',
                        prefixText: '$symbol ',
                        prefixIcon: const Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _savingsCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Savings Goal (Optional)',
                        prefixText: '$symbol ',
                        prefixIcon: const Icon(Icons.savings_rounded,
                            size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saveBudget,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Save Budget',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // No budget set
            if (budget == null && !_showForm) ...[
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 36,
                          color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text('No budget set',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      'Set a monthly budget to track\nhow much you\'re spending.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => setState(() => _showForm = true),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Set Budget',
                          style:
                              TextStyle(fontWeight: FontWeight.w700)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Budget set — show progress
            if (budget != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _levelColor(level).withValues(alpha: 0.3),
                  ),
                ),
                child: BudgetProgressBar(
                  budget: budget.monthlyBudget,
                  spent: spent,
                  symbol: symbol,
                ),
              ),
              const SizedBox(height: 16),

              // Spending breakdown cards
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: 'Daily Avg',
                      value: '$symbol${dailyRate.toStringAsFixed(0)}',
                      color: AppColors.primary,
                      icon: Icons.today_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBox(
                      label: 'Projected Month',
                      value: '$symbol${projectedTotal.toStringAsFixed(0)}',
                      color: projectedTotal > budget.monthlyBudget
                          ? AppColors.error
                          : AppColors.success,
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatBox(
                      label: 'Budget',
                      value: '$symbol${budget.monthlyBudget.toStringAsFixed(0)}',
                      color: AppColors.accentBlue,
                      icon: Icons.account_balance_wallet_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (budget.savingsGoal > 0)
                    Expanded(
                      child: _StatBox(
                        label: 'Savings Goal',
                        value:
                            '$symbol${budget.savingsGoal.toStringAsFixed(0)}',
                        color: AppColors.secondary,
                        icon: Icons.savings_rounded,
                      ),
                    )
                  else
                    const Expanded(child: SizedBox()),
                ],
              ),
              const SizedBox(height: 20),

              // Warning / Tip
              _BudgetAdvice(level: level, progress: progress),
            ],
          ],
        ),
      ),
    );
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'danger': return AppColors.budgetDanger;
      case 'warning': return AppColors.budgetWarning;
      default: return AppColors.budgetSafe;
    }
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          Text(label,
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

class _BudgetAdvice extends StatelessWidget {
  final String level;
  final double progress;

  const _BudgetAdvice({required this.level, required this.progress});

  @override
  Widget build(BuildContext context) {
    Color color;
    String message;
    IconData icon;

    switch (level) {
      case 'danger':
        color = AppColors.budgetDanger;
        icon = Icons.warning_rounded;
        message =
            'You\'ve used ${(progress * 100).toStringAsFixed(0)}% of your budget. Slow down on spending to avoid going over!';
        break;
      case 'warning':
        color = AppColors.budgetWarning;
        icon = Icons.info_rounded;
        message =
            'You\'re at ${(progress * 100).toStringAsFixed(0)}% of your budget. Be mindful of your remaining spend.';
        break;
      default:
        color = AppColors.budgetSafe;
        icon = Icons.check_circle_rounded;
        message =
            'You\'re on track! ${(progress * 100).toStringAsFixed(0)}% of budget used. Keep it up! 🎉';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    )),
          ),
        ],
      ),
    );
  }
}
