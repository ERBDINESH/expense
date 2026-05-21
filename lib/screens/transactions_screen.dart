import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../models/expense_transaction.dart';
import '../widgets/expense_card.dart';
import '../widgets/filter_bar.dart';
import 'transaction_detail_screen.dart';

/// Clean Transactions screen with applied-filter summary and grouped list.
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final grouped = provider.groupedByDate;
    final format = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                const FilterBar(compact: true),
                const SizedBox(height: 16),

                // Summary Row (Expense | Total | Income) - redesigned SummaryCard widgets
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SummaryCard(
                          amount: format.format(provider.filteredTotalDebit),
                          transactions: provider.filteredTransactions.where((t) => !t.isCredit).length,
                          accentColor: Colors.redAccent,
                          icon: Icons.arrow_downward_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SummaryCard(
                          amount: format.format(provider.filteredTotalCredit - provider.filteredTotalDebit),
                          transactions: provider.filteredTransactions.length,
                          accentColor: Theme.of(context).colorScheme.primary,
                          icon: Icons.account_balance_wallet_rounded,
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SummaryCard(
                          amount: format.format(provider.filteredTotalCredit),
                          transactions: provider.filteredTransactions.where((t) => t.isCredit).length,
                          accentColor: Colors.greenAccent.shade700,
                          icon: Icons.arrow_upward_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : grouped.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
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
}

// New reusable SummaryCard for a compact mobile-first finance summary
class SummaryCard extends StatefulWidget {
  const SummaryCard({
    super.key,
    required this.amount,
    required this.transactions,
    required this.accentColor,
    required this.icon,
    this.isPrimary = false,
  });

  final String amount;
  final int transactions;
  final Color accentColor;
  final IconData icon;
  final bool isPrimary;

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).cardColor;
    final amountColor = widget.accentColor;
    final displayAmount = _isVisible ? widget.amount : '••••';

    return Container(
      constraints: const BoxConstraints(minWidth: 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.white10, width: 0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 16, color: widget.accentColor),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => setState(() => _isVisible = !_isVisible),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Icon(
                    _isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 16,
                    color: widget.accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayAmount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: amountColor),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.receipt_long, size: 12, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${widget.transactions} ${widget.transactions == 1 ? 'txn' : 'txns'}', 
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _buildDateGroup(BuildContext context, DateTime date, List<ExpenseTransaction> transactions) {
  final dailyTotal = transactions.where((tx) => !tx.isCredit).fold(0.0, (sum, tx) => sum + tx.amount);
  final format = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, right: 8, bottom: 12, top: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('EEEE, dd MMM').format(date),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            if (dailyTotal > 0)
              Text(
                format.format(dailyTotal),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
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
                  MaterialPageRoute(builder: (_) => TransactionDetailScreen(transaction: transactions[i])),
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
  return const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.history_rounded, size: 64, color: Colors.white10),
        SizedBox(height: 16),
        Text('No transactions found', style: TextStyle(color: Colors.white54)),
      ],
    ),
  );
}
