import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/expense_transaction.dart';
import '../models/app_category.dart';
import '../services/firebase_service.dart';

class ExpenseFilter {
  DateTime? startDate;
  DateTime? endDate;
  String? categoryId;
  String? type;

  ExpenseFilter() {
    _setInitialMonth();
  }

  void _setInitialMonth() {
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }

  void reset() {
    _setInitialMonth();
    categoryId = null;
    type = null;
  }
}

class ExpenseProvider extends ChangeNotifier {
  final ExpenseFilter filter = ExpenseFilter();
  final FirebaseService _firebaseService = FirebaseService();
  bool isLoading = false;
  bool isProcessing = false;
  
  List<ExpenseTransaction> _transactions = [];
  List<AppCategory> _defaultCategories = [];
  List<AppCategory> _customCategories = [];
  List<Map<String, dynamic>> _fixedCosts = [];
  final Set<String> _pendingDeletionIds = {};
  double dailyLimit = 500.0;
  
  StreamSubscription? _transactionsSubscription;
  StreamSubscription? _defaultCategoriesSubscription;
  StreamSubscription? _customCategoriesSubscription;
  StreamSubscription? _fixedCostsSubscription;

  List<ExpenseTransaction> get transactions => _transactions;
  List<Map<String, dynamic>> get fixedCosts => _fixedCosts;
  
