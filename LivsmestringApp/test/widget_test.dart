// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:livsmestringapp/controllers/database-controller.dart';
import 'package:livsmestringapp/controllers/home-page-controller.dart';
import 'package:livsmestringapp/databse/database-helper.dart';
import 'package:livsmestringapp/databse/database_operation.dart';
import 'package:livsmestringapp/dto/category_dto.dart';

import 'package:livsmestringapp/main.dart';
import 'package:livsmestringapp/models/DataModel.dart';
import 'package:livsmestringapp/models/DataModelDTO.dart';
import 'package:livsmestringapp/models/VideoUrl.dart';
import 'package:sqflite_common/sqlite_api.dart';

void main() {
  // Setup group for all widget tests
  group('HomePage accessibility tests', () {
    // Setup runs once before all tests
    setUpAll(() {
      final databaseHelper = DatabaseHelper();
      final database = databaseHelper.db;
      // Initialize GetX controllers here
      final mockDatabaseController = DatabaseController(database);
      final mockHomePageController = HomePageController();

      Get.put<DatabaseController>(mockDatabaseController);
      Get.put<HomePageController>(mockHomePageController);
    });

    // Teardown runs after all tests
    tearDownAll(() {
      Get.reset();
    });

    testWidgets('HomePage meets androidTapTargetGuideline', (
        WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
          MaterialApp(
              home: HomePage(selectedLanguage: 1)));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

      handle.dispose();
    });

    testWidgets(
        'HomePage meets text contrast guidelines', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
          MaterialApp(
              home: HomePage(selectedLanguage: 1)));

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
