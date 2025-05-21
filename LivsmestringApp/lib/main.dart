import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/pages/chapter-page.dart';
import 'package:livsmestringapp/pages/home_page.dart';
import 'package:livsmestringapp/pages/language_page_nav.dart';
import 'package:livsmestringapp/pages/splash_screen.dart';
import 'package:livsmestringapp/services/LocaleString.dart';
import 'package:livsmestringapp/styles/theme.dart';
import 'package:livsmestringapp/widgets/navigation_bar.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'controllers/database-controller.dart';
import 'controllers/home-page-controller.dart';
import 'databse/database-helper.dart';
import 'models/page_enum.dart';

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
  Locale? locale = getLanguage != null
      ? Locale.fromSubtags(languageCode: getLanguage)
      : null;

  // Run the app with the new navigation structure
  runApp(MyApp(
      selectedLanguage: getLanguage,
      locale: locale,
  ));
}

class MyApp extends StatefulWidget {
  final String? selectedLanguage;
  final Locale? locale;

  const MyApp({super.key, required this.selectedLanguage, required this.locale});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late String? _selectedLanguage;
  late Future<bool> _dataFuture;
  late Locale? _locale;
  final dbController = Get.find<DatabaseController>();
  final homeController = Get.find<HomePageController>();

  @override
  void initState() {
    super.initState();
    var homepageController = Get.find<HomePageController>();
    _dataFuture = homepageController.insertData();
    _selectedLanguage = widget.selectedLanguage;
    _locale = widget.locale;
    Logger.root.level = Level.ALL; // defaults to Level.INFO
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
    );
  }
}
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
    log("In init navigationstate : ${pageController.initialPage}");

    // Set up a worker to listen for index changes
    indexWorker = ever(homePageController.currentIndex, (index) {
      log("In index worker ${index}");
      log("Has clients: ${pageController.hasClients}");
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
    if (homePageController.careerCategory.value == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
          log("Navigation bar onTap called with index: $index");
          // The worker will handle the page animation, so we don't need to do anything here
          // unless you want to override the animation behavior
        },
      )),
    );
  }
}

class HomePage extends StatefulWidget {
  final String? selectedLanguage;

  const HomePage({super.key, required this.selectedLanguage});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _dialogShown = false;
  var homePageController = Get.find<HomePageController>();

  @override
  void initState() {
    super.initState();
    // Only show the language dialog if no language is selected
    if (widget.selectedLanguage == null) {
      // Delay to ensure context is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLanguageDialog();
      });
    } else {
      // Load data if language is already selected
      homePageController.fetchAllData();
    }
  }

  Future<void> _showLanguageDialog() async {
    if (_dialogShown) return; // Prevent multiple dialogs
    _dialogShown = true;

    final selectedLocale = await buildLanguageDialog(context);

    if (selectedLocale != null) {
      // Update state or navigate as needed
      await homePageController.updateLanguage(selectedLocale.languageCode);
      homePageController.currentLocale.value = selectedLocale;
      homePageController.changePage(Pages.home.index); // Only once app is ready
    }
  }

  @override
  Widget build(BuildContext context) {
    //if (widget.selectedLanguage == null && _selectedLocale == null) {
    //  return const Scaffold(
    //    body: Center(child: Text("Please select a language...")),
    //  );
    //} else {
      return MainNavigation();
    //}
  }

  Future<Locale?> buildLanguageDialog(BuildContext context) async {
    final result = await showDialog<Locale?>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          child: AlertDialog(
            title: Center(child: Text('select_language'.tr)),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: LanguagePageNav.localeSet.length,
                itemBuilder: (context, index) {
                  final locale = LanguagePageNav.localeSet[index]['locale'];
                  final name = LanguagePageNav.localeSet[index]['name'];
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        child: Text(name),
                        onTap: () {
                          Navigator.pop(context, locale);
                        },
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => Divider(color: Colors.grey[800]),
              ),
            ),
          ),
        );
      },
    );
    return result;
  }
}

