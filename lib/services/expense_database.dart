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
      version: 3, // Incremented version
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            type TEXT NOT NULL,
            category TEXT NOT NULL,
            categoryName TEXT NOT NULL,
            date TEXT NOT NULL,
            notes TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Migration to add categoryName
          await db.execute('ALTER TABLE transactions ADD COLUMN categoryName TEXT DEFAULT ""');
        }
      },
    );
  }

  Future<Database> get db async {
    if (_database == null) {
      await init();
    }
    return _database!;
  }

  // Transactions
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

  // Categories
  Future<List<String>> getCategories() async {
    final database = await db;
    final maps = await database.query('categories', orderBy: 'name ASC');
    return maps.map((m) => m['name'] as String).toList();
  }

  Future<int> insertCategory(String name) async {
    final database = await db;
    return database.insert('categories', {'name': name}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> deleteCategory(String name) async {
    final database = await db;
    await database.delete('categories', where: 'name = ?', whereArgs: [name]);
  }
}
