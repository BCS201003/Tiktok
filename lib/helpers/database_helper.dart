import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firestore import
import 'package:uuid/uuid.dart'; // Added Uuid import

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  /// Provides a singleton instance of the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the SQLite database
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Handles the creation of the SQLite database
  Future<void> _onCreate(Database db, int version) async {
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

  /// Handles database upgrades (e.g., adding new columns)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN uuid TEXT UNIQUE');
    }
  }

  /// Inserts a new user into the SQLite database
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves user data by UID from the SQLite database
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

  /// Updates specific fields of a user in the SQLite database
  Future<void> updateUser(String uid, Map<String, dynamic> updatedData) async {
    final db = await database;
    await db.update(
      'users',
      updatedData,
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  /// Adds missing UUIDs to Firestore users
  Future<void> addMissingUUIDs() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('users').get();
      for (var doc in snapshot.docs) {
        if (!doc.data().containsKey('uuid')) {
          String uuid = const Uuid().v4();
          await FirebaseFirestore.instance
              .collection('users')
              .doc(doc.id)
              .update({'uuid': uuid});
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding missing UUIDs: $e');
      }
    }
  }
}
