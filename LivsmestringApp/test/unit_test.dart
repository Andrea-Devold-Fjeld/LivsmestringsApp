import 'package:flutter_test/flutter_test.dart';
import 'package:livsmestringapp/dto/chapter_dto.dart';
import 'package:livsmestringapp/dto/video_dto.dart';
import 'package:livsmestringapp/models/DataModel.dart';
import 'package:livsmestringapp/services/parse_duration.dart';


void main() {
  group('VideoDto Tests', () {
    test('fromMap should create a ChapterDto with correct values', () {
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

      final VideoDto1 = VideoDto.fromMap(videoMap);
      final VideoDto2 = VideoDto.fromMap(videoMap2);

      final chapter = ChapterDto(
        id: 1,
        categoryId: 2,
        title: 'Test Chapter',
        videos: [VideoDto1, VideoDto2],
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
      final originalChapter = ChapterDto(
        id: 1,
        categoryId: 2,
        title: 'Test Chapter',
        videos: [
          VideoDto(
            id: 10,
            chapterId: 1,
            title: 'Test Video 1',
            url: 'https://example.com/video1',
            languageCode: 'en',
          ),
        ],
      );

      // Act
      final Map<String, dynamic> map = originalChapter.toMap();
      final resultChapter = ChapterDto.fromMap(map);

      // Assert
      expect(resultChapter.id, originalChapter.id);
      expect(resultChapter.categoryId, originalChapter.categoryId);
      expect(resultChapter.title, originalChapter.title);
      expect(resultChapter.videos.length, originalChapter.videos.length);

      // Check video in roundtrip conversion
      expect(resultChapter.videos[0].id, originalChapter.videos[0].id);
      expect(resultChapter.videos[0].chapterId, originalChapter.videos[0].chapterId);
      expect(resultChapter.videos[0].title, originalChapter.videos[0].title);

      expect(
          resultChapter.videos[0].url,
          originalChapter.videos[0].url
      );

      expect(
          resultChapter.videos[0].languageCode,
          originalChapter.videos[0].languageCode
      );
    });

    group('Parsing of the duration object', () {
      test('Parsing the duration string from db to duration object', () {
        // Arrange
        final String durationString = '00:10:05.010010';

        // The fractional part .010010 represents 10,010 microseconds
        // which is 10 milliseconds + 10 microseconds
        final Duration expectedDuration = Duration(
            hours: 0,
            minutes: 10,
            seconds: 5,
            microseconds: 10010  // This is 10,010 microseconds total
        );

        // Act
        final Duration? parsedDuration = ParseDuration.parse(durationString);

        // Assert
        expect(parsedDuration, isNotNull);
        expect(parsedDuration, expectedDuration);
      });

      test('Parsing duration with different fractional formats', () {
        // Test with milliseconds precision (3 digits)
        expect(
            ParseDuration.parse('00:10:05.010'),
            Duration(hours: 0, minutes: 10, seconds: 5, microseconds: 000010)
        );

        // Test with microseconds precision (6 digits)
        expect(
            ParseDuration.parse('00:10:05.010010'),
            Duration(hours: 0, minutes: 10, seconds: 5, microseconds: 10010)
        );

        // Test without fractional part
        expect(
            ParseDuration.parse('00:10:05'),
            Duration(hours: 0, minutes: 10, seconds: 5)
        );
      });
    });
  });
}