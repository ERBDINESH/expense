import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/filter_bar.dart';
import '../widgets/summary_card.dart';
import 'add_edit_expense_screen.dart';
import 'transaction_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final grouped = provider.groupedByDate;

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Expense Tracker')),
      body: RefreshIndicator(
        onRefresh: provider.loadTransactions,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    SummaryCard(
                      totalExpense: provider.totalDebit,
                      totalIncome: provider.totalCredit,
                      netBalance: provider.netBalance,
                    ),
                    const SizedBox(height: 10),
                    const FilterBar(),
                    const SizedBox(height: 8),
                    if (provider.categoryTotals.isNotEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Category Breakdown',
                                  style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              ...provider.categoryTotals.entries.map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(entry.key)),
                                      Text('₹${entry.value.toStringAsFixed(2)}'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
            if (provider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (grouped.isEmpty)
              const SliverFillRemaining(
                child: _EmptyState(),
              )
            else
              for (final entry in grouped.entries) ...[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _DateHeaderDelegate(
                    date: entry.key,
                    dailyTotal: entry.value
                        .where((tx) => !tx.isCredit)
                        .fold(0, (sum, tx) => sum + tx.amount),
                    dailyNet: entry.value.fold(
                      0,
                      (sum, tx) => tx.isCredit ? sum + tx.amount : sum - tx.amount,
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: entry.value.length,
                  itemBuilder: (context, index) {
                    final tx = entry.value[index];
                    return Dismissible(
                      key: ValueKey(tx.id),
                      background: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => provider.delete(tx),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOut,
                          child: ExpenseCard(
                            transaction: tx,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionDetailScreen(transaction: tx),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AddEditExpenseScreen(),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            ),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}

class _DateHeaderDelegate extends SliverPersistentHeaderDelegate {
  _DateHeaderDelegate({required this.date, required this.dailyTotal, required this.dailyNet});

  final DateTime date;
  final double dailyTotal;
  final double dailyNet;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('EEEE, dd MMM yyyy').format(date),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text('Spent ₹${dailyTotal.toStringAsFixed(0)}  •  Net ₹${dailyNet.toStringAsFixed(0)}')
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 56;

  @override
  double get minExtent => 56;

  @override
  bool shouldRebuild(covariant _DateHeaderDelegate oldDelegate) {
    return oldDelegate.date != date ||
        oldDelegate.dailyTotal != dailyTotal ||
        oldDelegate.dailyNet != dailyNet;
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wallet_outlined, size: 52, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text('No expenses yet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Tap “Add Expense” to track your first transaction.'),
        ],
      ),
    );
  }
}
