import 'dart:core';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:livsmestringapp/dto/category_dto.dart';
import 'package:sqflite/sqflite.dart';
import '../dto/chapter_dto.dart';
import '../dto/task_dto.dart';
import '../dto/video_dto.dart';
import '../models/DataModel.dart';
import '../models/cateregory.dart';

Duration? _parseDuration(String? durationString) {
  // Format from Duration.toString() is typically "0:00:00.000000"
  // or something similar
  if(durationString == null){
    return null;
  }

  // Remove any potential formatting from the toString() method
  durationString = durationString.replaceAll(RegExp(r'[^0-9:]'), '');

  List<String> parts = durationString.split(':');

  if (parts.length == 3) {
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);

    return Duration(
      hours: hours,
      minutes: minutes,
      microseconds: seconds,
    );
  }

  return Duration.zero; // Return default if parsing fails
}

Future<void> updateTotalVideoLength(Future<Database> futureDb, Duration duration, String url) async {
  final Database db = await futureDb;

  await db.transaction((txn) async {
    int update =await txn.update(
      'videos',
      {'total_length': duration.toString()},
    where: 'url = ?',
    whereArgs: [url]);
    if(update == 0){
      //#tODO check in tasks
    }
  });
}

Future<void> updateVideoWatchTime(Future<Database> futureDb, Duration duration, String url) async {
  final Database db = await futureDb;
  // check if wideo is watched
  var result = await db.query(
      'videos',
      columns: ['total_length'],
      where: 'url = ?',
      whereArgs: [url]
  );

  if (result.isNotEmpty) {
    var totalLength = result
        .first['total_length'] as String; // Ensure the type is String
    log("Total length $totalLength");

    // Split the total length string into hours, minutes, seconds, and milliseconds
    var totalLengthSplit = totalLength.split(":");

    if (totalLengthSplit.length == 3) {
      int hours = int.parse(totalLengthSplit[0]);
      int minutes = int.parse(totalLengthSplit[1]);
      var secondsMilli = totalLengthSplit[2].split('.');
      int seconds = int.parse(secondsMilli[0]);
      int milliseconds = int.parse(secondsMilli[1].substring(0, 3));
      int microseconds = int.parse(secondsMilli[1].substring(3));

      Duration watched = Duration(
          hours: hours,
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
          microseconds: microseconds
      );

      log("Watched duration: $watched");

      log((duration.inSeconds/watched.inSeconds).toString());
      // Check if the video is watched 95% or more
      if ((duration.inSeconds / watched.inSeconds) >= 0.95) {
        log("Video watched over 95%");


        await db.transaction((txn) async {
          int update = await txn.update(
              'videos',
              {'watched': 1},
              where: 'url = ?',
              whereArgs: [url]);
        });
      }
    }
    await db.transaction((txn) async {
      int update = await txn.update('videos',
          {'watched_length': duration.toString()},
          where: 'url = ?',
          whereArgs: [url]);
      if (update == 0) {
        //#tODO check in tasks
      }
    });
  }
}

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

    // Process each chapter
    if(model.chapters.isEmpty){
      return;
    }
    for (var chapter in model.chapters) {
      // Insert chapter
      final chapterId = await txn.insert(
        'chapters',
        {
          'category_id': categoryId,
          'title': chapter.title,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      // Process each video in the chapter
      for (var video in chapter.videos) {
        // For each language URL in the video
        for (var entry in video.languageUrls.entries) {
          final languageCode = entry.key;
          final videoUrl = entry.value;

          // Insert the video with language code
          final videoId = await txn.insert(
            'videos',
            {
              'chapter_id': chapterId,
              'title': video.title,
              'url': videoUrl,
              'watched': video.watched ? 1 : 0,
              'language_code': languageCode,
              'total_length': video.totalLength?.toString(),
              'watched_length': video.watchedLength?.toString(),
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
          // If this video has tasks
          if (video.tasks != null && video.tasks!.isNotEmpty) {
            for (var task in video.tasks!) {
              // If the task has this language
              if (task.languageUrls.containsKey(languageCode)) {
                await txn.insert(
                  'tasks',
                  {
                    'video_id': videoId,
                    'title': task.title,
                    'url': task.languageUrls[languageCode],
                    'watched': task.watched ? 1 : 0,
                    //'language_code': languageCode,
                  },
                  conflictAlgorithm: ConflictAlgorithm.ignore,
                );
              }
            }
          }
        }
      }
    }
  });
}

Future<CategoryDto> getDataModelWithLanguage(Future<Database> futureDb, String category, String language) async {
  try {
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

    final List<ChapterDto> chaptersList = await Future.wait(
      chapters.map((chapter) async {
        // Query videos with the specified language code
        final List<Map<String, dynamic>> videos = await db.query(
          'videos',
          where: 'chapter_id = ? AND language_code = ?',
          whereArgs: [chapter['id'], language],
        );

        final List<VideoDto> videosList = await Future.wait(
          videos.map((video) async {
            // Query tasks with the same language code
            final List<Map<String, dynamic>> tasks = await db.query(
              'tasks',
              where: 'video_id = ?',
              whereArgs: [video['id']],
            );

            return VideoDto(
              id: video['id'],
              title: video['title'],
              url: video['url'],
              languageCode: video['language_code'] ?? language,
              watched: video['watched'] == 1,
              totalLength: _parseDuration(video['total_length']),
              watchedLength: _parseDuration(video['watched_length']),
              tasks: tasks.map((task) => TaskDto(
                id: task['id'],
                title: task['title'],
                url: task['url'],
                videoId: video['id'],
                //languageCode: task['language_code'] ?? language,
                watched: task['watched'] == 1,
              )).toList(),
              chapterId: video['chapter_id'],
            );
          }),
        );

        return ChapterDto(
          id: chapter['id'],
          title: chapter['title'],
          videos: videosList,
          categoryId: categoryId,
        );
      }),
    );

    return CategoryDto(
        id: categoryId,
        chapters: chaptersList,
        name: category
    );
  } catch(e) {
    if (kDebugMode) {
      print('Error fetching data model: $e');
    }
    throw Exception('Failed to load data model: $e');
  }
}


/*
                tasks: tasks.map((task) => TaskDto(
                  title: task['title'],
                  url: task['url'],
                  videoId: video['id'],
                )..watched = task['watched'] == 1).toList(),
 */
/*
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
        log("videoList: $videosList");
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
*/

/*
Future<Datamodel> getDatamodelByLanguage(Future<Database> futureDb, String category, String language) async {
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
          where: 'chapter_id = ? AND language_code = ?',
          whereArgs: [chapter['id'], language],
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
        log("videoList: $videosList");
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

 */


Future<List<ChapterDto>> getAllWatchedVideosAndTasksByCategory(Future<Database> futureDb, int categoryId) async {
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
  List<ChapterDto> chapters = [];
  Map<int, ChapterDto> chapterMap = {};
  Map<int, VideoDto> videoMap = {};

  for (var row in result) {
    int chapterId = row['chapter_id'] as int;
    int videoId = row['video_id'] as int;
    int taskId = row['task_id'] as int;

    if (!chapterMap.containsKey(chapterId)) {
      chapterMap[chapterId] = ChapterDto(
        id: chapterId,
        categoryId: categoryId,
        title: row['chapter_title'] as String,
        videos: [],
      );
      chapters.add(chapterMap[chapterId]!);
    }

    if (!videoMap.containsKey(videoId)) {
      videoMap[videoId] = VideoDto(
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
      videoMap[videoId]!.tasks.add(TaskDto(
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

Future<List<CategoryClass>> getAllCategories(Future<Database> futureDb) async {
  try {
    final db = await futureDb;
    final List<Map<String, dynamic>> maps = await db.query('categories');

    return List.generate(maps.length, (i) {
      return CategoryClass.fromMap(maps[i]);
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

Future<ProgressModel> getProgress(Future<Database> futureDb, int categoryId, Locale locale) async {
  final Database db = await futureDb;

  final totalVideosResult = await db.rawQuery('''
    SELECT 
      (SELECT COUNT(*)
       FROM videos
       JOIN chapters ON videos.chapter_id = chapters.id
       WHERE chapters.category_id = ? AND videos.language_code = ?) +
      (SELECT COUNT(*)
       FROM tasks
       JOIN videos ON tasks.video_id = videos.id
       JOIN chapters ON videos.chapter_id = chapters.id
       WHERE chapters.category_id = ?) as total
  ''', [categoryId, locale.languageCode, categoryId]);
  log("In getProgress totalVideoResult: $totalVideosResult");
  final totalCount = Sqflite.firstIntValue(totalVideosResult) ?? 0;
  final query = '''
    SELECT 
      COUNT(DISTINCT videos.id) as watched_videos_count,
      COUNT(tasks.id) as watched_tasks_count
    FROM chapters 
    JOIN videos ON chapters.id = videos.chapter_id 
    LEFT JOIN tasks ON videos.id = tasks.video_id
    WHERE chapters.category_id = ? AND videos.language_code = ? AND (videos.watched = 1 OR tasks.watched = 1)
  ''';
  log("In getProgress total count : $totalCount");
  // Execute the query
  final result = await db.rawQuery(query, [categoryId, locale.languageCode]);

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