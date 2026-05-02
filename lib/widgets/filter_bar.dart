import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../providers/expense_provider.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final hasDateFilter = provider.filter.startDate != null;
    final dateRangeText = hasDateFilter
        ? '${DateFormat('dd MMM').format(provider.filter.startDate!)} - ${DateFormat('dd MMM').format(provider.filter.endDate!)}'
        : '';

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Type Filter
                    Expanded(
                      child: _FilterPopupMenu<String?>(
                        initialValue: provider.filter.type,
                        onSelected: (type) {
                          provider.filter.type = type;
                          provider.notifyFilterUpdated();
                        },
                        icon: Icons.grid_view_rounded,
                        label: provider.filter.type ?? 'Type',
                        items: const [
                          PopupMenuItem<String?>(value: null, child: Text('All Types')),
                          PopupMenuItem<String?>(value: 'Debit', child: Text('Expense')),
                          PopupMenuItem<String?>(value: 'Credit', child: Text('Income')),
                        ],
                      ),
                    ),
                    _buildSeparator(context),
                    
                    // Category Filter
                    Expanded(
                      child: _FilterPopupMenu<String?>(
                        initialValue: provider.filter.categoryId,
                        onSelected: (catId) {
                          provider.filter.categoryId = catId;
                          provider.notifyFilterUpdated();
                        },
                        icon: Icons.sell_outlined,
                        label: provider.filter.categoryId != null 
                            ? provider.allCategories.firstWhereOrNull((c) => c.id == provider.filter.categoryId)?.name ?? 'Category'
                            : 'Category',
                        items: [
                          const PopupMenuItem<String?>(value: null, child: Text('All Categories')),
                          const PopupMenuDivider(),
                          ...provider.allCategories.map(
                            (c) => PopupMenuItem<String?>(value: c.id, child: Text(c.name)),
                          ),
                        ],
                      ),
                    ),
                    _buildSeparator(context),

                    // Date Filter
                    Expanded(
                      child: InkWell(
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
                        child: _FilterItemContent(
                          icon: Icons.calendar_today_rounded,
                          label: hasDateFilter ? DateFormat('dd MMM').format(provider.filter.startDate!) : 'Date',
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasDateFilter)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        dateRangeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Reset Button
        _ResetButton(hasFilter: hasDateFilter || provider.filter.categoryId != null || provider.filter.type != null),
      ],
    );
  }

  Widget _buildSeparator(BuildContext context) {
    return Container(
      height: 20,
      width: 1,
      color: Theme.of(context).dividerColor,
    );
  }
}

class _FilterPopupMenu<T> extends StatelessWidget {
  const _FilterPopupMenu({
    required this.initialValue,
    required this.onSelected,
    required this.icon,
    required this.label,
    required this.items,
  });

  final T initialValue;
  final ValueChanged<T> onSelected;
  final IconData icon;
  final String label;
  final List<PopupMenuEntry<T>> items;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      initialValue: initialValue,
      onSelected: onSelected,
      offset: const Offset(0, 40),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => items,
      child: _FilterItemContent(icon: icon, label: label),
    );
  }
}

class _FilterItemContent extends StatelessWidget {
  const _FilterItemContent({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11, 
                color: Theme.of(context).textTheme.bodySmall?.color, 
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
