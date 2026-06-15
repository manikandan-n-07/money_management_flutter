// lib/features/reports/reports_screen.dart
// Export PDF and Excel reports

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/split_provider.dart';
import '../../services/export_service.dart';
import '../../core/utils/currency_formatter.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final symbol = ref.watch(currencySymbolProvider);
    final expenses = ref.watch(allExpensesProvider);
    final splits = ref.watch(allSplitsProvider);
    final monthTotal = ref.watch(thisMonthTotalProvider);
    final grandTotal = ref.watch(grandTotalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary preview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9D97FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.assessment_rounded,
                          color: Colors.white, size: 28),
                      SizedBox(width: 10),
                      Text('Report Summary',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _SummaryItem(
                          label: 'Total Expenses',
                          value: CurrencyFormatter.format(grandTotal,
                              symbol: symbol)),
                      _SummaryItem(
                          label: 'This Month',
                          value: CurrencyFormatter.format(monthTotal,
                              symbol: symbol)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _SummaryItem(
                          label: 'Transactions',
                          value: '${expenses.length}'),
                      _SummaryItem(
                          label: 'Splits',
                          value: '${splits.length}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Export Options',
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            // PDF Card
            _ExportCard(
              title: 'Export PDF Report',
              description:
                  'Professional report with summary, expense table, and split expense table.',
              icon: Icons.picture_as_pdf_rounded,
              color: AppColors.error,
              features: const [
                'Cover page with summary',
                'Complete expense list',
                'Split expense table',
                'Logo & branding',
              ],
              buttonLabel: 'Export PDF',
              onExport: () => _exportPDF(context),
            ),
            const SizedBox(height: 12),
            // Excel Card
            _ExportCard(
              title: 'Export Excel Sheet',
              description:
                  'Spreadsheet with expenses, splits, and statistics on separate sheets.',
              icon: Icons.table_chart_rounded,
              color: AppColors.success,
              features: const [
                'Expenses sheet',
                'Split expenses sheet',
                'Monthly statistics sheet',
              ],
              buttonLabel: 'Export Excel',
              onExport: () => _exportExcel(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPDF(BuildContext context) async {
    try {
      _showLoadingSnackbar(context, 'Generating PDF...');
      await ExportService.exportPDF();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF export failed: $e')),
        );
      }
    }
  }

  Future<void> _exportExcel(BuildContext context) async {
    try {
      _showLoadingSnackbar(context, 'Generating Excel...');
      await ExportService.exportExcel();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Excel export failed: $e')),
        );
      }
    }
  }

  void _showLoadingSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white)),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        duration: const Duration(seconds: 10),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 11)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
        ],
      ),
    );
  }
}

class _ExportCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;
  final String buttonLabel;
  final VoidCallback onExport;

  const _ExportCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
    required this.buttonLabel,
    required this.onExport,
  });

  @override
  State<_ExportCard> createState() => _ExportCardState();
}

class _ExportCardState extends State<_ExportCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.color.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(widget.icon, color: widget.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700)),
                    Text(widget.description,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 14, color: widget.color),
                    const SizedBox(width: 6),
                    Text(f, style: theme.textTheme.bodySmall),
                  ],
                ),
              )),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      await Future.delayed(const Duration(milliseconds: 200));
                      widget.onExport();
                      await Future.delayed(const Duration(seconds: 2));
                      if (mounted) setState(() => _loading = false);
                    },
              icon: _loading
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Icon(widget.icon, size: 18),
              label: Text(widget.buttonLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              style: FilledButton.styleFrom(
                backgroundColor: widget.color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
