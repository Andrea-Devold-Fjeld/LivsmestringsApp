import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../services/career_data.dart';
import 'package:get/get.dart';

List<String> HealthItems = [
  '7_physical_and_psychological',
  '8_new_in_norway',
  '9_right_to_live',
  '7.1_health_and_lifestyle',
  '7.2_migration_process',
  '7.1.1_doctor_healthy_start',
  '7.1.2_doctor_general_practitioners',
  '7.1.3_general_practitioners',
  '7.1.4_what_is_gp',
  '7.1.5_physical_activity',
  '7.1.6_food_and_health',
  '7.1.7_bullying',
  '7.1.8_stress_healthy_start',
  '7.1.9_psychological_health',
  '8.1_doctor',
  '8.2_migration_process',
  '8.3_oral_health',
  '8.4_food_and_health',
  '9.1_sanitation_women',
  '9.2_queer_world',
  '9.3_introduction',
  '9.1.1_introduction',
  '9.1.2_new_words',
  '9.1.3_what_is_violence',
  '9.1.4_close_relationships',
  '9.1.5_confidentiality',
  '9.1.6_sign_of_Violence',
  '9.1.7_who_can_help',
  '9.1.8_who_can_help',
  '9.1.9_case',
  '9.2.1_discrimination',
  '9.2.2_social_norms',
  '9.2.3_diversity',
  '9.2.4_freedom_of_choice',
  '8.1.1_psychological_health',
];


// This method ensure retrieving the tittles for health sub-modules videos accessed through bottom navigation bar
// The return variable is a list of Strings
List<String> getHealthSubModulesVideosTittle(int moduleIndex, int subModuleIndex) {

  // implemented try/catch for handling errors
  try {
    //initiating list that will be returned
    List<String> result = [];
    //incrementing the index that refers to module tittle by 7
    String moduleIndexSt = '${moduleIndex +7}';
    //incrementing the index that refers to sub-module tittle by 1
    String subModuleIndexSt = '${subModuleIndex +1}';
    // going through the HealthItems list
    for (String item in HealthItems) {
      //filtering HealthItems list to fetch strings that match the criteria
      if (item.startsWith(moduleIndexSt) && item[1] == '.'
          && item[3] == '.' && item[2] == subModuleIndexSt) {
        //appending the target string/tittle to the initiated list
        result.add(item);
      }
    }
    //sending the list as a parameter to the sorting and translating method
    return groupAndTranslateSubModulesOrVideosTittle(result, "");
  }

  catch (e) {
    // Handle exceptions
    print('Error in getHealthSubModulesVideosTittle: $e');
    return [];
  }
}


// This method ensure retrieving the tittles for health sub-modules videos accessed through home page
// The return variable is a list of Strings
List<String> getSubModuleIndexAndVideosTittle(List<String> subModulesTittles, String subModuleTittle, int moduleIndex) {
  // implemented try/catch for handling errors
  try {
    //initiating list that will be returned
    List<String> result = [];
    //integer variable that will identify sub-module index
    int? subModuleIndex;

    //filtering the sub-modules to fetch the index for the sub-module tittle clicked on
    for (int i = 0; i < subModulesTittles.length; i++) {
      if (subModuleTittle == subModulesTittles[i]) {
        //assigning the value of the sub-module's index to the already initiated integer
        subModuleIndex = i;
      }
    }
    //incrementing the index that refers to module tittle by 7
    String moduleIndexStr = '${moduleIndex + 7}';
    //incrementing the index that refers to sub-module tittle by 1
    String subModuleIndexStr = '${subModuleIndex! + 1}';
    // going through the HealthItems list
    for (String item in HealthItems) {
      //filtering HealthItems list to fetch strings that match the criteria
      if (item.startsWith(moduleIndexStr) && item[2] == subModuleIndexStr &&
          item[3] == '.') {
        //appending the target string/tittle to the initiated list
        result.add(item);
      }
    }
    //sending the list as a parameter to the sorting and translating method
    return groupAndTranslateSubModulesOrVideosTittle(result, "");
  }

  catch (e) {
// Handle exceptions
    print('Error in getSubModuleIndexAndVideosTittle: $e');
    return [];
  }
}


