// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:livsmestringapp/controllers/database-controller.dart';
import 'package:livsmestringapp/controllers/home-page-controller.dart';
import 'package:livsmestringapp/dto/category_dto.dart';
import 'package:livsmestringapp/dto/chapter_dto.dart';
import 'package:livsmestringapp/dto/task_dto.dart';
import 'package:livsmestringapp/dto/video_dto.dart';
import 'package:livsmestringapp/models/cateregory.dart';
import 'package:livsmestringapp/widgets/chapter/chapter-page.dart';
import 'package:livsmestringapp/widgets/home/home_page_content.dart';
import 'package:livsmestringapp/widgets/home/language_selection_start.dart';
import 'package:livsmestringapp/widgets/language/language_page_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'MockDatabase.dart';
import 'widget_test.dart';

void main() {
  group('accessibility tests', () {
    late Future<Database> testDb;
    late HomePageController mockHomePageController;

    setUpAll( () async {
      // Initialize sqflite_common_ffi for testing
      final testDbHelper = TestDatabaseHelper();
      testDb = testDbHelper.getTestDatabase();
      SharedPreferences.setMockInitialValues({'selectedLanguage': 'en'});

      //final resolvedTestDb = await testDbHelper.getTestDatabase(); // Resolve the database
      // Basic setup
      final dio = Dio(BaseOptions());
      final dioAdapter = DioAdapter(dio: dio);

      const path = 'https://example.com';

      dioAdapter.onGet(
        path,
            (server) => server.reply(
          200,
          {
            "Category": "career",
            "Chapters": [
            {
            "Title": "1_me_in_context",
            "Videos": [
            {
              "Title": "1.1_introduction",
              "LanguageUrls": {
                "en": "https://youtu.be/LEvsQV9x3Oo",
                "nb": "https://youtu.be/KOwLhVRP7UY",
                "ps": "https://youtu.be/I9zQ3BCxEEw"
              },
            "Tasks": null
            }
            ]
            }
          ]
          },
          // Reply would wait for one-sec before returning data.
          delay: const Duration(seconds: 1),
        ),
      );



      // Mock database controller
      //final mockDatabaseController = DatabaseController(Future.value(mockDatabase));

      // Inject mocks into GetX
      Get.put<DatabaseController>(DatabaseController(testDb));
      mockHomePageController = MockHomePageController();
      Get.put<HomePageController>(mockHomePageController);

      Get.put<HomePageController>(HomePageController());
      //mockHomePageController = Get.find<HomePageController>();
      mockHomePageController.currentIndex.value = 0;
      mockHomePageController.careerData = mockHomePageController.careerData = CategoryDto(
        id: 1,
        name: 'career',
        chapters: [
          ChapterDto(
            categoryId: 1,
            title: "Chapter 1",
            videos: [
              VideoDto(
                id: 1,
                title: 'Video 1',
                url: 'https://youtube.com/video1',
                watched: false,
                tasks: [
                  TaskDto(
                    id: 1,
                    title: 'Task 1',
                    url: 'https://youtube.com/task1',
                    watched: false, videoId: 1,
                  ),
                ], chapterId: 0,
              ),
            ],
          ),
        ],
      );

      //when(() => mockHomePageController.fetchAllData()).thenAnswer((_) async =>  true);

      //await mockHomePageController.loadData();

    });

    tearDownAll(() async {
      await testDb.then((db) =>  {db.close()}); // Clean up after each test
      Get.reset();
    });

    testWidgets('HomePage meets guideline', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(MaterialApp(home: HomePageContent(categories: [CategoryClass(id: 1, name: 'career')], updateProgress: (bool value) {  },)));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
    testWidgets('ChapterPage meets guidelines', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await mockHomePageController.fetchAllData();

      await tester.pumpWidget(MaterialApp(home: ChapterPage(category: CategoryClass(id: 1, name: 'career'), updateProgress: (bool value) {})));
      
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });

    testWidgets('LanguagePage meets guidelines', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(MaterialApp(home: HomePage(selectedLanguage:  null)));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });

    testWidgets('LanguagePageNav meets guidelines', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(MaterialApp(home: LanguagePageNav()));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
  });
});
}
