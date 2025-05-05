
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:livsmestringapp/controllers/database-controller.dart';
import 'package:livsmestringapp/controllers/home-page-controller.dart';
import 'package:livsmestringapp/dto/category_dto.dart';
import 'package:livsmestringapp/main.dart';
import 'package:livsmestringapp/pages/chapter-page.dart';
import 'package:livsmestringapp/pages/language_page.dart';
import 'package:livsmestringapp/pages/language_page_nav.dart';
import 'package:sqflite/sqflite.dart';
import 'MockDatabase.dart';

void main() {
  group('accessibility tests', () {
    late Future<Database> testDb;
    late HomePageController mockHomePageController;

    setUpAll( () async {
      // Initialize sqflite_common_ffi for testing
      final testDbHelper = TestDatabaseHelper();
      testDb = testDbHelper.getTestDatabase();

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
      Get.put<HomePageController>(HomePageController());
      mockHomePageController = Get.find<HomePageController>();

      await mockHomePageController.loadData();

    });

    tearDownAll(() async {
      await testDb.then((db) =>  {db.close()}); // Clean up after each test
      Get.reset();
    });

    testWidgets('HomePage meets guideline', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(MaterialApp(home: HomePage(selectedLanguage: 1)));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
    testWidgets('ChapterPage meets guidelines', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      mockHomePageController.fetchAllData();

      await tester.pumpWidget(MaterialApp(home: ChapterPage(category: CategoryDTO(id: 0, name: 'carreer'), updateProgress: (bool value) {})));
      
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });

    testWidgets('LanguagePage meets guidelines', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(MaterialApp(home: LanguagePage(selectedLanguage: (int value) {})));

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
