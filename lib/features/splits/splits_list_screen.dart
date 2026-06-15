import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/split_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/split_card.dart';
import 'add_split_screen.dart';
import 'split_detail_screen.dart';

class SplitsListScreen extends ConsumerStatefulWidget {
  const SplitsListScreen({super.key});

  @override
  ConsumerState<SplitsListScreen> createState() => _SplitsListScreenState();
}

class _SplitsListScreenState extends ConsumerState<SplitsListScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final splits = ref.watch(allSplitsProvider);
    final pendingAmount = ref.watch(totalPendingAmountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Split Expenses'),
            const SizedBox(height: 2),
            Text(
              DateFormat('dd MMMM yyyy, hh:mm a').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddSplitScreen()),
            ),
          ),
        ],
      ),
      body: splits.isEmpty
          ? EmptySplits(
              onAdd: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddSplitScreen()),
              ),
            )
          : Column(
              children: [
                // Pending summary banner
                if (pendingAmount > 0)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total Pending',
                                  style: TextStyle(
                                      fontSize: 11, color: AppColors.error)),
                              Text(
                                '₹${pendingAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${ref.watch(pendingSplitsProvider).length} active',
                          style: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: splits.length,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemBuilder: (context, index) {
                      final split = splits[index];
                      return SplitCard(
                        split: split,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                SplitDetailScreen(splitId: split.id),
                          ),
                        ),
                        onEdit: () {
                          SplitDetailScreen.showEditSplitDialog(
                              context, ref, split);
                        },
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              title: const Text('Delete Split?'),
                              content: Text(
                                  'Are you sure you want to permanently delete "${split.description}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.error),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            ref
                                .read(splitNotifierProvider.notifier)
                                .deleteSplit(split.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Split expense deleted')),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: Navigator.canPop(context)
          ? FloatingActionButton(
              heroTag: 'fab_splits_list_add',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddSplitScreen()),
              ),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
    );
  }
}
