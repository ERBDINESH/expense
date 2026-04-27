import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../providers/expense_provider.dart';
import '../models/app_category.dart';

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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
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
                        label: provider.filter.categoryId != null 
                            ? provider.allCategories.firstWhereOrNull((c) => c.id == provider.filter.categoryId)?.name ?? 'Category'
                            : 'Category',
                        onTap: () async {
                          final catId = await showMenu<String>(
                            context: context,
                            color: Theme.of(context).cardColor,
                            position: const RelativeRect.fromLTRB(80, 400, 20, 0),
                            items: [
                              PopupMenuItem(value: null, child: Text('All Categories', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                              const PopupMenuItem(enabled: false, child: Text("--- Defaults ---", style: TextStyle(color: Colors.white30, fontSize: 11))),
                              ...provider.allCategories.where((c) => c.type == CategoryType.defaultType).map(
                                (c) => PopupMenuItem(value: c.id, child: Text(c.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                              ),
                              const PopupMenuItem(enabled: false, child: Text("--- Customs ---", style: TextStyle(color: Colors.white30, fontSize: 11))),
                              ...provider.allCategories.where((c) => c.type == CategoryType.custom).map(
                                (c) => PopupMenuItem(value: c.id, child: Text(c.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                              ),
                            ],
                          );
                          if (catId != provider.filter.categoryId) {
                            provider.filter.categoryId = catId;
                            provider.notifyFilterUpdated();
                          }
                        },
                      ),
                      _buildSeparator(context),
                      _FilterItem(
                        icon: Icons.calendar_today_rounded,
                        label: hasDateFilter ? DateFormat('dd MMM').format(provider.filter.startDate!) : 'Date',
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
                      ),
                    ],
                  ),
                ),
                if (hasDateFilter)
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 400),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      final clampedValue = value.clamp(0.0, 1.0);
                      return Opacity(
                        opacity: clampedValue,
                        child: Transform.translate(
                          offset: Offset(0, (1 - clampedValue) * 5),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.date_range_rounded, size: 10, color: Theme.of(context).colorScheme.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    dateRangeText,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Reset Button
        GestureDetector(
          onTap: () {
            provider.filter.reset();
            provider.notifyFilterUpdated();
          },
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 500),
            turns: hasDateFilter || provider.filter.categoryId != null || provider.filter.type != null ? 0 : 0.5,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: (hasDateFilter || provider.filter.categoryId != null || provider.filter.type != null)
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Theme.of(context).cardColor,
                shape: BoxShape.circle,
                border: Border.all(
                  // ignore: deprecated_member_use
                  color: (hasDateFilter || provider.filter.categoryId != null || provider.filter.type != null)
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
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
        ),
      ],
    );
  }

  Widget _buildSeparator(BuildContext context) {
    return Container(
      height: 16,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Theme.of(context).dividerColor,
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
