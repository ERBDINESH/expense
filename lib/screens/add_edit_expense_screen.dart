import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense_transaction.dart';
import '../providers/expense_provider.dart';

class AddEditExpenseScreen extends StatefulWidget {
  const AddEditExpenseScreen({super.key, this.initial});

  final ExpenseTransaction? initial;

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController amountCtrl;
  late final TextEditingController notesCtrl;
  String type = 'Debit';
  String category = predefinedCategories.first;
  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    amountCtrl = TextEditingController(text: initial?.amount.toString() ?? '');
    notesCtrl = TextEditingController(text: initial?.notes ?? '');
    type = initial?.type ?? type;
    category = initial?.category ?? category;
    date = initial?.date ?? date;
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Transaction' : 'Add Transaction')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Amount'),
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount <= 0) return 'Enter valid amount';
                return null;
              },
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Credit', label: Text('Credit')),
                ButtonSegment(value: 'Debit', label: Text('Debit')),
              ],
              selected: {type},
              onSelectionChanged: (v) => setState(() => type = v.first),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: category,
              items: predefinedCategories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) => setState(() => category = value!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 12),
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              leading: const Icon(Icons.calendar_month),
              title: const Text('Date'),
              subtitle: Text('${date.day}/${date.month}/${date.year}'),
              onTap: () async {
                final selected = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate: date,
                );
                if (selected != null) {
                  setState(() => date = DateTime(
                        selected.year,
                        selected.month,
                        selected.day,
                        DateTime.now().hour,
                        DateTime.now().minute,
                      ));
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: notesCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final tx = ExpenseTransaction(
                  id: widget.initial?.id,
                  amount: double.parse(amountCtrl.text),
                  type: type,
                  category: category,
                  date: date,
                  notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                );
                final provider = context.read<ExpenseProvider>();
                if (isEdit) {
                  await provider.update(tx);
                } else {
                  await provider.add(tx);
                }
                if (mounted) Navigator.pop(context, true);
              },
              child: Text(isEdit ? 'Save Changes' : 'Add Transaction'),
            )
          ],
        ),
      ),
    );
  }
}
