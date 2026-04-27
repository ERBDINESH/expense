import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense_transaction.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    super.key,
    required this.transaction,
    required this.onTap,
    this.showBackground = false,
  });

  final ExpenseTransaction transaction;
  final VoidCallback onTap;
  final bool showBackground;

  static const icons = {
    'Food': Icons.restaurant_rounded,
    'Movie': Icons.movie_rounded,
    'Delivery & Myself': Icons.delivery_dining_rounded,
    'Loan': Icons.account_balance_rounded,
    'Medical': Icons.local_hospital_rounded,
    'Home': Icons.home_rounded,
    'Petrol': Icons.local_gas_station_rounded,
    'Wife': Icons.favorite_rounded,
    'Appa': Icons.person_rounded,
    'Amma': Icons.person_2_rounded,
    'Hand': Icons.back_hand_rounded,
    'Goods': Icons.shopping_bag_rounded,
    'Rent': Icons.house_siding_rounded,
    'Recharge': Icons.phone_iphone_rounded,
    'Rent Home': Icons.home_work_rounded,
    'Travel': Icons.flight_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final accentColor = transaction.isCredit ? const Color(0xFF2E7D32) : Colors.red[700]!;
    final format = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);
    
    Widget content = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icons[transaction.categoryName] ?? Icons.category_rounded,
                color: accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.categoryName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      transaction.notes!,
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.isCredit ? '+' : '-'} ₹${format.format(transaction.amount).replaceAll(RegExp(r'[^0-9,]'), '')}',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.type,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (showBackground) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        ),
        child: content,
      );
    }
    return content;
  }
}
