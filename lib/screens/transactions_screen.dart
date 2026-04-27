import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/filter_bar.dart';
import 'transaction_detail_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final grouped = provider.groupedByDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: FilterBar(),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : grouped.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: grouped.length,
                        itemBuilder: (context, index) {
                          final date = grouped.keys.elementAt(index);
                          final transactions = grouped[date]!;
                          return _buildDateGroup(context, date, transactions);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateGroup(BuildContext context, DateTime date, List<dynamic> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12, top: 16),
          child: Text(
            DateFormat('EEEE, dd MMM').format(date),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              for (var i = 0; i < transactions.length; i++) ...[
                ExpenseCard(
                  transaction: transactions[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionDetailScreen(transaction: transactions[i]),
                    ),
                  ),
                ),
                if (i < transactions.length - 1)
                  const Divider(height: 1, color: Colors.white10, indent: 20, endIndent: 20),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          const Text('No transactions found', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}
