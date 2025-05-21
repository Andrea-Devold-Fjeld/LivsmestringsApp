import 'package:flutter_test/flutter_test.dart';
import 'package:livsmestringapp/dto/chapter_dto.dart';
import 'package:livsmestringapp/dto/video_dto.dart';
import 'package:livsmestringapp/models/DataModel.dart';


void main() {
  group('VideoDTO Tests', () {
    test('fromMap should create a ChapterDTO with correct values', () {
      // Arrange
      final Map<String, dynamic> chapterMap = {
        'id': 1,
        'category_id': 2,
        'Title': 'Test Chapter',
        'Videos': [
          {
            'id': 10,
            'chapter_id': 1,
            'Title': 'Test Video 1',
            'LanguageUrls': {
              'en': 'https://example.com/video1_en',
              'nb': 'https://example.com/video1_nb',
            },
          },
          {
            'id': 11,
            'chapter_id': 1,
            'Title': 'Test Video 2',
            'LanguageUrls': {
              'en': 'https://example.com/video2_en',
            },
          },
        ],
      };

      // Act
      final chapter = Chapter.fromJson(chapterMap);
      // Assert
      expect(chapter.title, 'Test Chapter');
      expect(chapter.videos.length, 2);

      // Check first video
      expect(chapter.videos[0].title, 'Test Video 1');
      expect(chapter.videos[0].languageUrls['en'], 'https://example.com/video1_en');
      expect(chapter.videos[0].languageUrls['nb'], 'https://example.com/video1_nb');

      // Check second video
      expect(chapter.videos[1].title, 'Test Video 2');
      expect(chapter.videos[1].languageUrls['en'], 'https://example.com/video2_en');
      expect(chapter.videos[1].languageUrls['nb'], null);
    });

    test('fromMap should handle empty videos list', () {
      // Arrange
      final Map<String, dynamic> chapterMap = {
        'id': 1,
        'category_id': 2,
        'Title': 'Test Chapter',
        'Videos': [],
      };

      // Act
      final chapter = Chapter.fromJson(chapterMap);

      // Assert
      expect(chapter.title, 'Test Chapter');
      expect(chapter.videos.length, 0);
    });

    test('fromMap should handle missing videos key', () {
      // Arrange
      final Map<String, dynamic> chapterMap = {
        'id': 1,
        'category_id': 2,
        'Title': 'Test Chapter',
      };

      // Act
      final chapter = Chapter.fromJson(chapterMap);

      // Assert
      expect(chapter.title, 'Test Chapter');
      expect(chapter.videos.length, 0);
    });

    test('toMap should return a map with correct values', () {
      // Arrange
      final Map<String, dynamic> videoMap = {
        'id': 10,
        'chapter_id': 1,
        'title': 'Test Video 1',
        'url': 'https://example.com/video1',
        'language_code': 'en',
        'watched': 0,
        'total_length': '00:10:00',
        'watched_length': '00:05:00',
      };

      final videoMap2 = {
        'id': 11,
        'chapter_id': 1,
        'title': 'Test Video 2',
        'url': 'https://example.com/video2',
        'language_code': 'en',
        'watched': 0,
        'total_length': '00:20:00',
        'watched_length': '00:10:00',
      };

      final videoDto1 = VideoDTO.fromMap(videoMap);
      final videoDto2 = VideoDTO.fromMap(videoMap2);

      final chapter = ChapterDTO(
        id: 1,
        categoryId: 2,
        title: 'Test Chapter',
        videos: [videoDto1, videoDto2],
      );

      // Act
      final Map<String, dynamic> result = chapter.toMap();

      // Assert
      expect(result['id'], 1);
      expect(result['category_id'], 2);
      expect(result['title'], 'Test Chapter');
      expect(result['videos'], isA<List<dynamic>>());
      expect(result['videos'].length, 2);

      // Check first video in map
      expect(result['videos'][0]['id'], 10);
      expect(result['videos'][0]['chapter_id'], 1);
      expect(result['videos'][0]['title'], 'Test Video 1');
      expect(result['videos'][0]['url'], 'https://example.com/video1');
      expect(result['videos'][0]['url'], 'https://example.com/video1');

      // Check second video in map
      expect(result['videos'][1]['id'], 11);
      expect(result['videos'][1]['chapter_id'], 1);
      expect(result['videos'][1]['title'], 'Test Video 2');
      expect(result['videos'][1]['url'], 'https://example.com/video2');
    });

    test('roundtrip conversion should maintain data integrity', () {
      // Arrange
      final originalChapter = ChapterDTO(
        id: 1,
        categoryId: 2,
        title: 'Test Chapter',
        videos: [
          VideoDTO(
            id: 10,
            chapterId: 1,
            title: 'Test Video 1',
            url: 'https://example.com/video1',
          ),
        ],
      );

      // Act
      final Map<String, dynamic> map = originalChapter.toMap();
      final resultChapter = ChapterDTO.fromMap(map);

      // Assert
      expect(resultChapter.id, originalChapter.id);
      expect(resultChapter.categoryId, originalChapter.categoryId);
      expect(resultChapter.title, originalChapter.title);
      expect(resultChapter.videos.length, originalChapter.videos.length);

      // Check video in roundtrip conversion
      expect(resultChapter.videos[0].id, originalChapter.videos[0].id);
      expect(resultChapter.videos[0].chapterId, originalChapter.videos[0].chapterId);
      expect(resultChapter.videos[0].title, originalChapter.videos[0].title);
      /*
      expect(
          resultChapter.videos[0].url,
          originalChapter.videos[0].url
      );
      expect(
          resultChapter.videos[1].url,
          originalChapter.videos[1].url
      );

       */
    });
    group('Paring of the duration object', (){
      test('Parsing the duration string from db to duration object', (){
        // Arrange
        final String durationString = '00:10:05.010010';
        final Duration duration = Duration(days: 0, hours: 0, minutes: 10, seconds: 5, milliseconds: 10, microseconds: 10);

        // Act
        //#TODO fix this
        //final Duration? parsedDuration = parseDuration(durationString);
        // Assert
        //expect(parsedDuration, isNotNull);
        //expect(parsedDuration, duration);
      });
    });
  });
}