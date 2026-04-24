import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterItem(
                    icon: Icons.grid_view_rounded,
                    label: provider.filter.type ?? 'Type',
                    onTap: () async {
                      final type = await showMenu<String>(
                        context: context,
                        color: Theme.of(context).cardColor,
                        position: const RelativeRect.fromLTRB(20, 400, 100, 0),
                        items: [
                          PopupMenuItem(value: null, child: Text('All Types', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                          PopupMenuItem(value: 'Debit', child: Text('Expense', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                          PopupMenuItem(value: 'Credit', child: Text('Income', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                        ],
                      );
                      if (type != provider.filter.type) {
                        provider.filter.type = type;
                        provider.notifyFilterUpdated();
                      }
                    },
                  ),
                  _buildSeparator(context),
                  _FilterItem(
                    icon: Icons.sell_outlined,
                    label: provider.filter.category ?? 'Category',
                    onTap: () async {
                      final cat = await showMenu<String>(
                        context: context,
                        color: Theme.of(context).cardColor,
                        position: const RelativeRect.fromLTRB(80, 400, 20, 0),
                        items: [
                          PopupMenuItem(value: null, child: Text('All Categories', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                          ...provider.allCategories.map(
                            (c) => PopupMenuItem(value: c, child: Text(c, style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                          ),
                        ],
                      );
                      if (cat != provider.filter.category) {
                        provider.filter.category = cat;
                        provider.notifyFilterUpdated();
                      }
                    },
                  ),
                  _buildSeparator(context),
                  _FilterItem(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
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
                                onPrimary: Colors.white,
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
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Refresh Button
        GestureDetector(
          onTap: () {
            provider.filter.reset();
            provider.notifyFilterUpdated();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.refresh_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator(BuildContext context) {
    return Container(
      height: 16,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Theme.of(context).dividerColor.withOpacity(0.1),
    );
  }
}

class _FilterItem extends StatelessWidget {
  const _FilterItem({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.2)),
        ],
      ),
    );
  }
}
