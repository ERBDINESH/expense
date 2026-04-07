import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense_transaction.dart';
import '../providers/expense_provider.dart';
import 'add_edit_expense_screen.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.transaction});

  final ExpenseTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditExpenseScreen(initial: transaction),
                ),
              );
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () async {
              await context.read<ExpenseProvider>().delete(transaction);
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amount: ${format.format(transaction.amount)}'),
                const SizedBox(height: 8),
                Text('Category: ${transaction.category}'),
                const SizedBox(height: 8),
                Text('Type: ${transaction.type}'),
                const SizedBox(height: 8),
                Text('Date & Time: ${DateFormat('dd MMM yyyy, hh:mm a').format(transaction.date)}'),
                const SizedBox(height: 8),
                Text('Notes: ${transaction.notes ?? '-'}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
