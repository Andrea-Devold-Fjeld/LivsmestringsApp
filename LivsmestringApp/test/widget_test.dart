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
import 'package:get/get_core/src/get_main.dart';
import 'package:livsmestringapp/controllers/database-controller.dart';
import 'package:livsmestringapp/controllers/home-page-controller.dart';
import 'package:livsmestringapp/main.dart';
import 'package:livsmestringapp/models/DataModel.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'MockDatabase.dart';
import 'MockHttpClient.dart'; // Import the MockDio class from this file

void main() {
  group('HomePage accessibility tests', () {
    late Future<Database> mockDatabase;
    late MockDio mockDio;
    late Future<Database> testDb;


    setUpAll( () async {
      // Initialize sqflite_common_ffi for testing
      final testDbHelper = TestDatabaseHelper();
      testDb = testDbHelper.getTestDatabase();
      //final resolvedTestDb = await testDbHelper.getTestDatabase(); // Resolve the database

      // Initialize the database
      // Initialize mock database and Dio
      //mockDatabase = MockDatabaseHelper().db;
      mockDio = MockDio();

      // Mock database controller
      //final mockDatabaseController = DatabaseController(Future.value(mockDatabase));

      // Inject mocks into GetX
      Get.put<DatabaseController>(DatabaseController(testDb));
      final mockHomePageController = HomePageController();

      Get.put<HomePageController>(mockHomePageController);

      // Mock Dio behavior
      Datamodel mockData = await mockFetchData(mockDio, 'career');
    });

    tearDownAll(() async {
      await testDb.then((db) =>  {db.close()}); // Clean up after each test
      Get.reset();
    });

    testWidgets('HomePage meets androidTapTargetGuideline', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(MaterialApp(home: HomePage(selectedLanguage: 1)));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

      handle.dispose();
    });

    testWidgets('HomePage meets text contrast guidelines', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(MaterialApp(home: HomePage(selectedLanguage: 1)));

      await expectLater(tester, meetsGuideline(textContrastGuideline));

      handle.dispose();
    });
  });
}
/*
class MockDatabaseController extends GetxController with Mock implements DatabaseController {
  // Override methods that HomePage or HomePageController calls
  @override
  Future<void> initDatabase() async {
    // No-op implementation for testing
  }

  @override
  // TODO: implement db
  Future<Database> get db => throw UnimplementedError();

  @override
  Future<List<CategoryDTO>> getCategories() {
    // TODO: implement getCategories
    throw UnimplementedError();
  }

  @override
  Future<DatamodelDto> getDatamodelWithLAnguage(String category, String language) {
    // TODO: implement getDatamodelWithLAnguage
    throw UnimplementedError();
  }

  @override
  Future<ProgressModel> getVideoProgress(int categoryId) {
    // TODO: implement getVideoProgress
    throw UnimplementedError();
  }

  @override
  Future<void> insertDatamodel(Datamodel data, VideoUrls urls) {
    // TODO: implement insertDatamodel
    throw UnimplementedError();
  }

  @override
  Future<void> markTaskWatched(String taskUrl) {
    // TODO: implement markTaskWatched
    throw UnimplementedError();
  }

  @override
  Future<void> markVideoWatched(String videoTitle) {
    // TODO: implement markVideoWatched
    throw UnimplementedError();
  }

  @override
  Future<void> updateTotalLength(Duration duration, String url) {
    // TODO: implement updateTotalLength
    throw UnimplementedError();
  }

  @override
  Future<void> updateUrl(Video video, String url) {
    // TODO: implement updateUrl
    throw UnimplementedError();
  }

  @override
  Future<void> updateWatchTime(Duration duration, String url) {
    // TODO: implement updateWatchTime
    throw UnimplementedError();
  }

// Add other methods that your real DatabaseController implements
// and that are called by the code under test
}

 */
