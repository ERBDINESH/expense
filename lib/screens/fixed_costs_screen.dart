import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';

class FixedCostsScreen extends StatelessWidget {
  const FixedCostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final costs = provider.fixedCosts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixed Costs'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Reserve money for upcoming payments like EMI, Rent, or Subscriptions.',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 24),
          if (costs.isEmpty)
            _buildEmptyState(context)
          else
            ...costs.map((cost) => _buildCostTile(context, cost, provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, provider),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildCostTile(BuildContext context, Map<String, dynamic> cost, ExpenseProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        title: Text(cost['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Due on day ${cost['dayOfMonth']} of month', style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('₹${cost['amount']}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
              onPressed: () => provider.deleteFixedCost(cost['id']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          children: [
            Icon(Icons.receipt_outlined, size: 64, color: Colors.white10),
            const SizedBox(height: 16),
            const Text('No fixed costs added yet.', style: TextStyle(color: Colors.white38)),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, ExpenseProvider provider) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final dayCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Add Fixed Cost'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (e.g. Rent)')),
              const SizedBox(height: 16),
              TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (₹)')),
              const SizedBox(height: 16),
              TextField(controller: dayCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Day of Month (1-31)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final amount = double.tryParse(amountCtrl.text);
              final day = int.tryParse(dayCtrl.text);
              if (name.isNotEmpty && amount != null && day != null) {
                provider.addFixedCost(name, amount, day);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
