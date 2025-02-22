import 'dart:developer';
import 'package:sqflite/sqflite.dart';

import '../models/DataModel.dart';

// Updated insert method for the new schema
Future<void> insertDataModel(Future<Database> futureDb, Datamodel model) async {
  final Database db = await futureDb;

  await db.transaction((txn) async {
    // Insert or get category
    final List<Map<String, dynamic>> existingCategories = await txn.query(
      'categories',
      where: 'name = ?',
      whereArgs: [model.category],
    );

    final int categoryId = existingCategories.isEmpty
        ? await txn.insert(
      'categories',
      {'name': model.category},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    )
        : existingCategories.first['id'];

    // Insert chapters with category reference
    for (var chapter in model.chapters) {
      final chapterId = await txn.insert(
        'chapters',
        {
          'category_id': categoryId,
          'title': chapter.title,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert videos
      for (var video in chapter.videos) {
        final videoId = await txn.insert(
          'videos',
          {
            'chapter_id': chapterId,
            'title': video.title,
            'url': video.url,
            'watched': video.watched ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        // Insert tasks if they exist
        if (video.tasks != null) {
          for (var task in video.tasks!) {
            await txn.insert(
              'tasks',
              {
                'video_id': videoId,
                'title': task.title,
                'url': task.url,
                'watched': task.watched ? 1 : 0,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      }
    }
  });
}

// Updated method to retrieve data model with category
Future<Datamodel> getDataModel(Future<Database> futureDb, String category) async {
  final Database db = await futureDb;

  // Get category ID
  final List<Map<String, dynamic>> categoryResult = await db.query(
    'categories',
    where: 'name = ?',
    whereArgs: [category],
  );

  if (categoryResult.isEmpty) {
    throw Exception('Category not found: $category');
  }

  final categoryId = categoryResult.first['id'];

  // Get chapters for this category
  final List<Map<String, dynamic>> chapters = await db.query(
    'chapters',
    where: 'category_id = ?',
    whereArgs: [categoryId],
  );

  final List<Chapter> chaptersList = await Future.wait(
    chapters.map((chapter) async {
      final List<Map<String, dynamic>> videos = await db.query(
        'videos',
        where: 'chapter_id = ?',
        whereArgs: [chapter['id']],
      );

      final List<Video> videosList = await Future.wait(
        videos.map((video) async {
          final List<Map<String, dynamic>> tasks = await db.query(
            'tasks',
            where: 'video_id = ?',
            whereArgs: [video['id']],
          );

          return Video(
            title: video['title'],
            url: video['url'],
            tasks: tasks.map((task) => Task(
              title: task['title'],
              url: task['url'],
            )..watched = task['watched'] == 1).toList(),
          )..watched = video['watched'] == 1;
        }),
      );

      return Chapter(
        title: chapter['title'],
        videos: videosList,
      );
    }),
  );

  return Datamodel(chapters: chaptersList, category: category);
}


// Helper methods also need to be updated to handle Future<Database>
Future<void> updateVideoWatchStatus(Future<Database> futureDb, String videoUrl, bool watched) async {
  final Database db = await futureDb;
  await db.transaction((txn) async {
    await txn.update(
      'videos',
      {'watched': watched ? 1 : 0},
      where: 'url = ?',
      whereArgs: [videoUrl],
    );
  });
}

Future<void> updateTaskWatchStatus(Future<Database> futureDb, String taskUrl, bool watched) async {
  final Database db = await futureDb;
  await db.transaction((txn) async {
    await txn.update(
      'tasks',
      {'watched': watched ? 1 : 0},
      where: 'url = ?',
      whereArgs: [taskUrl],
    );
  });
}

//Future<List<String>> getChaptersFromCategory(Future<Database> futureDb) async {

  /*
  futureDb.then(
    (db) =>
        db.query(
          'categories',
        ),
  ).then(
      (categoryResult){
        Map<String, List<String>> chapters = {};
        categoryResult.forEach(
          (category){
            log("in getchapter: $category");
          }
        );
        final categoryId =  categoryResult.first['id'];
        return futureDb.then(
            (db) => db.query(
              'videos',
              where: 'category_id = ?',
              whereArgs: [categoryId],
            )
            );
      }

  ).onError(() = throw Exception());
  /*
  final List<Map<String, dynamic>> categoryResult = await db.query(
    'categories',
    where: 'name = ?',
    whereArgs: [category],
  );

   */

   */
//}

Future<List<Map<String, dynamic>>> getCategoryId(Database db, String category) {
  return db.query(
    'categories',
    where: 'name = ?',
    whereArgs: [category],
  );
}

Future<List<Map<String, dynamic>>> getChapters(Database db, int categoryId) {
  return db.query(
    'chapters',
    where: 'category_id = ?',
    whereArgs: [categoryId],
  );
}

Future<List<Map<String, dynamic>>> getAllCategories(Database db){
  return db.query(
    'categories',
  );
}
Future<void> getChaptersWithCategory(Future<Database> futureDb)async {
  futureDb.then((db) {
    return getAllCategories(db)
        .then((categoryResult) {
          log("category $categoryResult");
    });
  });
}


Future<Map<String, dynamic>> getProgress(Future<Database> futureDb) async {
  final Database db = await futureDb;

  // Get total counts
  final totalVideosResult = await db.rawQuery('''
    SELECT 
      (SELECT COUNT(*) FROM videos) +
      (SELECT COUNT(*) FROM tasks) as total
  ''');
  final totalCount = Sqflite.firstIntValue(totalVideosResult) ?? 0;

  // Get watched counts
  final watchedResult = await db.rawQuery('''
    SELECT 
      (SELECT COUNT(*) FROM videos WHERE watched = 1) +
      (SELECT COUNT(*) FROM tasks WHERE watched = 1) as watched
  ''');
  final watchedCount = Sqflite.firstIntValue(watchedResult) ?? 0;

  // Calculate progress percentage
  final double progress = totalCount > 0 ? watchedCount / totalCount : 0.0;

  return {
    'totalVideos': totalCount,
    'watchedVideos': watchedCount,
    'progress': progress,
  };
}

final String categoryTable = 'categories';
final String categoryId = 'id';
final String categoryName = 'name';

class Categories {
  final int? id;
  final String name;

  Categories({this.id, required this.name});

  factory Categories.fromMap(Map<String, dynamic> json) => Categories(
    id: json['id'],
    name: json['name'],
  );

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}

class Chapters {
  final int? id;
  final int? categoryId;
  final String title;

  Chapters({this.id, required this.categoryId, required this.title});

  factory Chapters.fromMap(Map<String, dynamic> json) => Chapters(
      categoryId: json['category_id'],
      title: json['title']
  );

  Map<String, dynamic> toMap() {
    return {'id': id, 'category_id': categoryId, 'title': title};
  }
}
/*
  CREATE TABLE videos(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    chapter_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    url TEXT NOT NULL,
    watched INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (chapter_id) REFERENCES chapters (id)
      ON DELETE CASCADE
  );
'''

 */
class Videos {
  final int? id;
  final int chapterId;
  final String title;
  final String url;
  final bool watched;


  Videos({this.id,required this.chapterId,required this.title,required this.url,required this.watched});

  factory Videos.fromMap(Map<String, dynamic> json) => Videos(
      chapterId: json['chapter_id'],
      title: json['title'],
      url: json['url'],
      watched: json['watched'] == 1
  );

  Map<String, dynamic> toMap() {
    return {'id': id, 'chapter_id': chapterId,
  };

}
}