import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense_transaction.dart';
import '../models/app_category.dart';

class QuickAddBottomSheet extends StatefulWidget {
  const QuickAddBottomSheet({super.key});

  @override
  State<QuickAddBottomSheet> createState() => _QuickAddBottomSheetState();
}

class _QuickAddBottomSheetState extends State<QuickAddBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _type = 'Debit';
  String? _categoryId;
  String? _categoryName;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ExpenseProvider>();
    final allCategories = provider.allCategories;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white10),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Quick Add',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Type Selector
              Row(
                children: [
                  _buildTypeChip('Debit', 'Expense', Colors.redAccent),
                  const SizedBox(width: 12),
                  _buildTypeChip('Credit', 'Income', theme.colorScheme.primary),
                ],
              ),
              const SizedBox(height: 24),

              // Amount Input
              TextFormField(
                controller: _amountController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '₹ 0',
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                ),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Enter valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category Selector
              DropdownButtonFormField<String>(
                value: _categoryId,
                hint: const Text('Select Category'),
                items: allCategories.map((cat) => DropdownMenuItem(
                  value: cat.id,
                  child: Text(cat.name),
                )).toList(),
                onChanged: (val) {
                  final cat = allCategories.firstWhere((c) => c.id == val);
                  setState(() {
                    _categoryId = val;
                    _categoryName = cat.name;
                  });
                },
                validator: (val) => val == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Note Input
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: 'What was this for?',
                  prefixIcon: Icon(Icons.notes_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                onPressed: provider.isProcessing ? null : _save,
                child: provider.isProcessing 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save Transaction'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String value, String label, Color color) {
    final isSelected = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? color : Colors.white10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white38,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final tx = ExpenseTransaction(
      amount: double.parse(_amountController.text),
      type: _type,
      category: _categoryId!,
      categoryName: _categoryName!,
      date: DateTime.now(),
      notes: _notesController.text.trim(),
    );

    await context.read<ExpenseProvider>().add(tx);
    if (mounted) Navigator.pop(context);
  }
}
