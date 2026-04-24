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
  String? category;
  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    amountCtrl = TextEditingController(text: initial?.amount.toString() ?? '');
    notesCtrl = TextEditingController(text: initial?.notes ?? '');
    type = initial?.type ?? type;
    category = initial?.category;
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
    final provider = context.watch<ExpenseProvider>();
    final isEdit = widget.initial != null;
    final existingCategories = provider.allCategories;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Transaction' : 'Add Transaction',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Amount Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.black87, fontSize: 32, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(color: Color(0xFF2E7D32), fontSize: 32),
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Colors.black26, fontSize: 14),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  if (amount == null || amount <= 0) return 'Enter valid amount';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Type Switch
            Row(
              children: [
                Expanded(
                  child: _TypeButton(
                    label: 'Expense',
                    isSelected: type == 'Debit',
                    color: Colors.redAccent,
                    onTap: () => setState(() => type = 'Debit'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _TypeButton(
                    label: 'Income',
                    isSelected: type == 'Credit',
                    color: const Color(0xFF2E7D32),
                    onTap: () => setState(() => type = 'Credit'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Category Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: category,
                items: existingCategories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(color: Colors.black87)));
                }).toList(),
                onChanged: (value) => setState(() => category = value),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.black26),
                  border: InputBorder.none,
                ),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
            ),
            const SizedBox(height: 24),
            
            // Date Picker
            InkWell(
              onTap: () async {
                final selected = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate: date,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF2E7D32),
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black87,
                        ),
                      ),
                      child: child!,
                    );
                  },
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
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Color(0xFF2E7D32), size: 20),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Date', style: TextStyle(color: Colors.black26, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Notes Field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: notesCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.black87),
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  labelStyle: TextStyle(color: Colors.black26),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // Submit Button
            GestureDetector(
              onTap: () async {
                if (!_formKey.currentState!.validate() || category == null) return;
                final tx = ExpenseTransaction(
                  id: widget.initial?.id,
                  amount: double.parse(amountCtrl.text),
                  type: type,
                  category: category!,
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
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    isEdit ? 'Update Transaction' : 'Create Transaction',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.3) : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.black26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
