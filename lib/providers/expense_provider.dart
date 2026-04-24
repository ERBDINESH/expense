import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../models/expense_transaction.dart';
import '../services/expense_database.dart';

const predefinedCategories = <String>[
  'Loan',
  'Travel',
  'Medical',
  'Food',
];

class ExpenseFilter {
  DateTime? startDate;
  DateTime? endDate;
  String? category;
  String? type;

  void reset() {
    startDate = null;
    endDate = null;
    category = null;
    type = null;
  }
}

class ExpenseProvider extends ChangeNotifier {
  final ExpenseFilter filter = ExpenseFilter();
  bool isLoading = false;
  final List<ExpenseTransaction> _transactions = [];
  final List<String> _customCategories = [];

  List<ExpenseTransaction> get transactions => _transactions;
  List<String> get allCategories => {...predefinedCategories, ..._customCategories}.toList()..sort();

  List<ExpenseTransaction> get filteredTransactions {
    return _transactions.where((tx) {
      final inRange = (filter.startDate == null ||
              !tx.date.isBefore(filter.startDate!)) &&
          (filter.endDate == null || !tx.date.isAfter(filter.endDate!));
      final inCategory = filter.category == null || tx.category == filter.category;
      final inType = filter.type == null || tx.type == filter.type;
      return inRange && inCategory && inType;
    }).toList();
  }

  Map<DateTime, List<ExpenseTransaction>> get groupedByDate {
    final groups = groupBy(filteredTransactions, (ExpenseTransaction tx) {
      return DateTime(tx.date.year, tx.date.month, tx.date.day);
    });
    final sortedKeys = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final key in sortedKeys) key: groups[key]!};
  }

  double get totalDebit => filteredTransactions
      .where((e) => !e.isCredit)
      .fold(0.0, (sum, e) => sum + e.amount);
  double get totalCredit =>
      filteredTransactions.where((e) => e.isCredit).fold(0.0, (sum, e) => sum + e.amount);
  double get netBalance => totalCredit - totalDebit;

  Map<String, double> get categoryTotals {
    final result = <String, double>{};
    for (final tx in filteredTransactions.where((e) => !e.isCredit)) {
      result[tx.category] = (result[tx.category] ?? 0) + tx.amount;
    }
    return Map.fromEntries(
      result.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Future<void> loadTransactions() async {
    isLoading = true;
    notifyListeners();
    _transactions
      ..clear()
      ..addAll(await ExpenseDatabase.instance.getAll());
    
    _customCategories
      ..clear()
      ..addAll(await ExpenseDatabase.instance.getCategories());

    isLoading = false;
    notifyListeners();
  }

  Future<void> add(ExpenseTransaction tx) async {
    await ExpenseDatabase.instance.insert(tx);
    // Also add to custom categories if not predefined
    if (!predefinedCategories.contains(tx.category)) {
      await addCategory(tx.category);
    }
    await loadTransactions();
  }

  Future<void> update(ExpenseTransaction tx) async {
    await ExpenseDatabase.instance.update(tx);
    if (!predefinedCategories.contains(tx.category)) {
      await addCategory(tx.category);
    }
    await loadTransactions();
  }

  Future<void> delete(ExpenseTransaction tx) async {
    if (tx.id == null) return;
    await ExpenseDatabase.instance.delete(tx.id!);
    await loadTransactions();
  }

  Future<void> addCategory(String name) async {
    if (name.trim().isEmpty) return;
    await ExpenseDatabase.instance.insertCategory(name.trim());
    await loadTransactions();
  }

  Future<void> removeCategory(String name) async {
    await ExpenseDatabase.instance.deleteCategory(name);
    await loadTransactions();
  }

  void applyQuickFilter(String mode) {
    final now = DateTime.now();
    if (mode == 'Today') {
      filter.startDate = DateTime(now.year, now.month, now.day);
      filter.endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (mode == 'This Week') {
      final start = now.subtract(Duration(days: max(0, now.weekday - 1)));
      filter.startDate = DateTime(start.year, start.month, start.day);
      filter.endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (mode == 'This Month') {
      filter.startDate = DateTime(now.year, now.month, 1);
      filter.endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    }
    notifyListeners();
  }

  void notifyFilterUpdated() => notifyListeners();
}