//This method ensure retrieving the correct tittles for health sub-modules
//The return variable is of type string which represent the translated sub-module tittle
String getVideoPlayerHealthAppBarTittle(String tittle) {
  // implemented 'try/catch' block for handling errors
  try {
    //initiating a string variable that will be returned
    String result = "";
    //extracting the first digit of the string that refers to the module tittle
    String searchIndex1 = tittle[0];
    //extracting the second digit of the string that refers to the sub-module tittle
    String searchIndex2 = tittle[2];

    // going through the HealthItems list
    for (String item in HealthItems) {
      //filtering HealthItems list to fetch Strings having only two digits
      //the translated digits for the filtered string should also match the
      //digits within the input string
      if (item[0].tr == searchIndex1 && item[2].tr == searchIndex2 && item[3] == "_") {
        result = item;
      }
    }
    // returning the translated targeted sub-module tittle
    return result.tr;
  }

  catch (e) {
    // Handle exceptions
    print('Error in getHealthAppBarTittle: $e');
    return "";
  }
}


// This method ensure sorting the tittles for the sub-models
// The return variable is a list of Strings
List<String> groupSubModulesTittles(List<String> items) {
  //implemented try/catch for handling errors
  try {
    // Function to extract numerical values from a string
    String extractNumber(String str) {
      final RegExp regex = RegExp(r'^(\d+(\.\d+)*)');
      final match = regex.firstMatch(str);
      return match?.group(1) ?? '0';
    }
    // Group items based on numerical values
    Map<String, List<String>> groupedItems = {};
    for (String item in items) {
      String num = extractNumber(item);
      if (!groupedItems.containsKey(num)) {
        groupedItems[num] = [];
      }
      groupedItems[num]!.add(item);
    }
    // Sort and translate grouped items
    List<String> result = [];
    List<String> keys = groupedItems.keys.toList()
      ..sort();
    for (String key in keys) {
      List<String> group = groupedItems[key]!;
      // Sort items within each group
      group.sort();
      for (String item in group) {
        result.add(item);
      }
    }
    return result;
  }
  catch (e) {
// Handle exceptions
    print('Error in  groupSubModulesTittles: $e');
    return [];
  }
}


// This method ensure retrieving the tittles for health modules
// The return variable is a list of Strings
List<String> getHealthModulesTittles() {

  // implemented try/catch for handling errors
  try {
    // initiating list that will be returned
    List<String> result = [];
    // going through the HealthItems list
    for (String item in HealthItems) {
      // filtering HealthItems list to fetch Strings having only one digit
      if (item.length > 1 && item[1] == '_') {
        // appending the target string/key/tittle to the initiated list
        result.add(item);
      }
    }
    // sending the list as a parameter to the sorting and translating method
    return groupAndTranslateModulesTittles(result);
  }

  catch (e) {
// Handle exceptions
    print('Error in getHealthModulesTittles: $e');
    return [];
  }
}



// This method is used on health pages
// This method ensure retrieving the tittles for sub-models on the health pages
// The return variable is a list of Strings
List<String> getHealthSubModuleTittles(int index, String state) {

  // implemented try/catch for handling errors
  try {
    //initiating list that will be returned
    List<String> result = [];
    //incrementing the input index by 7
    String searchIndex = '${index+7}';
    // going through the HealthItems list
    for (String item in HealthItems) {
      //filtering HealthItems list to fetch Strings having single decimal number
      if (item.startsWith(searchIndex) && item[1] == "." && item[3] == '_') {
        //appending the target string/key/tittle to the initiated list
        result.add(item);
      }
    }
    if(state == "Not_Translate") {
      //sending the list to be returned as a parameter to sorting method
      return groupSubModulesTittles(result);
    }
    else{
      //sending the list to be returned as a parameter to sorting and translating method
      return  groupAndTranslateSubModulesOrVideosTittle(result, "");
    }
  }

  catch (e) {
    // Handle exceptions
    print('Error in  getHealthSubModuleTittles: $e');
    return [];
  }
}