  List<AppCategory> get allCategories {
    final list = [..._defaultCategories, ..._customCategories]
        .where((cat) => !_pendingDeletionIds.contains(cat.id))
        .toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  List<ExpenseTransaction> get filteredTransactions {
    return _transactions.where((tx) {
      final inRange = (filter.startDate == null ||
              !tx.date.isBefore(filter.startDate!)) &&
          (filter.endDate == null || !tx.date.isAfter(filter.endDate!));
      final inCategory = filter.categoryId == null || tx.category == filter.categoryId;
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

  double get totalDebit => _transactions
      .where((e) => !e.isCredit)
      .fold(0.0, (sum, e) => sum + e.amount);
  double get totalCredit =>
      _transactions.where((e) => e.isCredit).fold(0.0, (sum, e) => sum + e.amount);
  double get netBalance => totalCredit - totalDebit;

  double get totalBalance => netBalance; // Standardized name for clarity

  Map<String, double> get categoryTotals {
    final result = <String, double>{};
    for (final tx in filteredTransactions.where((e) => !e.isCredit)) {
      result[tx.categoryName] = (result[tx.categoryName] ?? 0) + tx.amount;
    }
    return Map.fromEntries(
      result.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  // --- Dynamic Spending Control Logic ---

  double get upcomingFixedCosts {
    final today = DateTime.now().day;
    return _fixedCosts
        .where((cost) => (cost['dayOfMonth'] as int) >= today)
        .fold(0.0, (sum, cost) => sum + (cost['amount'] as num).toDouble());
  }

  double get availableBalance => netBalance - upcomingFixedCosts;

  double get dynamicDailyBudget {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    final remainingDays = lastDay - now.day + 1;
    if (remainingDays <= 0) return availableBalance;
    final budget = availableBalance / remainingDays;
    return budget > 0 ? budget : 0.0;
  }

  double get todaySpent {
    final now = DateTime.now();
    return _transactions.where((tx) => 
      tx.date.day == now.day && 
      tx.date.month == now.month && 
      tx.date.year == now.year &&
      !tx.isCredit
    ).fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get remainingToday => dynamicDailyBudget - todaySpent;

  double get safeToSpendPerHour {
    final hoursLeft = max(1, 24 - DateTime.now().hour);
    final safe = remainingToday / hoursLeft;
    return safe > 0 ? safe : 0.0;
  }

  String? get weeklyInsight {
    final now = DateTime.now();
    final last7Days = _transactions.where((tx) => 
      !tx.isCredit && 
      tx.date.isAfter(now.subtract(const Duration(days: 7)))
    ).toList();

    if (last7Days.length < 3) return null;

    final daySpending = <int, double>{};
    for (var tx in last7Days) {
      daySpending[tx.date.weekday] = (daySpending[tx.date.weekday] ?? 0) + tx.amount;
    }

    final highestDay = daySpending.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final dayNames = {
      1: 'Monday', 2: 'Tuesday', 3: 'Wednesday', 4: 'Thursday', 
      5: 'Friday', 6: 'Saturday', 7: 'Sunday'
    };

    if (highestDay >= 6) return "You spend more on weekends.";
    return "Your highest spending day is ${dayNames[highestDay]}.";
  }

  AppCategory? get mostFrequentCategory {
    if (_transactions.isEmpty) return null;
    
    final counts = <String, int>{};
    for (var tx in _transactions) {
      counts[tx.category] = (counts[tx.category] ?? 0) + 1;
    }

    if (counts.isEmpty) return null;
    
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topId = sorted.first.key;
    
    return allCategories.firstWhereOrNull((c) => c.id == topId);
  }

  // --- Initialization & Listeners ---

  Future<void> init() async {
    print("Provider: Initializing...");
    isLoading = true;
    notifyListeners();
    
    FirebaseAuth.instance.idTokenChanges().listen((user) {
      print("Provider: Auth changed. User: ${user?.uid}");
      _setupListeners();
    });

    if (FirebaseAuth.instance.currentUser != null) {
      _setupListeners();
    }

    isLoading = false;
    notifyListeners();
  }

  void _setupListeners() {
    _transactionsSubscription?.cancel();
    _defaultCategoriesSubscription?.cancel();
    _customCategoriesSubscription?.cancel();
    _fixedCostsSubscription?.cancel();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      isLoading = true;
      notifyListeners();

      _transactionsSubscription = _firebaseService.getTransactionsStream(user.uid).listen((txs) {
        _transactions = txs;
        isLoading = false;
        notifyListeners();
      });

      _defaultCategoriesSubscription = _firebaseService.getDefaultCategoriesStream().listen((defaults) {
        _defaultCategories = defaults;
        notifyListeners();
      });

      _customCategoriesSubscription = _firebaseService.getUserCategoriesStream(user.uid).listen((customs) {
        _customCategories = customs;
        _pendingDeletionIds.removeWhere((id) => !customs.any((c) => c.id == id));
        notifyListeners();
      });

      _firebaseService.userDataStream(user.uid).listen((userData) {
        if (userData != null) {
          dailyLimit = userData.dailyLimit;
          notifyListeners();
        }
      });

      _fixedCostsSubscription = _firebaseService.getFixedCostsStream(user.uid).listen((costs) {
        _fixedCosts = costs;
        notifyListeners();
      });
    } else {
      _transactions = [];
      _defaultCategories = [];
      _customCategories = [];
      _fixedCosts = [];
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    isLoading = true;
    notifyListeners();
    _setupListeners();
    isLoading = false;
    notifyListeners();
  }

  // --- Actions ---

  Future<void> add(ExpenseTransaction tx) async {
    isProcessing = true;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) await _firebaseService.addTransaction(user.uid, tx);
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> addQuickExpense(double amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final freq = mostFrequentCategory;
    
    final tx = ExpenseTransaction(
      amount: amount,
      type: 'Debit',
      category: freq?.id ?? 'misc',
      categoryName: freq?.name ?? 'Misc',
      date: DateTime.now(),
      notes: 'Quick add',
    );
    await add(tx);
  }

  Future<void> update(ExpenseTransaction tx) async {
    isProcessing = true;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) await _firebaseService.updateTransaction(user.uid, tx);
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> delete(ExpenseTransaction tx) async {
    if (tx.id == null) return;
    isProcessing = true;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) await _firebaseService.deleteTransaction(user.uid, tx.id!);
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> addCustomCategory(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      isProcessing = true;
      notifyListeners();
      try {
        await _firebaseService.addCustomCategory(user.uid, name);
      } finally {
        isProcessing = false;
        notifyListeners();
      }
    }
  }

  Future<void> removeCustomCategory(String categoryId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _pendingDeletionIds.add(categoryId);
      notifyListeners();
      try {
        await _firebaseService.deleteCustomCategory(user.uid, categoryId);
      } catch (e) {
        _pendingDeletionIds.remove(categoryId);
        notifyListeners();
      }
    }
  }

  Future<void> updateDailyLimit(double limit) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) await _firebaseService.updateDailyLimit(user.uid, limit);
  }

  Future<void> addFixedCost(String name, double amount, int day) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) await _firebaseService.addFixedCost(user.uid, name, amount, day);
  }

  Future<void> deleteFixedCost(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) await _firebaseService.deleteFixedCost(user.uid, id);
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

  @override
  void dispose() {
    _transactionsSubscription?.cancel();
    _defaultCategoriesSubscription?.cancel();
    _customCategoriesSubscription?.cancel();
    _fixedCostsSubscription?.cancel();
    super.dispose();
  }
}
