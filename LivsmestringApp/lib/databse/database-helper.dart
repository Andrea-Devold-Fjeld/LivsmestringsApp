import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';



final String createCategoriesTable = '''
  CREATE TABLE categories(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
  );
''';

final String lastUpdated = '''
  CREATE TABLE last_updated(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  last_updated TEXT NOT  NULL
  );
''';
final String createChaptersTable = '''
  CREATE TABLE chapters(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    UNIQUE(category_id, title),
    FOREIGN KEY (category_id) REFERENCES categories (id)
      ON DELETE CASCADE
  );
''';

final String createVideosTable = '''
  CREATE TABLE videos(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    chapter_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    url TEXT NOT NULL,
    watched INTEGER NOT NULL DEFAULT 0,
    language_code TEXT NOT NULL,
    total_length TEXT,
    watched_length TEXT, 
    FOREIGN KEY (chapter_id) REFERENCES chapters (id)
      ON DELETE CASCADE
  );
''';
//     UNIQUE(chapter_id, url),
final String createTasksTable = '''
  CREATE TABLE tasks(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    video_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    url TEXT NOT NULL,
    watched INTEGER NOT NULL DEFAULT 0,
    total_length TEXT,
    watched_length TEXT, 
    UNIQUE(video_id, title),
    FOREIGN KEY (video_id) REFERENCES videos (id)
      ON DELETE CASCADE
  );
''';
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get db async {
    if (_db != null) return _db!;

    _db = await _initDb();
    return _db!;
  }

  Future<void> onCreate(Database db, int version) async {
    // Create tables
    await db.execute(createCategoriesTable);
    await db.execute(createChaptersTable);
    await db.execute(createVideosTable);
    await db.execute(createTasksTable);

    //var category = Category(name: "career", chapters: List.empty());
    //Map.of({"name": "career"});
    await db.insert("categories", Map.of({"name": "career"}));
    await db.insert("categories", Map.of({"name": "health"}));

    // Create indices for better query performance
    await db.execute('''
    CREATE INDEX idx_chapters_category
    ON chapters(category_id);
  ''');

    await db.execute('''
    CREATE INDEX idx_videos_chapter
    ON videos(chapter_id);
  ''');

    await db.execute('''
    CREATE INDEX idx_tasks_video
    ON tasks(video_id);
  ''');
  }


  Future<Database> _initDb() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: onCreate
    );

  }
}