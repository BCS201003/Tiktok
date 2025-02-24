// lib/helpers/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Getter to access the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    return await openDatabase(
      path,
      version: 2, // Ensure this matches the latest schema version
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) {
        print('Database opened at path: $path');
      },
    );
  }

  // Create the users table
  Future _onCreate(Database db, int version) async {
    print('Creating database with version $version');
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT UNIQUE,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,
        profilePhoto TEXT NOT NULL,
        uuid TEXT,
        bio TEXT,
        followers TEXT,
        following TEXT
      )
    ''');
    print('Users table created successfully.');
  }

  // Handle database upgrades
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');
    if (oldVersion < 2) {
      // Add 'uuid' column
      await db.execute('ALTER TABLE users ADD COLUMN uuid TEXT');
      print('Added uuid column.');

      // Add 'bio' column
      await db.execute('ALTER TABLE users ADD COLUMN bio TEXT');
      print('Added bio column.');

      // Add 'followers' column
      await db.execute('ALTER TABLE users ADD COLUMN followers TEXT');
      print('Added followers column.');

      // Add 'following' column
      await db.execute('ALTER TABLE users ADD COLUMN following TEXT');
      print('Added following column.');
    }
    print('Database upgrade completed.');
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
      columns: [
        'uid',
        'name',
        'email',
        'profilePhoto',
        'uuid',
        'bio',
        'followers',
        'following'
      ],
      where: 'uid = ?',
      whereArgs: [uid],
    );
    if (maps.isNotEmpty) {
      print('User found: ${maps.first}');
      return maps.first;
    }
    print('No user found with uid: $uid');
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
    print('User with uid $uid updated with data: $updatedData');
  }

  /// Resets the database by deleting all tables (For Development Only)
  Future<void> resetDatabase() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS users');
    print('Users table dropped.');
    await _onCreate(db, 2); // Recreate the table with version 2
    print('Database reset completed.');
  }
}
