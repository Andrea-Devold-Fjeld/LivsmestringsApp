import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/consumer/FetchData.dart';
import 'package:livsmestringapp/pages/home_page.dart';
import 'package:livsmestringapp/pages/language_page_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../databse/database_operation.dart';
import '../dto/category_dto.dart';
import '../models/DataModel.dart';
import '../pages/chapter-page.dart';
import '../services/data.dart';
import 'database-controller.dart';


class HomeBinding extends Bindings {
  final int? selectedLanguage;

  HomeBinding({this.selectedLanguage});

  @override
  void dependencies() {
    Get.lazyPut(() => HomePageController());
  }
}


class HomePageController extends GetxController {
  // Variables for navigation and categories
  var currentIndex = 0.obs;
  var categories = <CategoryDTO>[].obs;
  var progress = <int, ProgressModel>{}.obs;
  var careerCategory = Rx<CategoryDTO?>(null);
  var healthCategory = Rx<CategoryDTO?>(null);
  final DatabaseController databaseController = Get.find<DatabaseController>();

  // Variables for language
  var selectedLanguage = Rx<int?>(null);
  var currentLocale = Rx<Locale?>(null); // Default locale

  @override
  void onInit() {
    super.onInit();
    // Load initial data when controller initializes
    loadData();
    ever(currentLocale, (_) {
      // If currentLocale is set (not null), call loadData
      if (currentLocale.value != null) {
        Get.updateLocale(currentLocale.value!);
        updateUrls();
        loadData();
      }
    });
  }

  void setLocale(Locale locale){
    currentLocale.value = locale;
  }
  Future<List<CategoryDTO>> getCategories() {
    return databaseController.getCategories();
  }

  void updateUrls() async {
    final results = await Future.wait([
      fetchData('career'),
      //fetchData('health'),
    ]);
    final resultVideoUrls = await Future.wait([
      fetchVideoUrls()
    ]);

    //replaceUrls(results[0], resultVideoUrls.first);
    //replaceUrls(results[1], resultVideoUrls.first);
  }

  Future<Map<String, Datamodel>> fetchAllData() async {
    final results = await Future.wait([
      fetchData('career'),
      //fetchData('health'),
    ]);
    final resultVideoUrls = await Future.wait([
      fetchVideoUrls()
    ]);

    databaseController.insertDatamodel(results[0], resultVideoUrls.first);



    return {
      'career': results[0],
      //'health': results[1],
    };
  }
  // Navigation method
  void changePage(int index) {
    currentIndex.value = index;
  }


  // Main data loading method
  Future<void> loadData() async {
    try {
      var categoriesList = await databaseController.getCategories();
      categories.value = categoriesList;

      // Find and assign specific categories for the tabs
      if (categoriesList.isNotEmpty) {
        // Find career category
        try {
          careerCategory.value = categoriesList.firstWhere(
                  (cat) => cat.name.toLowerCase().contains('career') || cat.id == 2,
              orElse: () => categoriesList.first // Fallback to first category if not found
          );
        } catch (e) {
          print('Error finding career category: $e');
        }

        // Find health category
        try {
          healthCategory.value = categoriesList.firstWhere(
                  (cat) => cat.name.toLowerCase().contains('health') || cat.id == 3,
              orElse: () => categoriesList.length > 1 ? categoriesList[1] : categoriesList.first
          );
        } catch (e) {
          print('Error finding health category: $e');
        }
      }

      // Load progress for each category
      await _loadProgress();
    } catch (e) {
      print('Error in loadData: $e');
    }
  }

  // Load progress for all categories
  Future<void> _loadProgress() async {
    try {
      // Create a temporary map to store progress
      Map<int, ProgressModel> tempProgress = {};
      for (var c in categories) {
        tempProgress[c.id] = await databaseController.getVideoProgress(c.id);
      }

      // Update the observable map
      progress.value = tempProgress;
    } catch (e) {
      print('Error loading progress: $e');
    }
  }

  // Update language and locale
  Future<void> updateLanguage(int index) async {
    selectedLanguage.value = index;
    _updateLocaleFromLanguageIndex(index);

    // Save to shared preferences
    await _saveLanguagePreference(index);

    // Refresh data that depends on language
    await refreshLanguageDependentData();

    update(); // Notify all listeners that the controller has been updated
  }

