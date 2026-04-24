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
    final format = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 2);
    final primaryColor = const Color(0xFF2E7D32);
    final accentColor = transaction.isCredit ? primaryColor : Colors.redAccent;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Transaction Details', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
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
                              color: accentColor.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getCategoryIcon(transaction.category),
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
                                  transaction.category,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black38,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F3F4)),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.category_outlined,
                            iconColor: primaryColor,
                            label: 'Category',
                            value: transaction.category,
                          ),
                          _InfoDivider(),
                          _InfoRow(
                            icon: Icons.sync_alt_rounded,
                            iconColor: primaryColor,
                            label: 'Transaction Type',
                            value: transaction.type,
                            valueColor: accentColor,
                          ),
                          _InfoDivider(),
                          _InfoRow(
                            icon: Icons.calendar_today_outlined,
                            iconColor: Colors.black26,
                            label: 'Date & Time',
                            value: DateFormat('dd MMM yyyy, hh:mm a').format(transaction.date),
                          ),
                          _InfoDivider(),
                          _InfoRow(
                            icon: Icons.notes_rounded,
                            iconColor: Colors.black26,
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
                  child: GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditExpenseScreen(initial: transaction),
                        ),
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E7D32).withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Edit',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final confirmed = await _showDeleteDialog(context);
                      if (confirmed == true && context.mounted) {
                        await context.read<ExpenseProvider>().delete(transaction);
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
                      ),
                      child: const Center(
                        child: Text(
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Transaction?', style: TextStyle(color: Colors.black87)),
        content: const Text('This action cannot be undone and will be permanent.', style: TextStyle(color: Colors.black45)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black38)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: valueColor ?? Colors.black87,
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
  @override
  build(BuildContext context) {
    return const Divider(height: 1, color: Color(0xFFF1F3F4), indent: 56);
  }
}
