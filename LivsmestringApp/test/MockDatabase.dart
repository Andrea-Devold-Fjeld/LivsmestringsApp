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
