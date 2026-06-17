import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/split_expense_model.dart';
import '../../providers/split_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/premium_app_bar.dart';
import '../../widgets/split_card.dart';
import '../../widgets/flow_entrance_animation.dart';
import 'add_split_screen.dart';
import 'split_detail_screen.dart';
import '../../providers/banner_provider.dart';
import '../../widgets/category_more_sheet.dart';

class SplitsListScreen extends ConsumerStatefulWidget {
  const SplitsListScreen({super.key});

  @override
  ConsumerState<SplitsListScreen> createState() => _SplitsListScreenState();
}

class _SplitsListScreenState extends ConsumerState<SplitsListScreen> {
  String _dateFilter = 'all';
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

  List<SplitExpenseModel> _applyFilter(List<SplitExpenseModel> splits) {
    switch (_dateFilter) {
      case 'today':
        return splits
            .where((s) => DateFormatter.isToday(s.dateTime))
            .toList();
      case 'week':
        return splits
            .where((s) => DateFormatter.isThisWeek(s.dateTime))
            .toList();
      case 'month':
        return splits
            .where((s) => DateFormatter.isThisMonth(s.dateTime))
            .toList();
      case 'year':
        return splits
            .where((s) => DateFormatter.isThisYear(s.dateTime))
            .toList();
      default:
        return splits;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allSplits = ref.watch(allSplitsProvider);
    final splits = _applyFilter(allSplits);
    final pendingAmount = ref.watch(totalPendingAmountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          PremiumSliverAppBar(
            title: 'Split Expenses',
            subtitle: DateFormat('dd MMM yyyy').format(DateTime.now()),
            emoji: '🤝',
            expandedHeight: 140,
            lightColors: const [
              Color(0xFF833AB4),
              Color(0xFF6A1FA0),
              Color(0xFF1A2980),
            ],
            darkColors: const [
              Color(0xFF1A0830),
              Color(0xFF100520),
              Color(0xFF0A0818),
            ],
            action: PremiumActionButton(
              icon: Icons.add_rounded,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddSplitScreen()),
              ),
            ),
          ),

          // Filter bar
          SliverToBoxAdapter(
            child: FlowEntranceAnimation(
              delay: const Duration(milliseconds: 50),
              child: _FilterBar(
                selected: _dateFilter,
                onChanged: (f) => setState(() => _dateFilter = f),
              ),
            ),
          ),

          if (splits.isEmpty)
            SliverFillRemaining(
              child: EmptySplits(
                onAdd: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddSplitScreen()),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildListDelegate([
                // Pending summary banner
                if (pendingAmount > 0)
                  FlowEntranceAnimation(
                    delay: const Duration(milliseconds: 50),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
                  ),

                // Quick Split category list
                FlowEntranceAnimation(
                  delay: const Duration(milliseconds: 70),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Quick Split Presets',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            ...AppConstants.categories.map((cat) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => AddSplitScreen(
                                          initialDescription: '${cat.name} Split',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: cat.color.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                              color: cat.color.withValues(alpha: 0.25)),
                                        ),
                                        child: Icon(cat.icon, color: cat.color, size: 24),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        cat.name,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            // Others / Plus Item
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => const CategoryMoreSheet(isQuickSplit: true),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25)),
                                      ),
                                      child: Icon(Icons.add_rounded, color: Theme.of(context).colorScheme.primary, size: 24),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Others',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                ...splits.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final split = entry.value;
                  return FlowEntranceAnimation(
                    delay: Duration(milliseconds: 100 + idx * 40),
                    child: SplitCard(
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
                                onPressed: () =>
                                    Navigator.pop(context, true),
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
                            ref.read(bannerNotifierProvider.notifier).show(
                              message: 'Split expense deleted',
                            );
                          }
                        }
                      },
                    ),
                  );
                }),

                const SizedBox(height: 100),
              ]),
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

class _FilterBar extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;

  const _FilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filters = ['all', 'today', 'week', 'month', 'year'];
    final labels = ['All', 'Today', 'Week', 'Month', 'Year'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(filters.length, (i) {
          final isSelected = selected == filters[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(labels[i]),
              onSelected: (_) => onChanged(filters[i]),
            ),
          );
        }),
      ),
    );
  }
}
