import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:livsmestringapp/consumer/FetchData.dart';
import 'package:livsmestringapp/models/DataModelDTO.dart';
import 'package:livsmestringapp/pages/home_page.dart';
import 'package:livsmestringapp/pages/language_page_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../databse/database_operation.dart';
import '../dto/category_dto.dart';
import '../main.dart';
import '../models/page_enum.dart';
import '../pages/chapter-page.dart';
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
  DatamodelDto? careerData;
  DatamodelDto? healthData;
  bool isDataLoading = false;
  final DatabaseController databaseController = Get.find<DatabaseController>();

  // Variables for language
  var selectedLanguage = Rx<int?>(null);
  var currentLocale = Rx<Locale?>(null); // Default locale

  @override
  void onInit() {
    super.onInit();
    loadData();

    // Load initial data when controller initializes
    ever(currentLocale, (_) async {
      // If currentLocale is set (not null), call loadData
      if (currentLocale.value != null && !isDataLoading) {
        Get.updateLocale(currentLocale.value!);
        log("In onInit in HomeController ${careerData}"); // Debug the data to ensure it is set
        await fetchAllData();
        //      loadData();
      }
    });

  }

  void setLocale(Locale locale){
    _loadProgressWithLocale(locale);
    currentLocale.value = locale;
    fetchAllData();
  }
  Future<List<CategoryDTO>> getCategories() {
    return databaseController.getCategories();
  }


  Future<bool> insertData() async {
    try {
      final careerResults = await fetchData('career');
      final healthResult = await fetchData('health');
      //Future.wait([
        //fetchData('career'),
        //fetchData('health'),
      //final resultVideoUrls = await Future.wait([
      //  fetchVideoUrls()
      //]);

      databaseController.insertDatamodel(careerResults);
      databaseController.insertDatamodel(healthResult);
      return true;
    }catch (e){
      log("Error: $e");
      return false;
    }

  }
  Future<bool> fetchAllData() async {
    try {
      var data = await databaseController.getDatamodelWithLAnguage('career', currentLocale.value!.languageCode);
      var healthDat = await databaseController.getDatamodelWithLAnguage('health', currentLocale.value!.languageCode);

      _loadProgress();
      careerData = data;
      healthData = healthDat;
      return true;
    }catch (e){
      log("Error: $e");
      return false;
    }


  }

  // Navigation method
  void changePage(int index) {
    log("Current index $index");
    var listPages = Pages.values;
    if(index < 0  && index > listPages.length) return;
    currentIndex.value = index;
    log("IN change page in homeController ${currentIndex.value.toString()}");
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
  Future<void> _loadProgressWithLocale(Locale locale) async {
    try {
      // Create a temporary map to store progress
      Map<int, ProgressModel> tempProgress = {};
      for (var c in categories) {
        tempProgress[c.id] = await databaseController.getVideoProgress(c.id, locale);
      }

      // Update the observable map
      progress.value = tempProgress;
    } catch (e) {
      print('Error loading progress: $e');
    }
  }
  // Load progress for all categories
  Future<void> _loadProgress() async {
    try {
      // Create a temporary map to store progress
      Map<int, ProgressModel> tempProgress = {};
      for (var c in categories) {
        tempProgress[c.id] = await databaseController.getVideoProgress(c.id, currentLocale.value!);
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
      if (kDebugMode) {
        print("Error saving language preference: $e");
      }
    }
  }

  // Refresh data that depends on language
  Future<void> refreshLanguageDependentData() async {
    try {
      // Reload all data when language changes
      await loadData();
    } catch (e) {
      if (kDebugMode) {
        print("Error refreshing language-dependent data: $e");
      }
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
      if (kDebugMode) {
        print('Error in checkCategory: $e');
      }
      return null;
    }
  }
}
