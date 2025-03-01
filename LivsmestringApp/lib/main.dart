import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/pages/chapter-page.dart';
import 'package:livsmestringapp/pages/home_page.dart';
import 'package:livsmestringapp/pages/language_page.dart';
import 'package:livsmestringapp/pages/language_page_nav.dart';
import 'package:livsmestringapp/pages/splash_screen.dart';
import 'package:livsmestringapp/services/LocaleString.dart';
import 'package:livsmestringapp/styles/theme.dart';
import 'package:livsmestringapp/widgets/buttom_navigation.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'controllers/database-controller.dart';
import 'controllers/home-page-controller.dart';
import 'databse/database-helper.dart';
import 'dto/category_dto.dart';
import 'models/DataModel.dart';

// Entry point of the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  final databaseHelper = DatabaseHelper();
  final database = databaseHelper.db;

  // Put the DatabaseController into the GetX dependency injection system
  Get.put(DatabaseController(database));
  Get.put(HomePageController());

  // Prevents the application from changing orientation to horizontal at any point
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Get language preferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? getLanguage = prefs.getInt('selectedLanguage');
  Locale locale = getLanguage != null
      ? LanguagePageNav.localeSet[getLanguage]['locale']
      : Locale('nb', 'NO');

  // Run the app with the new navigation structure
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
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late int? _selectedLanguage;
  late Future<Map<String, Datamodel>> _dataFuture;
  late Locale _locale;
  final dbController = Get.find<DatabaseController>();
  final homeController = Get.find<HomePageController>();
  late Future<List<CategoryDTO>> categories;

  @override
  void initState() {
    super.initState();
    var homepageController = Get.find<HomePageController>();
    categories = _getCategories();
    _dataFuture = homepageController.fetchAllData();
    _selectedLanguage = widget.selectedLanguage;
    _locale = widget.locale;
    Logger.root.level = Level.ALL; // defaults to Level.INFO
  }

  Future<List<CategoryDTO>> _getCategories() {
    return dbController.getCategories();
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
            // This is where we'll implement the navigation logic from HomePage
            if ( homeController.currentLocale.value == null) {
              return LanguagePage(
                selectedLanguage: (value) {
                  setState(() {
                    _selectedLanguage = value;
                  });
                },
              );
            } else {
              return MainNavigation(selectedLanguage: _selectedLanguage);
            }
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            return Center(child: Text("No data available"));
          }
        },
      ),
      // Routes in the app
      getPages: [
        GetPage(
          name: '/home',
          page: () => MainNavigation(selectedLanguage: _selectedLanguage),
          binding: BindingsBuilder(() {
            // Make sure controller is available and initialized
            if (!Get.isRegistered<HomePageController>()) {
              Get.put(HomePageController(), permanent: true);
            }
          }),
        ),
        GetPage(
          name: '/chapter',
          page: () => ChapterPage(category: Get.find<HomePageController>().careerCategory.value!, updateProgress: (bool value) {}),
        ),
        GetPage(
          name: '/language',
          page: () => LanguagePageNav(),
        ),
      ],
    );
  }
}
// Fixed MainNavigation class with null safety handling
class MainNavigation extends StatelessWidget {
  final int? selectedLanguage;

  const MainNavigation({super.key, required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    final homePageController = Get.find<HomePageController>();

    if (homePageController.careerCategory.value == null) {
      // show cirluar progression if category is not defined
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Obx(() => IndexedStack(
        index: homePageController.currentIndex.value,
        children: [
          // Home tab
          HomePageContent(
            categories: homePageController.categories,
            progress: homePageController.progress,
            updateProgress: homePageController.updateProgress,
          ),
          // Career tab
          ChapterPage(
            category: homePageController.careerCategory.value!,
            updateProgress: homePageController.updateProgress,
          ),
          // Health tab
          /*
          ChapterPage(
            category: homePageController.healthCategory.value!,
            updateProgress: homePageController.updateProgress,
          ),
           */
          // Language tab
          LanguagePageNav(),
        ],
      )),
      bottomNavigationBar: Obx(() => ButtomNavigationBar(
        selectedTab: homePageController.currentIndex.value,
        onTap: homePageController.changePage,
      )),
    );
  }
}