//This method takes in a string in the parameter that is not a translated item, the item is a videoItemTitle.
//The method then retreives the  numeral value from the item. This is for determing which chapter we are in Health.
//Then it fetches all the videoUrls for the given path based on the numeral value, this videolist of urls is returned back to the view.
Future<List<String>> getVideoUrlsHealth(String unTranslatedItem) async {
  try {

    num extractNumber(String str) {
      final RegExp regex = RegExp(r'^(\d+(\.\d+)?)(_.+)?$');
      final match = regex.firstMatch(str);
      return double.parse(match?.group(1) ?? '0');
    }

    Database database = Database();
    List<String> videoUrls = [];

    String currentLanguage = await getCurrentLanguage();

    num numberItem = extractNumber(unTranslatedItem);

    print("Detter er item før: $unTranslatedItem");


    String videoPath = "videos/$currentLanguage/helse/";

    print("This is firstItem: $numberItem");

    if (numberItem == 7.1) {
      videoPath = "${videoPath}6.Fysisk_Og_Psykisk_Helse/6.1Helse_Og_Livsstil/";
      videoUrls = await database.fetchAllVideos(videoPath);
    }
    else if (numberItem == 7.2) {
      videoPath = "${videoPath}6.Fysisk_Og_Psykisk_Helse/6.2Migrasjonsprosessen/";
      videoUrls = await database.fetchAllVideos(videoPath);
    }
    else if (numberItem == 8.1) {
      videoPath = "${videoPath}7.Ny_I_Norge/7.1Fastlegen/";
      videoUrls = await database.fetchAllVideos(videoPath);
    }
    else if (numberItem == 8.2) {
      videoPath = "${videoPath}7.Ny_I_Norge/7.2Migrasjonsprosessen/";
      videoUrls = await database.fetchAllVideos(videoPath);
    }
    else if (numberItem == 8.3) {
      videoPath = "${videoPath}7.Ny_I_Norge/7.3Munnhelse/";
      videoUrls = await database.fetchAllVideos(videoPath);
    }
    else if (numberItem == 8.4) {
      videoPath = "${videoPath}7.Ny_I_Norge/7.4Mat_Og_Helse/";
      videoUrls = await database.fetchAllVideos(videoPath);
    }
    else if (numberItem == 9.1) {
      videoPath = "${videoPath}8.Retten_Til_Å_Leve_Et_Fritt_Og_Selvstendig_Liv/8.1Sanitetskvinnene/";
      videoUrls = await database.fetchAllVideos(videoPath);
    }
    else if (numberItem == 9.2) {
      videoPath = "${videoPath}8.Retten_Til_Å_Leve_Et_Fritt_Og_Selvstendig_Liv/8.2Skeiv_Verden/";
      videoUrls = await database.fetchAllVideos(videoPath);
    }
    else {
      print("getVideoUrlsHealth: Den er ikke en del av denne listen");
    }
    print("Returning Videos");
    return videoUrls;
  }
  catch (e) {
    print('Error in getVideoUrlsHealth: $e');
    return [];
  }
}

//A method that returns a double which represents the progress in how much the user has watched of the health videos.
//To get the value the method retrieves the list of all topics in the chosen language, and checks against shared preferences
//if the videos are true or false, then divides the sum on the amount of headings and returns the value.
Future<double> getHealthProgress() async {
  double result = 0.0;
  try {
    // Initialize SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get translated items
    List<String> itemResult = await groupAndTranslateWithoutHeadlinesHealth();

    // Check if itemResult is empty
    if (itemResult.isEmpty) {
      throw Exception('itemResult is empty.');
    }

    // Calculate career progress
    for (String item in itemResult) {
      bool? checkValue = prefs.getBool(item);
      if (checkValue != null && checkValue) {
        result++;
      }
    }

    // Perform division
    result = result / itemResult.length;

    return result;
  }
  catch (e) {
    print('Error in getHealthProgress(): $e');
    return result;
  }
}

