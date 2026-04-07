import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense_transaction.dart';

class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  final ExpenseTransaction transaction;
  final VoidCallback onTap;

  static const icons = {
    'Food': Icons.restaurant,
    'Movie': Icons.movie,
    'Delivery & Myself': Icons.delivery_dining,
    'Loan': Icons.account_balance,
    'Medical': Icons.local_hospital,
    'Home': Icons.home,
    'Petrol': Icons.local_gas_station,
    'Wife': Icons.favorite,
    'Appa': Icons.person,
    'Amma': Icons.person_2,
    'For Hand': Icons.back_hand,
    'Goods': Icons.shopping_bag,
    'Rent': Icons.house_siding,
    'Recharge': Icons.phone_iphone,
    'Rent Home': Icons.home_work,
    'Travel': Icons.flight,
  };

  @override
  Widget build(BuildContext context) {
    final amountColor = transaction.isCredit ? Colors.green : Colors.red;
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: amountColor.withValues(alpha: 0.12),
          child: Icon(icons[transaction.category] ?? Icons.category, color: amountColor),
        ),
        title: Text(transaction.category),
        subtitle: Text(
          transaction.notes?.isNotEmpty == true ? transaction.notes! : 'No notes',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              format.format(transaction.amount),
              style: TextStyle(color: amountColor, fontWeight: FontWeight.w700),
            ),
            Text(DateFormat('hh:mm a').format(transaction.date)),
          ],
        ),
      ),
    );
  }
}
