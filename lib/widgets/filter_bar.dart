import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                for (final mode in ['Today', 'This Week', 'This Month'])
                  ActionChip(
                    label: Text(mode),
                    onPressed: () => provider.applyQuickFilter(mode),
                  ),
                ActionChip(
                  label: const Text('Reset'),
                  onPressed: () {
                    provider.filter.reset();
                    provider.notifyFilterUpdated();
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                DropdownButton<String?>(
                  value: provider.filter.type,
                  hint: const Text('Type'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Types')),
                    DropdownMenuItem(value: 'Credit', child: Text('Credit')),
                    DropdownMenuItem(value: 'Debit', child: Text('Debit')),
                  ],
                  onChanged: (v) {
                    provider.filter.type = v;
                    provider.notifyFilterUpdated();
                  },
                ),
                DropdownButton<String?>(
                  value: provider.filter.category,
                  hint: const Text('Category'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Categories')),
                    ...predefinedCategories.map(
                      (c) => DropdownMenuItem(value: c, child: Text(c)),
                    ),
                  ],
                  onChanged: (v) {
                    provider.filter.category = v;
                    provider.notifyFilterUpdated();
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: const Text('Date range'),
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
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
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
