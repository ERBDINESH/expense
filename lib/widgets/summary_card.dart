import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class SummaryCard extends StatefulWidget {
  const SummaryCard({
    super.key,
    this.totalExpense = 0,
    this.totalIncome = 0,
    this.netBalance = 0,
  });

  final double totalExpense;
  final double totalIncome;
  final double netBalance;

  @override
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final format = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
    final displayedBalance = _isBalanceVisible ? format.format(provider.netBalance) : '••••••';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Net Balance',
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        displayedBalance,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 14),
                      GestureDetector(
                        onTap: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.north_east_rounded, color: Theme.of(context).colorScheme.primary, size: 10),
                        const SizedBox(width: 4),
                        Text('100%', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Theme.of(context).colorScheme.primary.withOpacity(0.15), Theme.of(context).colorScheme.primary.withOpacity(0.05)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.account_balance_wallet_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
              )
            ],
          ),
          const SizedBox(height: 36),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: 'Income',
                  value: format.format(provider.totalCredit),
                  icon: Icons.arrow_upward_rounded,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricBox(
                  label: 'Expense',
                  value: format.format(provider.totalDebit),
                  icon: Icons.arrow_downward_rounded,
                  color: Colors.red[700]!,
                  showMonth: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.showMonth = false,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool showMonth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.03)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (showMonth) ...[
                  const SizedBox(height: 4),
                  // Removed "This month" text
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
