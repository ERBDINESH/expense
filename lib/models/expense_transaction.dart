class ExpenseTransaction {
  ExpenseTransaction({
    this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.notes,
  });

  final int? id;
  final double amount;
  final String type;
  final String category;
  final DateTime date;
  final String? notes;

  bool get isCredit => type == 'Credit';

  ExpenseTransaction copyWith({
    int? id,
    double? amount,
    String? type,
    String? category,
    DateTime? date,
    String? notes,
  }) {
    return ExpenseTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory ExpenseTransaction.fromMap(Map<String, dynamic> map) {
    return ExpenseTransaction(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
    );
  }
}
