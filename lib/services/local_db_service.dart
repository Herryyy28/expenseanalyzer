import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class LocalDBService {
  static final LocalDBService _instance = LocalDBService._internal();
  factory LocalDBService() => _instance;
  LocalDBService._internal();

  static Database? _database;

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'expense_analyzer.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create tables
  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        name TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        date INTEGER NOT NULL,
        is_synced INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        period TEXT NOT NULL,
        start_date INTEGER NOT NULL,
        end_date INTEGER NOT NULL,
        is_synced INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Predictions table
    await db.execute('''
      CREATE TABLE predictions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        category TEXT NOT NULL,
        predicted_amount REAL NOT NULL,
        prediction_date INTEGER NOT NULL,
        confidence REAL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better query performance
    await db.execute('CREATE INDEX idx_expenses_user_id ON expenses(user_id)');
    await db.execute('CREATE INDEX idx_expenses_date ON expenses(date)');
    await db.execute('CREATE INDEX idx_expenses_category ON expenses(category)');
    await db.execute('CREATE INDEX idx_budgets_user_id ON budgets(user_id)');
    await db.execute('CREATE INDEX idx_predictions_user_id ON predictions(user_id)');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema changes here
    if (oldVersion < 2) {
      // Example: Add new column in version 2
      // await db.execute('ALTER TABLE expenses ADD COLUMN new_column TEXT');
    }
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Clear all data (useful for logout)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('expenses');
    await db.delete('budgets');
    await db.delete('predictions');
    await db.delete('users');
  }

  /// Get database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;

    final expenseCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM expenses')
    ) ?? 0;

    final budgetCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM budgets')
    ) ?? 0;

    final predictionCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM predictions')
    ) ?? 0;

    return {
      'expenses': expenseCount,
      'budgets': budgetCount,
      'predictions': predictionCount,
    };
  }
}