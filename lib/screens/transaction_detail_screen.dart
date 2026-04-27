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
    final provider = context.watch<ExpenseProvider>();
    final format = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 2);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final accentColor = transaction.isCredit ? primaryColor : Colors.redAccent;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Transaction Details'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  // ignore: deprecated_member_use
                                  color: accentColor.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getCategoryIcon(transaction.categoryName),
                                  color: accentColor,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${transaction.isCredit ? '+' : '-'} ${format.format(transaction.amount)}',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: accentColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      transaction.categoryName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: Colors.white10),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _InfoRow(
                                icon: Icons.category_outlined,
                                iconColor: primaryColor,
                                label: 'Category',
                                value: transaction.categoryName,
                              ),
                              const _InfoDivider(),
                              _InfoRow(
                                icon: Icons.sync_alt_rounded,
                                iconColor: primaryColor,
                                label: 'Transaction Type',
                                value: transaction.type,
                                valueColor: accentColor,
                              ),
                              const _InfoDivider(),
                              _InfoRow(
                                icon: Icons.calendar_today_outlined,
                                iconColor: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                                label: 'Date & Time',
                                value: DateFormat('dd MMM yyyy, hh:mm a').format(transaction.date),
                              ),
                              const _InfoDivider(),
                              _InfoRow(
                                icon: Icons.notes_rounded,
                                iconColor: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                                label: 'Notes',
                                value: transaction.notes ?? 'No notes provided',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: provider.isProcessing ? null : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditExpenseScreen(initial: transaction),
                            ),
                          );
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: provider.isProcessing ? null : () async {
                          final confirmed = await _showDeleteDialog(context);
                          if (confirmed == true && context.mounted) {
                            await context.read<ExpenseProvider>().delete(transaction);
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.redAccent.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
                          ),
                          child: Center(
                            child: provider.isProcessing 
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent),
                                )
                              : const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (provider.isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food': return Icons.restaurant_rounded;
      case 'Loan': return Icons.account_balance_rounded;
      case 'Travel': return Icons.flight_rounded;
      case 'Medical': return Icons.local_hospital_rounded;
      default: return Icons.category_rounded;
    }
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text('This action cannot be undone and will be permanent.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: iconColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: valueColor ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: Colors.white10, indent: 56);
  }
}
