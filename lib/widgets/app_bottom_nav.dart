import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final items = [
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
      ),
      _NavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long_rounded,
        label: 'Expenses',
      ),
      _NavItem(
        icon: Icons.hub_outlined,
        activeIcon: Icons.hub_rounded,
        label: 'Splits',
      ),
      _NavItem(
        icon: Icons.pie_chart_outline_rounded,
        activeIcon: Icons.pie_chart_rounded,
        label: 'Stats',
      ),
      _NavItem(
        icon: Icons.apps_outage_outlined,
        activeIcon: Icons.apps_rounded,
        label: 'More',
      ),
    ];

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        color: Colors.transparent,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2C2C3E)
                  : Colors.grey.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;

              // Selected tab is flex 1.8, unselected is flex 1.0
              const selectedFlex = 1.8;
              const unselectedFlex = 1.0;
              const totalFlex =
                  (5 - 1) * unselectedFlex + selectedFlex; // 5 tabs total

              final unitWidth = totalWidth / totalFlex;
              final selectedWidth = unitWidth * selectedFlex;
              final unselectedWidth = unitWidth * unselectedFlex;

              final indicatorLeft = currentIndex * unselectedWidth + 6;
              final indicatorWidth = selectedWidth - 12;

              return Stack(
                children: [
                  // Sliding pill indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.fastOutSlowIn,
                    left: indicatorLeft,
                    width: indicatorWidth,
                    top: 8,
                    bottom: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.primary.withValues(alpha: 0.2)
                            : theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  // Row of items
                  Row(
                    children: List.generate(items.length, (index) {
                      final isSelected = currentIndex == index;
                      final item = items[index];

                      return Expanded(
                        flex: isSelected ? 18 : 10,
                        child: GestureDetector(
                          onTap: () => onTap(index),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: isSelected
                                  ? OverflowBox(
                                      key: ValueKey('selected_$index'),
                                      minWidth: 0,
                                      maxWidth: double.infinity,
                                      minHeight: 0,
                                      maxHeight: double.infinity,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            item.activeIcon,
                                            color: theme.colorScheme.primary,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            item.label,
                                            style: TextStyle(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Icon(
                                      key: ValueKey('unselected_$index'),
                                      item.icon,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black54,
                                      size: 22,
                                    ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
