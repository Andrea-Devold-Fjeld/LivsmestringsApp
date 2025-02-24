import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:livsmestringapp/pages/home_page.dart';
import 'package:livsmestringapp/pages/language_page_nav.dart';

import '../databse/database_operation.dart';
import '../dto/category_dto.dart';
import '../pages/chapter-page.dart';
import 'database-controller.dart';


class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomePageController());
  }
}



class HomePageController extends GetxController {
  // Observable variables
  final RxList<CategoryDTO> categories = <CategoryDTO>[].obs;
  final Rx<Map<int, ProgressModel>> progress = Rx<Map<int, ProgressModel>>({});

  // Add these two new properties for the navigation tabs
  final Rx<CategoryDTO?> careerCategory = Rx<CategoryDTO?>(null);
  final Rx<CategoryDTO?> healthCategory = Rx<CategoryDTO?>(null);

  final DatabaseController databaseController = Get.find<DatabaseController>();
  var currentIndex = 0.obs;

  final pages = <String>["/home", "/career", "/health","/language"];

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
        page: () => HomePage(),
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