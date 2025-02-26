import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:livsmestringapp/dto/category_dto.dart';
import 'package:sqflite/sqflite.dart';
import '../dto/chapter_dto.dart';
import '../dto/task_dto.dart';
import '../dto/video_dto.dart';
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
        conflictAlgorithm: ConflictAlgorithm.ignore,
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
          conflictAlgorithm: ConflictAlgorithm.ignore,
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
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }
      }
    }
  });
}

// Updated method to retrieve data model with category
Future<Datamodel> getDataModel(Future<Database> futureDb, String category) async {
  try{
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
  }catch(e){
    if (kDebugMode) {
      print(e);
    }
    throw Exception();

  }
}


Future<List<ChapterDTO>> getAllWatchedVideosAndTasksByCategory(Future<Database> futureDb, int categoryId) async {
  final db = await futureDb;

  // Query to get watched videos and tasks by category
  final query = '''
    SELECT 
      chapters.id as chapter_id, 
      chapters.title as chapter_title, 
      videos.id as video_id, 
      videos.title as video_title, 
      videos.url as video_url, 
      videos.watched as video_watched, 
      tasks.id as task_id, 
      tasks.title as task_title, 
      tasks.url as task_url, 
      tasks.watched as task_watched
    FROM chapters 
    JOIN videos ON chapters.id = videos.chapter_id 
    LEFT JOIN tasks ON videos.id = tasks.video_id
    WHERE chapters.category_id = ? AND (videos.watched = 1 OR tasks.watched = 1)
  ''';

  // Execute the query
  final result = await db.rawQuery(query, [categoryId]);

  // Process the results into a hierarchical structure
  List<ChapterDTO> chapters = [];
  Map<int, ChapterDTO> chapterMap = {};
  Map<int, VideoDTO> videoMap = {};

  for (var row in result) {
    int chapterId = row['chapter_id'] as int;
    int videoId = row['video_id'] as int;
    int taskId = row['task_id'] as int;

    if (!chapterMap.containsKey(chapterId)) {
      chapterMap[chapterId] = ChapterDTO(
        id: chapterId,
        categoryId: categoryId,
        title: row['chapter_title'] as String,
        videos: [],
      );
      chapters.add(chapterMap[chapterId]!);
    }

    if (!videoMap.containsKey(videoId)) {
      videoMap[videoId] = VideoDTO(
        id: videoId,
        chapterId: chapterId,
        title: row['video_title'] as String,
        url: row['video_url'] as String,
        watched: row['video_watched'] == 1,
        tasks: [],
      );
      chapterMap[chapterId]!.videos.add(videoMap[videoId]!);
    }

    if (row['task_watched'] == 1) {
      videoMap[videoId]!.tasks.add(TaskDTO(
        id: taskId,
        videoId: videoId,
        title: row['task_title'] as String,
        url: row['task_url'] as String,
        watched: true,
      ));
    }
    }

  // Filter out videos that are not watched
  for (var chapter in chapters) {
    chapter.videos = chapter.videos.where((video) => video.watched || video.tasks.any((task) => task.watched)).toList();
  }

  return chapters;
}


// Helper methods also need to be updated to handle Future<Database>
Future<void> updateVideoWatchStatus(Future<Database> futureDb, String videoName, bool watched) async {
  final Database db = await futureDb;
  await db.transaction((txn) async {
    await txn.update(
      'videos',
      {'watched': watched ? 1 : 0},
      where: 'title = ?',
      whereArgs: [videoName],
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

Future<void> updateVideoUrl(Future<Database> futureDb, String videoName, String newUrl) async {
  final Database db = await futureDb;
  await db.transaction((txn) async {
    await txn.update(
      'videos',
      {'url': newUrl},
      where: 'title = ?',
      whereArgs: [videoName],
    );
  });
}

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

Future<List<CategoryDTO>> getAllCategories(Future<Database> futureDb) async {
  try {
    final db = await futureDb;
    final List<Map<String, dynamic>> maps = await db.query('categories');

    return List.generate(maps.length, (i) {
      return CategoryDTO.fromMap(maps[i]);
    });
  } catch (e) {
    throw Exception("An error happened with the db: $e");
  }
}

Future<List<Map<String, dynamic>>> getVideos(Database db, int chapterId){
  return db.query('videos',
    where: 'chapter_id = ?',
    whereArgs: [chapterId],
  );
}

Future<ProgressModel> getProgress(Future<Database> futureDb, int categoryId) async {
  final Database db = await futureDb;

  final totalVideosResult = await db.rawQuery('''
    SELECT 
      (SELECT COUNT(*)
       FROM videos
       JOIN chapters ON videos.chapter_id = chapters.id
       WHERE chapters.category_id = ?) +
      (SELECT COUNT(*)
       FROM tasks
       JOIN videos ON tasks.video_id = videos.id
       JOIN chapters ON videos.chapter_id = chapters.id
       WHERE chapters.category_id = ?) as total
  ''', [categoryId, categoryId]);

  final totalCount = Sqflite.firstIntValue(totalVideosResult) ?? 0;
  final query = '''
    SELECT 
      COUNT(DISTINCT videos.id) as watched_videos_count,
      COUNT(tasks.id) as watched_tasks_count
    FROM chapters 
    JOIN videos ON chapters.id = videos.chapter_id 
    LEFT JOIN tasks ON videos.id = tasks.video_id
    WHERE chapters.category_id = ? AND (videos.watched = 1 OR tasks.watched = 1)
  ''';

  // Execute the query
  final result = await db.rawQuery(query, [categoryId]);

  // Extract the counts from the result
  final watchedVideosCount = result[0]['watched_videos_count'] as int;
  final watchedTasksCount = result[0]['watched_tasks_count'] as int;

  var watchedCount = watchedTasksCount + watchedVideosCount;
  // Calculate progress percentage
  final double progress = totalCount > 0 ? watchedCount / totalCount : 0.0;

  return ProgressModel(totalVideos: totalCount, watchedVideos: watchedCount, categoryId: categoryId, progress: progress);
}

class ProgressModel {
  final int totalVideos;
  final int watchedVideos;
  final double progress;
  final int categoryId;

  ProgressModel({required this.totalVideos, required this.watchedVideos, required this.categoryId, required this.progress });

}