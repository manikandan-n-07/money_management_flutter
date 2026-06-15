// lib/widgets/category_selector.dart
// Grid + search category selector widget

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

class CategorySelector extends StatefulWidget {
  final String? selectedCategoryId;
  final Function(String categoryId) onSelected;

  const CategorySelector({
    super.key,
    this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  List<ExpenseCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return AppConstants.categories;
    return AppConstants.categories.where((c) =>
        c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search category...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 12),
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: _filteredCategories.length,
          itemBuilder: (context, index) {
            final cat = _filteredCategories[index];
            final isSelected = widget.selectedCategoryId == cat.id;
            return GestureDetector(
              onTap: () => widget.onSelected(cat.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? cat.color.withValues(alpha: 0.2)
                      : (isDark ? AppColors.darkCard : AppColors.lightCard),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: isSelected
                        ? cat.color
                        : (isDark
                            ? AppColors.darkCardBorder
                            : AppColors.lightCardBorder),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: cat.color.withValues(alpha: isSelected ? 0.25 : 0.1),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(cat.icon, color: cat.color, size: 19),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat.name,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? cat.color : null,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Compact horizontal category chip row
class CategoryChipRow extends StatelessWidget {
  final String? selectedId;
  final Function(String?) onSelected;
  final bool includeAll;

  const CategoryChipRow({
    super.key,
    this.selectedId,
    required this.onSelected,
    this.includeAll = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (includeAll)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: selectedId == null,
                label: const Text('All'),
                onSelected: (_) => onSelected(null),
              ),
            ),
          ...AppConstants.categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: selectedId == cat.id,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.icon, size: 14, color: cat.color),
                      const SizedBox(width: 4),
                      Text(cat.name),
                    ],
                  ),
                  onSelected: (_) => onSelected(cat.id),
                ),
              )),
        ],
      ),
    );
  }
}
