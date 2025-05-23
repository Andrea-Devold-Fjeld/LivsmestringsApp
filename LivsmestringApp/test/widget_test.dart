// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/controllers/database-controller.dart';
import 'package:livsmestringapp/controllers/home-page-controller.dart';
import 'package:livsmestringapp/databse/database_operation.dart';
import 'package:livsmestringapp/dto/category_dto.dart';
import 'package:livsmestringapp/dto/chapter_dto.dart';
import 'package:livsmestringapp/dto/task_dto.dart';
import 'package:livsmestringapp/dto/video_dto.dart';
import 'package:livsmestringapp/models/cateregory.dart';
import 'package:livsmestringapp/widgets/chapter/chapter-page.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

import 'MockDatabase.dart';

final CategoryDto mockCategory = CategoryDto(
  name: 'career',
  id: 1,
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
              watched: false,
              videoId: 1,
            ),
          ],
          chapterId: 1,
        ),
        VideoDto(
          id: 2,
          title: 'Video 2',
          url: 'https://youtube.com/video2',
          totalLength: Duration(minutes: 10),
          watchedLength: Duration(minutes: 10),
          watched:true,
          tasks: [
            TaskDto(
              id: 2,
              title: 'Task 2',
              url: 'https://youtube.com/task2',
              watched: false,
              videoId: 2,
            ),
          ],
          chapterId: 10,
        ),
      ],
    ),
    ChapterDto(
        categoryId: 1,
        title: 'Chapter 2',
        videos: [
          VideoDto(
            id: 3,
            title: 'Video 3',
            url: 'https://youtube.com/video3',
            watched: false,
            totalLength: Duration(minutes: 10),
            watchedLength: Duration(minutes: 5),
            tasks: [
              TaskDto(
                id: 3,
                title: 'Task 3',
                url: 'https://youtube.com/task3',
                watched: false,
                videoId: 3,
              ),
            ],
            chapterId: 2,
          ),
        ]
    )
  ],
);
class MockDatabaseController extends Mock implements DatabaseController {
  @override
  Future<Database> get db async {
    return await TestDatabaseHelper().getTestDatabase();
  }
  @override
  Future<List<CategoryClass>> getCategories() {
    // TODO: implement getCategories
    return Future.value( [
      CategoryClass(name: 'career', id: 1),
      CategoryClass(name: 'health', id: 2),
    ]);
  }
  @override
  Future<CategoryDto> getDatamodelWithLAnguage(String category, String language) async {
    return mockCategory;
  }
}

class MockHomePageController extends GetxService with Mock implements HomePageController {
  @override
  final Rx<Locale?> currentLocale = Rx<Locale?>(const Locale('en'));
  @override
  final currentIndex = 0.obs;
  @override
  late CategoryDto? careerData;
  @override
  late CategoryDto? healthData;
  @override
  var categories = <CategoryClass>[].obs;
  @override
  final progress = RxMap<int, ProgressModel>({
    1: ProgressModel(totalVideos: 0, watchedVideos: 0, categoryId: 1, progress: 0),
  });  @override
  late final DatabaseController databaseController = Get.find<DatabaseController>();
  @override
  var careerCategory = Rx<CategoryClass?>(CategoryClass(name: 'career', id: 1));
  @override
  var healthCategory = Rx<CategoryClass?>(CategoryClass(name: 'health', id: 2));
  @override
  Future<void> onInit() async {
    super.onInit();
    categories = [
      CategoryClass(name: 'career', id: 1),
    ].obs;
  }
  @override
  Future<CategoryDto> fetchDataFromCategory(String category) async {
    var data = careerData;
    if(data != null) return data;
    return mockCategory;
  }
  @override
  Future<bool> fetchAllData() async {
    return true;
  }
}

void main() {
  late DatabaseController mockDatabaseController;
  late MockHomePageController mockHomePageController;
  late CategoryDto testCategory;

  setUp(() {

    // Create mock instances instead of real implementations
    mockDatabaseController = DatabaseController(TestDatabaseHelper().getTestDatabase());
    mockHomePageController = MockHomePageController();

    // Register mocks with GetX
    Get.put<DatabaseController>(mockDatabaseController);
    Get.put<HomePageController>(mockHomePageController);
    // Set up the mock database controller
    mockHomePageController.careerData =  mockCategory;
  });

  var category = CategoryClass(name: 'career', id: 1);

  testWidgets('ChapterPage should display correct title and chapter list', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      GetMaterialApp(
        home: ChapterPage(
          category: category,
          updateProgress: (_) {},
        ),
      ),
    );

    // Assert
    await tester.pumpAndSettle();

    // Verify the title is displayed correctly
    expect(find.text('Career'), findsOneWidget);

    // Verify both chapters are displayed
    expect(find.text('Chapter 1'), findsOneWidget);
    expect(find.text('Chapter 2'), findsOneWidget);
  });

  testWidgets('Chapter should expand to show videos when tapped', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      GetMaterialApp(
        home: ChapterPage(
          category: category,
          updateProgress: (_) {},
        ),
      ),
    );

    // Assert
    await tester.pumpAndSettle();

    // Initially, videos should not be visible
    expect(find.text('Video 1'), findsNothing);
    expect(find.text('Video 2'), findsNothing);

    // Tap on the first chapter
    await tester.tap(find.text('Chapter 1'));
    await tester.pumpAndSettle();

    // Find video title
    expect(find.text('Video 1'), findsOneWidget);
    expect(find.text('Video 2'), findsOneWidget);
  });

  testWidgets('Tasks should be displayed for videos with tasks', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      GetMaterialApp(
        home: ChapterPage(
          category: category,
          updateProgress: (_) {},
        ),
      ),
    );

    // Assert
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chapter 1'));
    await tester.pumpAndSettle();

    // Verify tasks expansion tile is present

    // Tap on tasks to expand
    await tester.tap(find.byIcon(Icons.chevron_right).first);
    await tester.pumpAndSettle();

    // Verify task is displayed
    expect(find.text('Task 1'), findsOneWidget);
  });

  testWidgets('Video progress indicators should display correctly', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      GetMaterialApp(
        home: ChapterPage(
          category: category,
          updateProgress: (_) {},
        ),
      ),
    );

    await tester.pumpAndSettle();
    // Assert
    // Expand first chapter
    await tester.tap(find.text('Chapter 1'));
    await tester.pumpAndSettle();

    final progressIndicatorFinders = find.byType(CircularProgressIndicator);

    final progressIndicators = tester.widgetList<CircularProgressIndicator>(progressIndicatorFinders);


    // Video 2 should have a checkmark (completed)
    expect(progressIndicators.elementAt(0).value, equals(0.0));

    // Collapse first chapter and expand second chapter
    await tester.tap(find.text('Chapter 1'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chapter 2'));

  });


  testWidgets('Tapping on a video should navigate to the YouTube page', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      GetMaterialApp(
        home: ChapterPage(
          category: category,
          updateProgress: (_) {},
        ),
      ),
    );

    // Assert
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chapter 1'));
    await tester.pumpAndSettle();

    bool navigated = false;
    Get.testMode = true;
    await tester.tap(find.text('Video 1'));
    expect(find.byType(ChapterPage), findsOneWidget);
  });

  tearDown(() {
    Get.reset();
  });
}