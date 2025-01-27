// lib/helpers/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    return await openDatabase(
      path,
      version: 2, // Incremented version number
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT UNIQUE,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        profilePhoto TEXT,
        uuid TEXT UNIQUE
      )
    ''');
  }

  /// Handles database upgrades
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add the uuid column if upgrading from version 1
      await db.execute('ALTER TABLE users ADD COLUMN uuid TEXT UNIQUE');
    }
  }

  /// Inserts a new user into the users table
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves user data by UID from the users table
  Future<Map<String, dynamic>?> getUserById(String uid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  /// Updates specific fields of a user in SQLite
  Future<void> updateUser(String uid, Map<String, dynamic> updatedData) async {
    final db = await database;
    await db.update(
      'users',
      updatedData,
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }
}
