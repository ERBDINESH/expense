import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final user = AuthService().currentUser;
    final theme = Theme.of(context);
    final format = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

    final todaySpent = provider.todaySpent;
    final dailyBudget = provider.dynamicDailyBudget;
    final remaining = provider.remainingToday;
    final progress = (dailyBudget > 0 ? (todaySpent / dailyBudget) : 0.0).clamp(0.0, 1.0);
    
    String mood = '😊';
    Color statusColor = theme.colorScheme.primary;
    if (remaining <= 0) {
      mood = '😞';
      statusColor = Colors.redAccent;
    } else if (progress > 0.5) {
      mood = '😐';
      statusColor = Colors.orangeAccent;
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.refreshAll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              // 1. Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hey, ${user?.displayName?.split(' ').first ?? 'Thozha'} 👋',
                        style: const TextStyle(color: Colors.white38, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Moniqo',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.cardColor,
                      backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                      child: user?.photoURL == null ? const Icon(Icons.person) : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 2. Balance Card
              _buildBalanceCard(context, format, provider),
              const SizedBox(height: 24),

              // 3. Available Cash Context
              if (provider.upcomingFixedCosts > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, left: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_clock_outlined, size: 14, color: Colors.white24),
                      const SizedBox(width: 8),
                      Text(
                        '₹${provider.upcomingFixedCosts.toStringAsFixed(0)} reserved for upcoming payments',
                        style: const TextStyle(color: Colors.white24, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),

              _buildBudgetCard(context, format, provider, mood, statusColor, progress),
              const SizedBox(height: 24),

              if (provider.weeklyInsight != null)
                _buildInsightCard(context, provider.weeklyInsight!),
              
              if (provider.upcomingFixedCosts == 0)
                 const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Add fixed costs to see reserved balance breakdown',
                      style: TextStyle(color: Colors.white10, fontSize: 11),
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // 4. Fast Expense Entry
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QUICK ADD ${provider.mostFrequentCategory != null ? "(${provider.mostFrequentCategory!.name.toUpperCase()})" : ""}',
                    style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAddButton(context, 10, provider),
                  _buildQuickAddButton(context, 20, provider),
                  _buildQuickAddButton(context, 50, provider),
                  _buildQuickAddButton(context, 100, provider),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, NumberFormat format, ExpenseProvider provider) {
    final amount = provider.availableBalance;
    final isNegative = amount < 0;
    
    String label = 'AVAILABLE TO SPEND';
    String displayAmount = format.format(amount.abs());
    Color textColor = Colors.white;

    if (isNegative) {
      label = 'OVERUSED BY';
      textColor = Colors.redAccent;
      displayAmount = '$displayAmount 😞';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: isNegative ? Colors.redAccent.withValues(alpha: 0.3) : Colors.white10),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: isNegative ? Colors.redAccent : Colors.white24, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Text(
            displayAmount,
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: textColor),
          ),
          if (isNegative)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'You\'ve exceeded your available spending',
                style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, NumberFormat format, ExpenseProvider provider, String mood, Color statusColor, double progress) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('DAILY BUDGET', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              Text(mood, style: const TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${format.format(provider.todaySpent)} spent',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                provider.remainingToday >= 0 
                  ? '${format.format(provider.remainingToday)} left'
                  : 'Over by ${format.format(provider.todaySpent - provider.dynamicDailyBudget)}',
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            provider.remainingToday > 0 
              ? 'Safe to spend: ₹${provider.safeToSpendPerHour.toStringAsFixed(0)} per hour'
              : 'You\'ve exceeded today\'s budget',
            style: const TextStyle(color: Colors.white24, fontSize: 12),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(BuildContext context, double amount, ExpenseProvider provider) {
    return GestureDetector(
      onTap: () => provider.addQuickExpense(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          '₹$amount',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
      ),
    );
  }
}
