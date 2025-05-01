import 'package:livsmestringapp/databse/database-helper.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';



import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class TestDatabaseHelper {
  Future<Database> getTestDatabase() async {
    // Initialize sqflite_common_ffi
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    return openDatabase(
      inMemoryDatabasePath, // Use SQLite in-memory database
      version: 1,
      onCreate: (db, version) async {
        // Create tables for testing
        await db.execute(createCategoriesTable);
        await db.execute(createChaptersTable);
        await db.execute(createVideosTable);
        await db.execute(createTasksTable);

        await db.insert("categories", Map.of({"name": "career"}));
        await db.insert("categories", Map.of({"name": "health"}));

      },
    );
  }
}// Mock class for the database helper

class MockDatabaseHelper implements DatabaseHelper {
  @override
  Future<Database> get db async {
    // Return a mock or in-memory database
    return await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        // Create tables for testing
        await db.execute(createCategoriesTable);
        await db.execute(createChaptersTable);
        await db.execute(createVideosTable);
        await db.execute(createTasksTable);
      },
    );
  }

  @override
  Future<void> onCreate(Database db, int version) {
    // TODO: implement onCreate
    throw UnimplementedError();
  }
}

class MockDatabase extends Mock implements Database {
  final Map<String, List<Map<String, Object?>>> _tables = {};

  @override
  Future<int> insert(String table, Map<String, Object?> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) async {
    _tables.putIfAbsent(table, () => []);
    _tables[table]!.add(values);
    return 1; // Simulate successful insert returning row ID
  }

  @override
  Future<List<Map<String, Object?>>> query(String table, {bool? distinct, List<String>? columns, String? where, List<Object?>? whereArgs, String? groupBy, String? having, String? orderBy, int? limit, int? offset}) async {
    return _tables[table] ?? [];
  }

  @override
  Future<int> update(String table, Map<String, Object?> values, {String? where, List<Object?>? whereArgs, ConflictAlgorithm? conflictAlgorithm}) async {
    if (_tables.containsKey(table)) {
      for (var row in _tables[table]!) {
        if (whereArgs != null && row[where!.split(' = ')[0]] == whereArgs[0]) {
          row.addAll(values);
          return 1; // Simulate one row updated
        }
      }
    }
    return 0; // No rows updated
  }

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) async {
    if (_tables.containsKey(table)) {
      _tables[table]!.removeWhere((row) => whereArgs != null && row[where!.split(' = ')[0]] == whereArgs[0]);
      return 1; // Simulate one row deleted
    }
    return 0; // No rows deleted
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    // Simulate raw query by returning all rows from the first table in the query
    final tableName = sql.split('FROM ')[1].split(' ')[0];
    return _tables[tableName] ?? [];
  }

  @override
  Future<void> close() async {
    _tables.clear(); // Simulate closing the database
  }
}
