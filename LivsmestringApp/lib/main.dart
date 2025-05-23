import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/services/LocaleString.dart';
import 'package:livsmestringapp/styles/theme.dart';
import 'package:livsmestringapp/widgets/chapter/chapter-page.dart';
import 'package:livsmestringapp/widgets/home/home_page_content.dart';
import 'package:livsmestringapp/widgets/home/language_selection_start.dart';
import 'package:livsmestringapp/widgets/language/language_page_nav.dart';
import 'package:livsmestringapp/widgets/navigation/navigation_bar.dart';
import 'package:livsmestringapp/widgets/splash_screen.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/database-controller.dart';
import 'controllers/home-page-controller.dart';
import 'databse/database-helper.dart';

/**
 * * * This is the main entry point of the application.
 */
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
  String? getLanguage = prefs.getString('selectedLanguage');

  // Run the app with the new navigation structure
  runApp(MyApp(
      selectedLanguage: getLanguage,
  ));
}

class MyApp extends StatefulWidget {
  final String? selectedLanguage;

  const MyApp({super.key, required this.selectedLanguage});

  @override
  MyAppState createState() => MyAppState();
}

/**
 * * This widget is responsible for displaying the main app.
 */
class MyAppState extends State<MyApp> {
  late String? _selectedLanguage;
  late Future<bool> _dataFuture;
  final dbController = Get.find<DatabaseController>();
  final homeController = Get.find<HomePageController>();


  @override
  void initState() {
    super.initState();
    var homepageController = Get.find<HomePageController>();
    homeController.loadData();
    _dataFuture = homepageController.insertData();
    _selectedLanguage = widget.selectedLanguage;
    Logger.root.level = Level.INFO; // defaults to Level.INFO
  }


  @override
  Widget build(BuildContext context) {
    return Obx(() => GetMaterialApp(
      locale: Locale(homeController.currentLocale.value?.languageCode ?? 'en'),
      fallbackLocale: Locale('en', 'UK'),
      debugShowCheckedModeBanner: false,
      translations: LocaleString(),
      title: 'life_mastery_app'.tr,
      theme: lightMode,
      darkTheme: darkMode,
      home: FutureBuilder(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          } else if (snapshot.hasData) {
            log("In MyAppState selected language: ${_selectedLanguage}");
            return HomePage(selectedLanguage: _selectedLanguage);


          } else if (snapshot.hasError) {
            return Center(child: Text("Error with snapshot: ${snapshot.error}"));
          } else {
            return Center(child: Text("No data available"));
          }
        },
      ),
      // Routes in the app
      getPages: [
        GetPage(
          name: '/home',
          page: () => MainNavigation(),
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
    ));
  }
}

/**
 * * This widget is responsible for displaying the main navigation of the app.
 */
class MainNavigation extends StatefulWidget {

  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late PageController pageController;
  late final HomePageController homePageController;
  late Worker indexWorker;

  @override
  void initState() {
    super.initState();
    homePageController = Get.find<HomePageController>();
    pageController = PageController(
      initialPage: homePageController.currentIndex.value,
    );

    // Set up a worker to listen for index changes
    indexWorker = ever(homePageController.currentIndex, (index) {
      // Only animate if the pageController has clients and the page is different
      if (pageController.hasClients && pageController.page?.round() != index) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    indexWorker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: PageView(
        controller: pageController,
        physics: const PageScrollPhysics(),
        onPageChanged: (index) {
          log("Page changed to index: $index");
          if (homePageController.currentIndex.value != index) {
            homePageController.currentIndex.value = index;
          }
        },
        children: [
          // Home tab
          HomePageContent(
            categories: homePageController.categories,
            updateProgress: homePageController.updateProgress,
          ),
          // Career tab
          ChapterPage(
            category: homePageController.careerCategory.value!,
            updateProgress: homePageController.updateProgress,
          ),
          ChapterPage(
              category: homePageController.healthCategory.value!,
              updateProgress: homePageController.updateProgress
          ),
          // Language tab
          LanguagePageNav(),
        ],
      ),
      bottomNavigationBar: Obx(() => NavigationBarWrapper(
        selectedTab: homePageController.currentIndex.value,
        onTap: (index) {
        },
      )),
    );
  }
}