  // Helper method to update locale from language index
  void _updateLocaleFromLanguageIndex(int index) {
    try {
      currentLocale.value = LanguagePageNav.localeSet[index]['locale'];
    } catch (e) {
      print("Error setting locale: $e");
      // Fallback to default locale
      currentLocale.value = Locale('nb', 'NO');
    }
  }

  // Save language preference to SharedPreferences
  Future<void> _saveLanguagePreference(int index) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selectedLanguage', index);
    } catch (e) {
      print("Error saving language preference: $e");
    }
  }

  // Refresh data that depends on language
  Future<void> refreshLanguageDependentData() async {
    try {
      // Reload all data when language changes
      await loadData();
    } catch (e) {
      print("Error refreshing language-dependent data: $e");
    }
  }

  // Method to update progress
  void updateProgress(bool value) {
    if (value) {
      loadData(); // Reload data when progress is updated
    }
  }

  // Helper method to check for a specific category
  CategoryDTO? checkCategory(String name) {
    try {
      return categories.firstWhere(
            (element) => element.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      print('Error in checkCategory: $e');
      return null;
    }
  }
}
/*

// 2. Update the language selection page to pass data to the controller
// In your LanguagePage or LanguagePageNav
class LanguagePageNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomePageController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('select_language'.tr),
      ),
      body: ListView.builder(
        itemCount: LanguagePageNav.localeSet.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(LanguagePageNav.localeSet[index]['name']),
            onTap: () async {
              // Save to shared preferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setInt('selectedLanguage', index);

              // Get the locale from your locale set
              Locale locale = LanguagePageNav.localeSet[index]['locale'];

              // Update the language in Get.updateLocale
              Get.updateLocale(locale);

              // Update the HomePageController with the new language
              homeController.updateLanguage(index, locale);

              // Navigate back or to home
              Get.back();
              // Or navigate to home if needed
              // Get.offNamed('/home');
            },
            // You can add trailing to show selected language
            trailing: homeController.selectedLanguage.value == index
                ? Icon(Icons.check, color: Colors.green)
                : null,
          );
        },
      ),
    );
  }
}

// 3. Ensure the HomePageController is initialized with the saved language when the app starts
// In your main.dart, when initializing the HomePageController:

void main() async {
  // Your existing initialization code

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? getLanguage = prefs.getInt('selectedLanguage');
  Locale locale = getLanguage != null
      ? LanguagePageNav.localeSet[getLanguage]['locale']
      : Locale('nb', 'NO');

  // Initialize HomePageController with language information
  final homeController = HomePageController();
  homeController.selectedLanguage.value = getLanguage;
  homeController.currentLocale.value = locale;

  Get.put(homeController, permanent: true);

  // Rest of your initialization code
}

// 4. Update your MyApp class to use the language from HomePageController
class _MyAppState extends State<MyApp> {
  final homeController = Get.find<HomePageController>();

  // Other variables and methods

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: LocaleString(),
      locale: homeController.currentLocale.value, // Use the locale from controller
      // Rest of your GetMaterialApp configuration
    );
  }
}
 */