//This method returns a list of strings that are all the video topics in career.
//For the different languages one has to use different regexes in order to traget and find the right strings to add to the list:
Future<List<String>> groupAndTranslateWithoutHeadlinesHealth() async {
  try {
    List<String> items = groupAndTranslateSubModulesOrVideosTittle(HealthItems, "");
    List<String> itemResult = [];
    String language = await getCurrentLanguage();

    RegExp regex1;
    RegExp regex2;

    if (language == "arabisk") {
      regex1 = RegExp(r'^[١-٩]+\.[١-٩]+\s');
      regex2 = RegExp(r'^[١-٩]+\.[١-٩]+\S');
    }
    else if (language == "pashto" || language == "urdu") {
      regex1 = RegExp(r'^[۱-۹]+\.[۱-۹]+\s');
      regex2 = RegExp(r'^[۱-۹]+\.[۱-۹]+\S');
    }
    else if(language == "farsi" || language == "dari"){
      regex1 = RegExp(r'^[۰-۹]+\.[۰-۹]+\s');
      regex2 = RegExp(r'^[۰-۹]+\.[۰-۹]+\S');
    }
    else if(language == "tamil"){
      regex1 = RegExp(r'^[௦-௯]+\.[௦-௯]+\s');
      regex2 = RegExp(r'^[௦-௯]+\.[௦-௯]+\S');
    }
    else if(language == "thai"){
      regex1 = RegExp(r'^[๐-๙]+\.[๐-๙]+\s');
      regex2 = RegExp(r'^[๐-๙]+\.[๐-๙]+\S');
    }
    else{
      regex1 = RegExp(r'^\d+\.\d+\s');
      regex2 = RegExp(r'^\d+\.\d+\S');
    }

    for (String item in items) {

      final match1 = regex1.firstMatch(item);
      final match2 = regex2.firstMatch(item);

      if (match1 != null) {
        itemResult.add(item);
      }
      else if (match2 != null) {
        itemResult.add(item);
      }
    }

    return itemResult;
  }
  catch (e) {
    print('Error in groupAndTranslateWithoutHeadlinesHealth(): $e');
    return [];
  }
}


// Fetches data about whether the user has seen videos related to health.
//The function takes in the chapter heading and a list of health item indices
//to check against the shared preferences. It returns a list of boolean values
// indicating whether each corresponding video has been seen by the user.
Future<List<bool>> getDataAboutUserHaveSeenVideosHealth(List<String> healthItemIndexList) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<bool> result = [];
    for (String item in healthItemIndexList) {
      bool? checkValue = prefs.getBool(item);
      if (checkValue != null) {
        if (checkValue) {
          print("Video has been seen");
          result.add(true);
        }
        else {
          print("Video has NOT been seen");
          result.add(false);
        }
      }
      else {
        print("Video has NOT been seen");
        result.add(false);
      }
    }
    return result;
  }
  catch (e) {
    print('Error in getDataAboutUserHaveSeenVideosHealth: $e');
    return [];
  }
}


//This method takes in a list of strings two times and a string in the parameter. The reason is to find out which
//item in the one list the string matches. If they match, then we want the corresponding lists item at that index to be returned.
//The reason for that beeing that we need a untranslated string in order to extract a digit and find its numerical value. That
//is not possible with arabic, pashto or urdu.
String getHeadlineNotTranslatedHealth(List<String> translatedResult, String translatedHeading, List<String> unTranslatedResult){
  try{
    String result = "";
    int i = 0;

    for(String heading in translatedResult){
      if(heading == translatedHeading){
        result = unTranslatedResult[i];
        break;
      }
      i++;
    }

    print("This is result before returning: $result");

    return result;
  }
  catch (e){
    print('Error in getHeadlineNotTranslatedHealth(): $e');
    return "";
  }
}





