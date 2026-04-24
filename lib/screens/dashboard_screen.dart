import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/filter_bar.dart';
import '../widgets/summary_card.dart';
import '../services/auth_service.dart';
import 'add_edit_expense_screen.dart';
import 'profile_screen.dart';
import 'transaction_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final grouped = provider.groupedByDate;
    final user = AuthService().currentUser;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: provider.loadTransactions,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hey, ${user?.displayName?.split(' ').first ?? 'Arjun'} 👋',
                          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Moniqo',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onBackground,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                          child: user?.photoURL == null 
                              ? Icon(Icons.person, color: Theme.of(context).colorScheme.primary, size: 30)
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    const SummaryCard(),
                    const SizedBox(height: 28),
                    const FilterBar(),
                    const SizedBox(height: 32),
                    
                    if (provider.categoryTotals.isNotEmpty) ...[
                      _buildSectionHeader('Category Breakdown', context),
                      const SizedBox(height: 16),
                      _CategoryBreakdown(
                        categoryTotals: provider.categoryTotals,
                        totalExpense: provider.totalDebit,
                      ),
                      const SizedBox(height: 32),
                    ],
                    
                    _buildSectionHeader('Recent Transactions', context),
                    const SizedBox(height: 16),
                    
                    if (provider.isLoading)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                      ))
                    else if (grouped.isEmpty)
                      const _EmptyState()
                    else
                      ..._buildTransactionList(context, grouped),
                        
                      const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()),
        ),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onBackground,
        fontSize: 19,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }

  List<Widget> _buildTransactionList(BuildContext context, Map<DateTime, List<dynamic>> grouped) {
    List<Widget> list = [];
    for (final entry in grouped.entries) {
      final dailyTotal = entry.value
          .where((tx) => !tx.isCredit)
          .fold(0.0, (sum, tx) => sum + tx.amount);
          
      list.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 16, left: 4, right: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEEE, dd MMM').format(entry.key),
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              if (dailyTotal > 0)
                Text(
                  '₹${dailyTotal.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                ),
            ],
          ),
        ),
      );
      
      list.add(
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              for (var i = 0; i < entry.value.length; i++) ...[
                ExpenseCard(
                  transaction: entry.value[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TransactionDetailScreen(transaction: entry.value[i]),
                    ),
                  ),
                ),
                if (i < entry.value.length - 1)
                  const Divider(height: 1, color: Color(0xFFF1F4F8), indent: 20, endIndent: 20),
              ],
            ],
          ),
        ),
      );
    }
    return list;
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.categoryTotals, required this.totalExpense});
  final Map<String, double> categoryTotals;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          ...categoryTotals.entries.take(3).map((entry) {
            final percentage = totalExpense > 0 ? (entry.value / totalExpense) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            entry.key,
                            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Text(
                        '₹${entry.value.toStringAsFixed(0)}',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      color: Theme.of(context).colorScheme.primary,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)],
              ),
              child: Icon(Icons.account_balance_wallet_outlined, size: 48, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.2)),
            ),
            const SizedBox(height: 24),
            Text('No Transactions Yet', style: TextStyle(color: Theme.of(context).colorScheme.onBackground, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Start tracking your expenses today!', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
