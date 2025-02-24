// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/databse/database_operation.dart';
import 'package:livsmestringapp/dto/category_dto.dart';
import 'package:livsmestringapp/pages/chapter-page.dart';
import 'package:livsmestringapp/pages/home_page.dart';
import 'package:livsmestringapp/pages/language_page.dart';
import 'package:livsmestringapp/services/data.dart';
import 'package:livsmestringapp/widgets/Layout.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'controllers/database-controller.dart';
import 'controllers/home-page-controller.dart';
import 'databse/database-helper.dart';
import 'unused/firebase_options.dart';
import '../pages/language_page_nav.dart';
import '../pages/splash_screen.dart';
import 'services/LocaleString.dart';
import '../styles/theme.dart';
import 'consumer/FetchData.dart';
import 'models/DataModel.dart';

final String createCategoriesTable = '''
  CREATE TABLE categories(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
  );
''';

final String createChaptersTable = '''
  CREATE TABLE chapters(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories (id)
      ON DELETE CASCADE
  );
''';

final String createVideosTable = '''
  CREATE TABLE videos(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    chapter_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    url TEXT NOT NULL,
    watched INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (chapter_id) REFERENCES chapters (id)
      ON DELETE CASCADE
  );
''';

final String createTasksTable = '''
  CREATE TABLE tasks(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    video_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    url TEXT NOT NULL,
    watched INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (video_id) REFERENCES videos (id)
      ON DELETE CASCADE
  );
''';

// Implementation for onCreate
Future<void> onCreate(Database db, int version) async {
  // Create tables
  await db.execute(createCategoriesTable);
  await db.execute(createChaptersTable);
  await db.execute(createVideosTable);
  await db.execute(createTasksTable);

  // Create indices for better query performance
  await db.execute('''
    CREATE INDEX idx_chapters_category
    ON chapters(category_id);
  ''');

  await db.execute('''
    CREATE INDEX idx_videos_chapter
    ON videos(chapter_id);
  ''');

  await db.execute('''
    CREATE INDEX idx_tasks_video
    ON tasks(video_id);
  ''');
}



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database
  final databaseHelper = DatabaseHelper();
  final database = databaseHelper.db;

  // Put the DatabaseController into the GetX dependency injection system
  Get.put(DatabaseController(database));
  Get.put(HomePageController());
   //Prevents the application from changing orientation to horizontal at any point:
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? getLanguage = prefs.getInt('selectedLanguage');
  Locale locale = getLanguage != null
      ? LanguagePageNav.localeSet[getLanguage]['locale']
      : Locale('nb', 'NO');

  runApp(MyApp(
    selectedLanguage: getLanguage,
    locale: locale,
    db: database
  ));
}

class MyApp extends StatefulWidget {
  final int? selectedLanguage;
  final Locale locale;
  final Future<Database> db;

  const MyApp({super.key, required this.selectedLanguage, required this.locale, required this.db});

  @override
  _MyAppState createState() => _MyAppState();
}



class _MyAppState extends State<MyApp> {
  late int? _selectedLanguage;
  late Future<Map<String, Datamodel>> _dataFuture;
  late Locale _locale;
  final dbController = Get.find<DatabaseController>();
  late Future<List<CategoryDTO>> categories;


  @override
  void initState() {
    super.initState();
    categories = _getCategories();
    _dataFuture = _fetchAllData();
    _selectedLanguage = widget.selectedLanguage;
    _locale = widget.locale;
    Logger.root.level = Level.ALL; // defaults to Level.INFO

  }
  Future<List<CategoryDTO>> _getCategories() {
    return dbController.getCategories();
  }
  Future<Map<String, Datamodel>> _fetchAllData() async {
    final results = await Future.wait([
      fetchData('career'),
      fetchData('health')
    ]);
    var career = findAndReplaceAndTranslate(results[0]);
    var health = findAndReplaceAndTranslate(results[1]);
    dbController.insertDatamodel(career);
    dbController.insertDatamodel(health);
    return {
      'career': results[0],
      'health': results[1],
    };
  }
  void updateLocale(Locale newLocale, int? newIndex) {
    setState(() {
      _locale = newLocale;
      _selectedLanguage = newIndex;
    });
    // Re-run the app with the updated locale
    runApp(MyApp(selectedLanguage: newIndex, locale: newLocale, db: widget.db,));
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: LocaleString(),
      locale: _locale,
      title: 'life_mastery_app'.tr,
      theme: lightMode,
      darkTheme: darkMode,
      home: FutureBuilder(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen(selectedLanguage: _selectedLanguage);
          } else if (snapshot.hasData) {
            if (_selectedLanguage == null) {
              return LanguagePage(
                selectedLanguage: (v) => setState(() {
                  _selectedLanguage = v;
                }),
              );
            } else {
              return HomePage(); // Default route for home screen
            }
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            return Center(child: Text("No data available"));
          }
        },
      ),
      // Define your pages (routes) here
      getPages: [
        GetPage(
          name: '/home',
          page: () => HomePage(),
          binding: BindingsBuilder(() {
            Get.lazyPut<HomePageController>(() => HomePageController());
          }),
        ),
        GetPage(
          name: '/chapter',
          page: () => ChapterPage(category: Get.find<HomePageController>().careerCategory.value!, updateProgress: (bool value) {  }),
        ),
        GetPage(
          name: '/language',
          page: () => LanguagePageNav(),
        ),
      ],
    );
  }
}

