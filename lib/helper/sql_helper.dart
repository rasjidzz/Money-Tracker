import 'dart:async';
import 'package:sqflite/sqflite.dart' as sql;
// import 'package:money_tracker/model/category.dart';

class sqlHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""
    CREATE TABLE IF NOT EXISTS transactions(
      id TEXT PRIMARY KEY NOT NULL,
      amount REAL,
      date TEXT,
      category TEXT,
      type TEXT,
      note TEXT
    )
  """);

    //   await database.execute("""
    //   CREATE TABLE IF NOT EXISTS categories(
    //     id TEXT PRIMARY KEY NOT NULL,
    //     name TEXT,
    //     icon TEXT
    //   )
    // """);

    //   await database.execute('''
    //   CREATE TABLE IF NOT EXISTS wallets(
    //     id TEXT PRIMARY KEY NOT NULL,
    //     balance REAL
    //   )
    // ''');

    //   await database.rawInsert('''
    //   INSERT OR IGNORE INTO wallets(id, balance)
    //   VALUES('1', 0)
    // ''');
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'wallet_tracker.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Inisiasi database
  Future<void> initializeDatabase() async {
    final _database = await sqlHelper.db();
    await sqlHelper.createTables(_database);
    print('Database initialized');
  }

  Future<void> printData() async {
    print('Database initialized');
  }
}
