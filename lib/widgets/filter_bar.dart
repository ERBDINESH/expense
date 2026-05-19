import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final hasDateFilter = provider.filter.startDate != null;
    final dateRangeText = hasDateFilter
        ? '${DateFormat('dd MMM').format(provider.filter.startDate!)} - ${DateFormat('dd MMM').format(provider.filter.endDate!)}'
        : 'Select Date';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Type Segmented Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: SegmentedButton<String?>(
                          segments: const [
                            ButtonSegment(
                              value: null,
                              label: Text('All', style: TextStyle(fontSize: 11)),
                              icon: Icon(Icons.all_inclusive, size: 14),
                            ),
                            ButtonSegment(
                              value: 'Debit',
                              label: Text('Expense', style: TextStyle(fontSize: 11)),
                              icon: Icon(Icons.arrow_downward, size: 14),
                            ),
                            ButtonSegment(
                              value: 'Credit',
                              label: Text('Income', style: TextStyle(fontSize: 11)),
                              icon: Icon(Icons.arrow_upward, size: 14),
                            ),
                          ],
                          selected: {provider.filter.type},
                          onSelectionChanged: (set) {
                            provider.filter.type = set.first;
                            provider.notifyFilterUpdated();
                          },
                          showSelectedIcon: false,
                          style: SegmentedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            selectedBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            selectedForegroundColor: Theme.of(context).colorScheme.primary,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: Colors.white10),
                    // Category Chips
                    SizedBox(
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        children: [
                          ChoiceChip(
                            label: const Text('All Categories', style: TextStyle(fontSize: 11)),
                            selected: provider.filter.categoryIds.isEmpty,
                            onSelected: (selected) {
                              if (selected) {
                                provider.filter.categoryIds = [];
                                provider.notifyFilterUpdated();
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          ...provider.allCategories.map((category) {
                            final isSelected = provider.filter.categoryIds.contains(category.id);
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(category.name, style: const TextStyle(fontSize: 11)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    provider.filter.categoryIds.add(category.id);
                                  } else {
                                    provider.filter.categoryIds.remove(category.id);
                                  }
                                  provider.notifyFilterUpdated();
                                },
                                showCheckmark: false,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Colors.white10),
                    // Date Filter Button
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: Theme.of(context).colorScheme.primary,
                                  onPrimary: Colors.black,
                                  surface: Theme.of(context).cardColor,
                                  onSurface: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (range != null) {
                          provider.filter.startDate = range.start;
                          provider.filter.endDate = DateTime(
                            range.end.year,
                            range.end.month,
                            range.end.day,
                            23,
                            59,
                            59,
                          );
                          provider.notifyFilterUpdated();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 14, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              dateRangeText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: hasDateFilter ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Reset Button
            _ResetButton(hasFilter: hasDateFilter || provider.filter.categoryIds.isNotEmpty || provider.filter.type != null),
          ],
        ),
      ],
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.hasFilter});
  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ExpenseProvider>();
    return GestureDetector(
      onTap: () {
        provider.filter.reset();
        provider.notifyFilterUpdated();
      },
      child: AnimatedRotation(
        duration: const Duration(milliseconds: 500),
        turns: hasFilter ? 0 : 0.5,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hasFilter
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Theme.of(context).cardColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: hasFilter
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Icon(
            Icons.refresh_rounded, 
            color: Theme.of(context).colorScheme.primary, 
            size: 20,
          ),
        ),
      ),
    );
  }
}
