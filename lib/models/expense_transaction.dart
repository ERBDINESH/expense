import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseTransaction {
  ExpenseTransaction({
    this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.categoryName,
    required this.date,
    this.notes,
  });

  final String? id;
  final double amount;
  final String type;
  final String category; // This stores the category ID
  final String categoryName; // Helper for display
  final DateTime date;
  final String? notes;

  bool get isCredit => type.toLowerCase() == 'credit';

  ExpenseTransaction copyWith({
    String? id,
    double? amount,
    String? type,
    String? category,
    String? categoryName,
    DateTime? date,
    String? notes,
  }) {
    return ExpenseTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      categoryName: categoryName ?? this.categoryName,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'type': type.toLowerCase(),
      'categoryId': category,
      'categoryName': categoryName,
      'date': Timestamp.fromDate(date),
      'notes': notes ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory ExpenseTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpenseTransaction(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      type: data['type'] == 'credit' ? 'Credit' : 'Debit',
      category: data['categoryId'] as String,
      categoryName: data['categoryName'] as String? ?? '',
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
    );
  }

  // Still keeping fromMap/toMap for local if ever needed, but updating it to match
  factory ExpenseTransaction.fromMap(Map<String, dynamic> map) {
    return ExpenseTransaction(
      id: map['id']?.toString(),
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      category: map['category'] as String,
      categoryName: map['categoryName'] as String? ?? '',
      date: map['date'] is String ? DateTime.parse(map['date']) : (map['date'] as Timestamp).toDate(),
      notes: map['notes'] as String?,
    );
  }
}
