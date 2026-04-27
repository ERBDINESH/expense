import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../models/expense_transaction.dart';
import '../models/app_category.dart';
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
  String? categoryId;
  String? categoryName;
  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    amountCtrl = TextEditingController(text: initial?.amount.toString() ?? '');
    notesCtrl = TextEditingController(text: initial?.notes ?? '');
    type = initial?.type ?? type;
    categoryId = initial?.category;
    categoryName = initial?.categoryName;
    date = initial?.date ?? date;

    notesCtrl.addListener(_onNotesChanged);
  }

  void _onNotesChanged() {
    if (categoryId != null) return; // Don't overwrite manually selected
    final text = notesCtrl.text.toLowerCase();
    final provider = context.read<ExpenseProvider>();
    final cats = provider.allCategories;

    final mapping = {
      'eb': 'electricity',
      'current': 'electricity',
      'rent': 'rent',
      'food': 'food',
      'lunch': 'food',
      'dinner': 'food',
      'fuel': 'petrol',
      'petrol': 'petrol',
      'gas': 'petrol',
      'taxi': 'travel',
      'uber': 'travel',
      'ola': 'travel',
      'movie': 'movie',
      'recharge': 'recharge',
      'jio': 'recharge',
      'airtel': 'recharge',
    };

    for (var key in mapping.keys) {
      if (text.contains(key)) {
        final match = cats.firstWhereOrNull((c) => c.name.toLowerCase().contains(mapping[key]!));
        if (match != null) {
          setState(() {
            categoryId = match.id;
            categoryName = match.name;
          });
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    notesCtrl.removeListener(_onNotesChanged);
    amountCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final isEdit = widget.initial != null;
    final allCategories = provider.allCategories;

    // Safety check for dropdown value
    bool categoryExists = allCategories.any((cat) => cat.id == categoryId);
    String? safeCategoryId = categoryExists ? categoryId : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEdit ? 'Edit Transaction' : 'Add Transaction'),
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
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: TextFormField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 32),
                  labelText: 'Amount',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
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
                    color: Theme.of(context).colorScheme.primary,
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
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: DropdownButtonFormField<String>(
                dropdownColor: Theme.of(context).cardColor,
                value: safeCategoryId,
                items: [
                  const DropdownMenuItem(
                    enabled: false,
                    child: Text("--- Default Categories ---", style: TextStyle(color: Colors.white30, fontSize: 12)),
                  ),
                  ...allCategories.where((c) => c.type == CategoryType.defaultType).map((cat) => 
                    DropdownMenuItem(value: cat.id, child: Text(cat.name))),
                  const DropdownMenuItem(
                    enabled: false,
                    child: Text("--- Your Categories ---", style: TextStyle(color: Colors.white30, fontSize: 12)),
                  ),
                  ...allCategories.where((c) => c.type == CategoryType.custom).map((cat) => 
                    DropdownMenuItem(value: cat.id, child: Text(cat.name))),
                ],
                onChanged: (value) {
                  final selected = allCategories.firstWhere((cat) => cat.id == value);
                  setState(() {
                    categoryId = value;
                    categoryName = selected.name;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                ),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
            ),
            const SizedBox(height: 32),

            // Quick Tags
            const Text('QUICK TAGS', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag('🍔 Food', allCategories),
                _buildTag('🚗 Travel', allCategories),
                _buildTag('🛒 Grocery', allCategories),
                _buildTag('❤️ Family', allCategories),
                _buildTag('💡 Bills', allCategories),
              ],
            ),
            const SizedBox(height: 32),
            
            // Date Picker
            InkWell(
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
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: TextFormField(
                controller: notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // Submit Button
            ElevatedButton(
              onPressed: provider.isProcessing 
                  ? null 
                  : () async {
                if (!_formKey.currentState!.validate() || categoryId == null || categoryName == null) return;
                final tx = ExpenseTransaction(
                  id: widget.initial?.id,
                  amount: double.parse(amountCtrl.text),
                  type: type,
                  category: categoryId!,
                  categoryName: categoryName!,
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
              child: provider.isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : Text(isEdit ? 'Update Transaction' : 'Create Transaction'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, List<AppCategory> categories) {
    final tagName = label.split(' ').last.toLowerCase();
    
    return GestureDetector(
      onTap: () {
        final match = categories.firstWhere(
          (c) => c.name.toLowerCase().contains(tagName),
          orElse: () => categories.firstWhere((c) => c.name.toLowerCase() == 'misc', orElse: () => categories.first),
        );
        setState(() {
          categoryId = match.id;
          categoryName = match.name;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
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
          color: isSelected ? color.withOpacity(0.08) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.3) : Colors.white10,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
