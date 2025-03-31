import 'package:sqflite/sqflite.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livsmestringapp/databse/database-helper.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database_test.mocks.dart';
import 'dart:io';
import 'package:path/path.dart';






class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  Database? _db;

  // Getter for the database instance
  Future<Database> get database async {
    if (_db == null) {
      _db = await initializeDatabase();
    }
    return _db!;
  }

  // Initialize the database
  Future<Database> initializeDatabase() async {
    return await openDatabase(
      'app_database.db',
      version: 1,
      onCreate: _createDb,
    );
  }

  // Create database tables
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE chapters(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE videos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        chapter_id INTEGER NOT NULL,
        FOREIGN KEY (chapter_id) REFERENCES chapters (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        video_id INTEGER NOT NULL,
        FOREIGN KEY (video_id) REFERENCES videos (id)
      )
    ''');
  }
  // Method to manually invoke the onCreate logic during tests
  Future<void> runOnCreate(Database mockDb) async {
    await _createDb(mockDb, 1);
  }


  // Allow mock database injection for testing
  void setTestDatabase(Database? mockDb) {
    _db = mockDb;
  }
}
void main() {
  late DatabaseHelper databaseHelper;
  late MockDatabase mockDatabase; // Mocked database instance

  // SQL schema constants for verification
  const String SQL_CREATE_CATEGORIES_TABLE = '''
    CREATE TABLE categories(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE
    );
  ''';

  const String SQL_CREATE_CHAPTERS_TABLE = '''
    CREATE TABLE chapters(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      category_id INTEGER NOT NULL,
      FOREIGN KEY (category_id) REFERENCES categories (id)
    );
  ''';

  const String SQL_CREATE_VIDEOS_TABLE = '''
    CREATE TABLE videos(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      chapter_id INTEGER NOT NULL,
      FOREIGN KEY (chapter_id) REFERENCES chapters (id)
    );
  ''';

  const String SQL_CREATE_TASKS_TABLE = '''
    CREATE TABLE tasks(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      video_id INTEGER NOT NULL,
      FOREIGN KEY (video_id) REFERENCES videos (id)
    );
  ''';

  setUpAll(() {
    // Initialize sqflite_common_ffi for SQLite testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi; // Set database factory for testing
  });

  setUp(() async {
    mockDatabase = MockDatabase();
    databaseHelper = DatabaseHelper.instance;

    // Delete the database file to ensure no tables exist
    final databasePath = await databaseFactory.getDatabasesPath();
    final dbFile = join(databasePath, 'app_database.db');
    if (File(dbFile).existsSync()) {
      File(dbFile).deleteSync(); // Delete the database file
    }

    databaseHelper.setTestDatabase(mockDatabase);
  });

  test('Database initialization should create tables and insert initial data', () async {
    // Arrange: Mock the database actions
    when(mockDatabase.execute(any)).thenAnswer((_) async => null);
    when(mockDatabase.insert(any, any)).thenAnswer((_) async => 1);


    await databaseHelper.runOnCreate(mockDatabase);


    verify(mockDatabase.execute(argThat(contains('CREATE TABLE categories')))).called(1);
    verify(mockDatabase.execute(argThat(contains('CREATE TABLE chapters')))).called(1);
    verify(mockDatabase.execute(argThat(contains('CREATE TABLE videos')))).called(1);
    verify(mockDatabase.execute(argThat(contains('CREATE TABLE tasks')))).called(1);
  });






  test('Insert category should return inserted row ID', () async {

    const int expectedRowId = 1;
    final Map<String, Object> categoryData = {'name': 'career'};

    when(mockDatabase.insert(
      any,
      any,
      conflictAlgorithm: anyNamed('conflictAlgorithm'),
    )).thenAnswer((_) async => expectedRowId);


    final result = await databaseHelper.database.then(
            (db) => db.insert('categories', categoryData, conflictAlgorithm: ConflictAlgorithm.replace));


    expect(result, expectedRowId);
    verify(mockDatabase.insert('categories', categoryData, conflictAlgorithm: ConflictAlgorithm.replace)).called(1);
  });
  test('Insert duplicate category should throw unique constraint violation', () async {

      final String uniqueConstraintError = 'UNIQUE constraint failed: categories.name';
      when(mockDatabase.insert(
        any,
        any,
        conflictAlgorithm: anyNamed('conflictAlgorithm'),
      )).thenThrow(Exception(uniqueConstraintError));

      final Map<String, Object> duplicateCategory = {'name': 'career'};


      expect(
            () => mockDatabase.insert('categories', duplicateCategory),
        throwsA(isA<Exception>()),
      );
    });

}
