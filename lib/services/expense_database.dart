import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/expense_transaction.dart';

class ExpenseDatabase {
  ExpenseDatabase._();

  static final ExpenseDatabase instance = ExpenseDatabase._();
  Database? _database;

  Future<void> init() async {
    if (_database != null) return;
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      join(dbPath, 'expense.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            notes TEXT
          )
        ''');
      },
    );
  }

  Future<Database> get db async {
    if (_database == null) {
      await init();
    }
    return _database!;
  }

  Future<List<ExpenseTransaction>> getAll() async {
    final database = await db;
    final maps = await database.query('transactions', orderBy: 'date DESC');
    return maps.map(ExpenseTransaction.fromMap).toList();
  }

  Future<int> insert(ExpenseTransaction transaction) async {
    final database = await db;
    return database.insert('transactions', transaction.toMap());
  }

  Future<void> update(ExpenseTransaction transaction) async {
    final database = await db;
    await database.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> delete(int id) async {
    final database = await db;
    await database.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
