import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key, this.compact = false});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final hasDateFilter = provider.filter.startDate != null;
    final hasCategoryFilter = provider.filter.categoryIds.isNotEmpty;
    final hasTypeFilter = provider.filter.types.isNotEmpty;
    final hasAnyFilter = hasDateFilter || hasCategoryFilter || hasTypeFilter;

    if (compact) {
      return Row(
        children: [
          Expanded(
            child: hasAnyFilter
                ? _FilterDisplay(provider: provider)
                : Text(
                    'All transactions',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: IconButton(
              onPressed: () => _openMobileFilterSheet(context),
              icon: Icon(Icons.filter_list_rounded, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: hasAnyFilter
                ? () {
                    provider.filter.reset();
                    provider.notifyFilterUpdated();
                  }
                : null,
            child: const Text('Clear'),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Leading Clear Button
        GestureDetector(
          onTap: () {
            provider.filter.reset();
            provider.notifyFilterUpdated();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasAnyFilter 
                  ? Theme.of(context).colorScheme.error.withValues(alpha: 0.1) 
                  : Theme.of(context).cardColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: hasAnyFilter 
                    ? Theme.of(context).colorScheme.error.withValues(alpha: 0.2) 
                    : Theme.of(context).dividerColor,
              ),
            ),
            child: Icon(
              Icons.close_rounded,
              size: 20,
              color: hasAnyFilter ? Theme.of(context).colorScheme.error : Colors.white24,
            ),
          ),
        ),
        const SizedBox(width: 10),
        
        // Filter Segments as a single "Button"
        Expanded(
          child: GestureDetector(
            onTap: () => _openMobileFilterSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_list_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: hasAnyFilter
                        ? _FilterDisplay(provider: provider)
                        : Text(
                            'Apply Filter', 
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6), 
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.unfold_more_rounded, size: 18, color: Colors.white24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openMobileFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        top: false,
        bottom: true,
        child: const _MobileFilterSheet(),
      ),
    );
  }
}

class _FilterDisplay extends StatelessWidget {
  const _FilterDisplay({required this.provider});
  final ExpenseProvider provider;

  String _formatDateRange(DateTime start, DateTime end) {
    final format = DateFormat('dd MMM yyyy');
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return format.format(start);
    }
    return '${format.format(start)} - ${format.format(end)}';
  }

  TextStyle _labelStyle(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 13,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final types = provider.filter.types;
    final catCount = provider.filter.categoryIds.length;
    final dateText = provider.filter.startDate != null
        ? _formatDateRange(provider.filter.startDate!, provider.filter.endDate ?? provider.filter.startDate!)
        : null;
    final txnsCount = provider.filteredTransactions.length;

    final children = <Widget>[];
    if (types.isNotEmpty) {
      children.add(Text(types.map((t) => t == 'Debit' ? 'Exp' : 'Inc').join(','), style: _labelStyle(context)));
    }
    if (catCount > 0) {
      children.add(Text('$catCount Cat', style: _labelStyle(context)));
    }
    if (dateText != null) {
      children.add(Text(dateText, style: _labelStyle(context)));
    }
    children.add(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text('$txnsCount', style: _labelStyle(context)),
        ],
      ),
    );

    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

class _MobileFilterSheet extends StatefulWidget {
  const _MobileFilterSheet({super.key});

  @override
  State<_MobileFilterSheet> createState() => _MobileFilterSheetState();
}

class _MobileFilterSheetState extends State<_MobileFilterSheet> {
  late ExpenseProvider provider;
  late List<String> selectedTypes;
  late List<String> selectedCategories;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    provider = context.read<ExpenseProvider>();
    selectedTypes = List.from(provider.filter.types);
    selectedCategories = List.from(provider.filter.categoryIds);
    startDate = provider.filter.startDate;
    endDate = provider.filter.endDate;
  }

  void _apply() {
    provider.filter.types = List.from(selectedTypes);
    provider.filter.categoryIds = List.from(selectedCategories);
    provider.filter.startDate = startDate;
    provider.filter.endDate = endDate;
    provider.notifyFilterUpdated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = provider.allCategories;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white10, width: 0.5),
          ),
          padding: EdgeInsets.fromLTRB(24, 20, 24, 20 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filters', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('TRANSACTION TYPE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white24, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _TypeChip(
                    label: 'Expense', 
                    isSelected: selectedTypes.contains('Debit'),
                    onTap: () => setState(() => selectedTypes.contains('Debit') ? selectedTypes.remove('Debit') : selectedTypes.add('Debit')),
                  ),
                  const SizedBox(width: 8),
                  _TypeChip(
                    label: 'Income', 
                    isSelected: selectedTypes.contains('Credit'),
                    onTap: () => setState(() => selectedTypes.contains('Credit') ? selectedTypes.remove('Credit') : selectedTypes.add('Credit')),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('CATEGORIES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white24, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allCategories.map((c) {
                        final selected = selectedCategories.contains(c.id);
                        return FilterChip(
                          label: Text(c.name),
                          selected: selected,
                          onSelected: (val) => setState(() => val ? selectedCategories.add(c.id) : selectedCategories.remove(c.id)),
                          showCheckmark: false,
                          backgroundColor: Colors.transparent,
                          selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: selected ? Theme.of(context).colorScheme.primary : Colors.white60,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: selected ? Theme.of(context).colorScheme.primary : Colors.white10),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('DATE RANGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white24, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              _DateSelector(
                startDate: startDate,
                endDate: endDate,
                onTap: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (range != null) {
                    setState(() {
                      startDate = range.start;
                      endDate = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _apply,
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white10),
        ),
        child: Text(
          label, 
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white60, 
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({this.startDate, this.endDate, required this.onTap});
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = (startDate != null && endDate != null) 
        ? '${DateFormat('dd MMM').format(startDate!)} - ${DateFormat('dd MMM').format(endDate!)}' 
        : 'Select Date Range';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, size: 20, color: Colors.white24),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
