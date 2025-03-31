import 'package:flutter_test/flutter_test.dart';
import 'package:livsmestringapp/databse/database_operation.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:livsmestringapp/models/DataModel.dart';
import 'package:livsmestringapp/models/VideoUrl.dart';
import 'database_test.mocks.dart'; // Import the generated mock

void main() {
  late MockDatabase mockDatabase;
  late MockTransaction mockTransaction;
  late Future<Database> futureDb;

  setUp(() {
    mockDatabase = MockDatabase();
    mockTransaction = MockTransaction();
    futureDb = Future.value(mockDatabase);
  });

  group('Database Tests', () {
    test('updateVideoWatchTime updates watched time correctly', () async {
      // Arrange
      when(mockDatabase.transaction(any)).thenAnswer((invocation) async {
        final transactionCallback = invocation.positionalArguments[0] as Function;
        await transactionCallback(mockTransaction);
        return null;
      });

      when(mockTransaction.update(
        'videos',
        {'watched_length': '0:05:00.000000'},
        where: 'url = ?',
        whereArgs: ['test_url'],
      )).thenAnswer((_) async => 1);

      // Act
      await updateVideoWatchTime(futureDb, Duration(minutes: 5), 'test_url');

      // Assert
      verify(mockDatabase.transaction(any)).called(1);
      verify(mockTransaction.update(
        'videos',
        {'watched_length': '0:05:00.000000'},
        where: 'url = ?',
        whereArgs: ['test_url'],
      )).called(1);
    });

    test('getDataModelWithLanguage returns correct data', () async {
      // Arrange
      when(mockDatabase.query('categories', where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [
        {'id': 1, 'name': 'Test Category'}
      ]);

      when(mockDatabase.query('chapters', where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [
        {'id': 1, 'category_id': 1, 'title': 'Chapter 1'}
      ]);

      when(mockDatabase.query('videos', where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => [
        {'id': 1, 'chapter_id': 1, 'title': 'Video 1', 'url': 'test_url', 'watched': 0}
      ]);

      when(mockDatabase.query('tasks', where: anyNamed('where'), whereArgs: anyNamed('whereArgs')))
          .thenAnswer((_) async => []);

      // Act
      final result = await getDataModelWithLanguage(futureDb, 'Test Category', 'en');

      // Assert
      expect(result.category, 'Test Category');
      expect(result.chapters.length, 1);
      expect(result.chapters[0].title, 'Chapter 1');
      expect(result.chapters[0].videos.length, 1);
      expect(result.chapters[0].videos[0].title, 'Video 1');
    });

    test('updateVideoWatchStatus updates watched status correctly', () async {
      // Arrange
      when(mockDatabase.transaction(any)).thenAnswer((invocation) async {
        final transactionCallback = invocation.positionalArguments[0] as Function;
        await transactionCallback(mockTransaction);
        return null;
      });

      when(mockTransaction.update(
        'videos',
        {'watched': 1},
        where: 'title = ?',
        whereArgs: ['Video 1'],
      )).thenAnswer((_) async => 1);

      // Act
      await updateVideoWatchStatus(futureDb, 'Video 1', true);

      // Assert
      verify(mockDatabase.transaction(any)).called(1);
      verify(mockTransaction.update(
        'videos',
        {'watched': 1},
        where: 'title = ?',
        whereArgs: ['Video 1'],
      )).called(1);
    });

    test('updateTaskWatchStatus updates watched status correctly', () async {
      // Arrange
      when(mockDatabase.transaction(any)).thenAnswer((invocation) async {
        final transactionCallback = invocation.positionalArguments[0] as Function;
        await transactionCallback(mockTransaction);
        return null;
      });

      when(mockTransaction.update(
        'tasks',
        {'watched': 1},
        where: 'url = ?',
        whereArgs: ['task_url'],
      )).thenAnswer((_) async => 1);

      // Act
      await updateTaskWatchStatus(futureDb, 'task_url', true);

      // Assert
      verify(mockDatabase.transaction(any)).called(1);
      verify(mockTransaction.update(
        'tasks',
        {'watched': 1},
        where: 'url = ?',
        whereArgs: ['task_url'],
      )).called(1);
    });
    test('getAllCategories returns all categories', () async {
      // Arrange
      when(mockDatabase.query('categories'))
          .thenAnswer((_) async => [
        {'id': 1, 'name': 'Category 1'},
        {'id': 2, 'name': 'Category 2'},
      ]);

      // Act
      final result = await getAllCategories(futureDb);

      // Assert
      expect(result.length, 2);
      expect(result[0].name, 'Category 1');
      expect(result[1].name, 'Category 2');
    });
    test('getProgress should return correct progress', () async {
      // Arrange: Mock total count of tasks and videos
      when(mockDatabase.rawQuery(
        '''
    SELECT 
      (SELECT COUNT(*) 
       FROM videos 
       JOIN chapters ON videos.chapter_id = chapters.id 
       WHERE chapters.category_id = ?) +
      (SELECT COUNT(*) 
       FROM tasks 
       JOIN videos ON tasks.video_id = videos.id 
       JOIN chapters ON videos.chapter_id = chapters.id 
       WHERE chapters.category_id = ?) AS total
    ''',
        [1, 1],
      )).thenAnswer((_) async => [{'total': 10}]);

      // Arrange: Mock watched videos and tasks
      when(mockDatabase.rawQuery(
        '''
    SELECT 
      COUNT(DISTINCT videos.id) AS watched_videos_count, 
      COUNT(tasks.id) AS watched_tasks_count
    FROM chapters 
    JOIN videos ON chapters.id = videos.chapter_id 
    LEFT JOIN tasks ON videos.id = tasks.video_id
    WHERE chapters.category_id = ? AND (videos.watched = 1 OR tasks.watched = 1)
    ''',
        [1],
      )).thenAnswer((_) async => [{'watched_videos_count': 3, 'watched_tasks_count': 2}]);

      // Act: Call the method
      final result = await getProgress(futureDb, 1);

      // Assert: Check expected values
      expect(result.totalVideos, 10); // Total videos/tasks count
      expect(result.watchedVideos, 5); // Watched videos + tasks
      expect(result.progress, 0.5);   // Progress = 5/10
    });
    test('getAllWatchedVideosAndTasksByCategory should return the correct structure', () async {
      // Arrange: Mock watched videos and tasks by category
      when(mockDatabase.rawQuery(
        '''
    SELECT 
      chapters.id AS chapter_id, 
      chapters.title AS chapter_title, 
      videos.id AS video_id, 
      videos.title AS video_title, 
      videos.url AS video_url, 
      videos.watched AS video_watched, 
      tasks.id AS task_id, 
      tasks.title AS task_title, 
      tasks.url AS task_url, 
      tasks.watched AS task_watched
    FROM chapters 
    JOIN videos ON chapters.id = videos.chapter_id 
    LEFT JOIN tasks ON videos.id = tasks.video_id
    WHERE chapters.category_id = ? AND (videos.watched = 1 OR tasks.watched = 1)
    ''',
        [1],
      )).thenAnswer((_) async => [
        {
          'chapter_id': 1,
          'chapter_title': 'Chapter 1',
          'video_id': 1,
          'video_title': 'Video 1',
          'video_url': 'video_url_1',
          'video_watched': 1,
          'task_id': 1,
          'task_title': 'Task 1',
          'task_url': 'task_url_1',
          'task_watched': 1,
        },
      ]);

      // Act: Call the method
      final result = await getAllWatchedVideosAndTasksByCategory(futureDb, 1);

      // Assert: Validate the result structure
      expect(result.length, 1); // 1 chapter
      final chapter = result[0];
      expect(chapter.title, 'Chapter 1'); // Chapter title
      expect(chapter.videos.length, 1); // 1 video in the chapter

      final video = chapter.videos[0];
      expect(video.title, 'Video 1'); // Validate video title
      expect(video.url, 'video_url_1'); // Validate video URL
      expect(video.tasks.length, 1); // 1 task in the video

      final task = video.tasks[0];
      expect(task.title, 'Task 1'); // Task title
      expect(task.url, 'task_url_1'); // Task URL
    });
  });
}