/*

class HomePageController extends GetxController {
  final int? selectedLanguage;
  final RxInt currentLanguage = RxInt(0); // Default language index
  final Rx<Locale> currentLocale = Rx<Locale>(Locale('nb', 'NO')); // Default locale


  HomePageController({this.selectedLanguage}) {
    // Initialize current language from parameter if provided
    if (selectedLanguage != null) {
      currentLanguage.value = selectedLanguage!;
      // Set locale based on selected language
      updateLocaleFromLanguageIndex(selectedLanguage!);
    }
  }

  // Observable variables
  final RxList<CategoryDTO> categories = <CategoryDTO>[].obs;
  final Rx<Map<int, ProgressModel>> progress = Rx<Map<int, ProgressModel>>({});

  // Add these two new properties for the navigation tabs
  final Rx<CategoryDTO?> careerCategory = Rx<CategoryDTO?>(null);
  final Rx<CategoryDTO?> healthCategory = Rx<CategoryDTO?>(null);

  final DatabaseController databaseController = Get.find<DatabaseController>();
  var currentIndex = 0.obs;

  final pages = <String>["/home", "/career", "/health","/language"];

  void updateLocaleFromLanguageIndex(int index) {
    // Assuming LanguagePageNav.localeSet is accessible here
    // If not, you may need to recreate the mapping here
    try {
      currentLocale.value = LanguagePageNav.localeSet[index]['locale'];
    } catch (e) {
      print("Error setting locale: $e");
      // Fallback to default locale
      currentLocale.value = Locale('nb', 'NO');
    }
  }
  Future<void> _loadCategories() async {
    try {
      // Get database controller
      final dbController = Get.find<DatabaseController>();

      // Load categories from database
      final allCategories = await dbController.getCategories();

      // Find career and health categories
      final career = allCategories.firstWhere(
            (cat) => cat.name.toLowerCase() == 'career',
        orElse: () => CategoryDTO(id: -1, name: 'Career'), // Default fallback
      );

      final health = allCategories.firstWhere(
            (cat) => cat.name.toLowerCase() == 'health',
        orElse: () => CategoryDTO(id: -2, name: 'Health'), // Default fallback
      );

      // Update the observable values
      careerCategory.value = career;
      healthCategory.value = health;

    } catch (e) {
      print('Error loading categories: $e');
    }
  }
// Save language preference to SharedPreferences
  Future<void> saveLanguagePreference(int index) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selectedLanguage', index);
    } catch (e) {
      print("Error saving language preference: $e");
    }
  }

  // Refresh data that depends on language
  void refreshLanguageDependentData() {
    /*
    // Reload categories to update translated titles
    loadCategories();
    // Any other data that depends on language

     */
  }

  // Method to update language and locale
  void updateLanguage(int index) {
    currentLanguage.value = index;
    updateLocaleFromLanguageIndex(index);

    // Save to shared preferences
    saveLanguagePreference(index);

    // Refresh data that depends on language
    refreshLanguageDependentData();
  }
  void changePage(int index) {
    currentIndex.value = index;
    Get.toNamed(pages[index], id: 1);  // No need for MaterialPageRoute, GetX handles it
  }

  CategoryDTO? checkCategory(String category){
    if(category == "career"){
      return careerCategory.value;
    }
    if(category == "health"){
      return healthCategory.value;
    }
    else {
      //#TODO better error handling
      return CategoryDTO(id: 1000, name: '');
    }
  }
  void navigateHome(){
    currentIndex.value = 0;
    Get.toNamed("/home");
  }

  Route? onGenerateRoute(RouteSettings settings) {
    if (settings.name == "/home") {
      return GetPageRoute(
        settings: settings,
        page: () => HomePage(selectedLanguage: selectedLanguage,),
        binding: HomeBinding(),
      );
    }
    if (settings.name == "/health") {
      return GetPageRoute(
          settings: settings,
          page: () =>
              ChapterPage(category: healthCategory.value!,
                  updateProgress: updateProgress)

      );
    }
    if (settings.name == "/career") {
      return GetPageRoute(
          settings: settings,
          page: () =>
              ChapterPage(category: careerCategory.value!,
                  updateProgress: updateProgress)

      );
    }
    if (settings.name == "/language") {
      return GetPageRoute(
          settings: settings,
          page: () => LanguagePageNav()

      );
      return null;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    var categoriesList = await databaseController.getCategories();
    categories.value = categoriesList;

    // Find and assign specific categories for the tabs
    // You'll need to adjust these conditions based on your actual data
    careerCategory.value = categoriesList.firstWhere(
          (cat) => cat.name.toLowerCase().contains('career') || cat.id == 2
    );

    healthCategory.value = categoriesList.firstWhere(
          (cat) => cat.name.toLowerCase().contains('health') || cat.id == 3
    );

    // Create a temporary map to store progress
    Map<int, ProgressModel> tempProgress = {};
    for (var c in categories) {
      tempProgress[c.id] = await databaseController.getVideoProgress(c.id);
    }

    // Update the observable map
    progress.value = tempProgress;
  }

  // Method to update progress
  void updateProgress(bool value) {
    if (value) {
      loadData(); // Reload data when progress is updated
    }
  }

  // Method to navigate to ChapterPage
  void navigateToChapter(CategoryDTO category) {
    Get.to(() => ChapterPage(
      category: category,
      updateProgress: updateProgress,
    ));
  }
}


 */
