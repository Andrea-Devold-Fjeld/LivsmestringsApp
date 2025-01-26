import '../models/video_item_model.dart';
import '../services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:get/get.dart';

List<String> CareerItems = [
  '1_me_in_context',
  '1.9_summary',
  '1.8_case_and_reflective',
  '1.7_roles',
  '1.6_reflective_task',
  '1.5_values',
  '1.4.1_task',
  '1.3_personal_qualities',
  '1.2_new_words',
  '1.4_interests',
  '1.3.1_reflective_task_personal_qualities',
  '1.1_introduction',
  '2_possibilties_and_limitations',
  '2.6_summary',
  '2.4.1_case_and_reflective',
  '2.2_new_words',
  '2.4.2_reflective_task',
  '2.1_introduction',
  '2.3_horizon_of_possibilities',
  '2.4_limitations',
  '2.5_thought_traps',
  '2.5.1_religion',
  '3_choices_and_chances',
  '3.6_summary',
  '3.3.1_case',
  '3.2_new_words',
  '3.5_reflective_task',
  '3.1_introduction',
  '3.4_good_coincidences',
  '3.4.1_case_volunteer_work',
  '3.3_own_choices',
  '4_adaptations_and_resistance',
  '4.1_introduction',
  '4.5_summary',
  '4.3_cases',
  '4.2_new_words',
  '4.4_reflective_task',
  '5_change_and_stability',
  '5.7_summary',
  '5.5_cases',
  '5.2_new_words',
  '5.6_reflective_task',
  '5.1_introduction',
  '5.4_stability',
  '5.3_change',
];



// This method ensure retrieving the tittles for Career modules
// The return variable is a list of Strings
List<String> getCareerModulesTittles(String state) {
  // implemented try/catch for handling errors
  try {
    //initiating list that will be returned
    List<String> result = [];
    // going through the CareerItems list
    for (String item in CareerItems) {
      //filtering CareerItems list to fetch Strings having only one digit
      if (item.length > 1 && item[1] == '_') {
        //appending the target string/tittle to the initiated list
        result.add(item);
      }
    }
    if(state == "Not_Translate"){
      //sending the list as a parameter to the sorting method
      return groupModulesTittles(result);
    }
    else{
      //sending the list as a parameter to the sorting and translating method
      return groupAndTranslateModulesTittles(result);
    }
  }
  catch (e) {
    // Handle exceptions
    print('Error in getCareerModulesTittles: $e');
    return [];
  }
}


// This method ensure retrieving the tittles for career videos
// The return variable is a list of Strings
List<String> getCareerModulesVideosTittle(int index, String state){

  // implemented try/catch for handling errors
  try {
    //initiating list that will be returned
    List<String> result = [];
    //incrementing the input index by 1
    String searchIndex = '${index + 1}';
    // going through the CareerItems list
    for (String item in CareerItems) {
      //filtering CareerItems list to fetch Strings with decimal numberings
      if (item.startsWith(searchIndex) && item[1] == ".") {
        //appending the target string/tittle to the initiated list
        result.add(item);
      }
    }
    // sending the list as a parameter to the sorting and translating method
    return groupAndTranslateSubModulesOrVideosTittle(result, state);
  }

  catch (e) {
    // Handle exceptions
    print('Error in getCareerModulesVideosTittle: $e');
    return [];
  }
}



// This method ensure retrieving the correct tittles for career modules
// The return variable is of type string which represent the translated module tittle
String getVideoPlayerCareerAppBarTittle(String tittle) {

  // implemented 'try/catch' block for handling errors
  try {
    //initiating a string variable that will be returned
    String result = "";
    // extracting the first digit of the input string
    String searchIndex = tittle[0];

    // going through the CareerItems list
    for (String item in CareerItems) {
      //filtering CareerItems list to fetch Strings having only one digit
      //the translated digit for the filtered string should also match the
      // first digit of the input string
      if (item[0].tr == searchIndex && item[1] == "_") {
        result = item; }
    }
    // returning the translated targeted module tittle
    return result.tr;
  }

  catch (e) {
    // Handle exceptions
    print('Error in getCareerAppBarTittle: $e');
    return "";
  }
}



// This method ensure sorting and translating the tittles for the modules
// The return variable is a list of Strings
List<String> groupAndTranslateModulesTittles(List<String> items) {
  // implemented try/catch for handling errors
  try {
    // Function to extract numerical values from a string
    num extractNumber(String str) {
      final RegExp regex = RegExp(r'^(\d+(\.\d+)?)(_.+)?$');
      final match = regex.firstMatch(str);
      return double.parse(match?.group(1) ?? '0');
    }
    // Group items based on numerical values
    Map<num, List<String>> groupedItems = {};
    for (String item in items) {
      num numValue = extractNumber(item);
      if (!groupedItems.containsKey(numValue)) {
        groupedItems[numValue] = []; }
      groupedItems[numValue]!.add(item); }
    // Sort and translate grouped items
    List<String> result = [];
    List<num> keys = groupedItems.keys.toList()..sort();
    for (num key in keys) {
      List<String> group = groupedItems[key]!;
      group.sort(); // Sort items within each group
      for (String item in group) {
        result.add(item.tr); // Append .tr suffix
      } }
    return result;
  }
  catch (e) {
    // Handle exceptions
    print('Error in groupAndTranslateModulesTittles: $e');
    return [];
  }
}

// This method ensure sorting the tittles for the modules
// The return variable is a list of Strings
List<String> groupModulesTittles(List<String> items) {
  // implemented try/catch for handling errors
  try {
    // Function to extract numerical values from a string
    num extractNumber(String str) {
      final RegExp regex = RegExp(r'^(\d+(\.\d+)?)(_.+)?$');
      final match = regex.firstMatch(str);
      return double.parse(match?.group(1) ?? '0');
    }
    // Group items based on numerical values
    Map<num, List<String>> groupedItems = {};
    for (String item in items) {
      num numValue = extractNumber(item);
      if (!groupedItems.containsKey(numValue)) {
        groupedItems[numValue] = []; }
      groupedItems[numValue]!.add(item); }
    // Sort the grouped items
    List<String> result = [];
    List<num> keys = groupedItems.keys.toList()..sort();
    for (num key in keys) {
      List<String> group = groupedItems[key]!;
      group.sort(); // Sort items within each group
      for (String item in group) {
        result.add(item);
      } }
    return result;
  }
  catch (e) {
    // Handle exceptions
    print('Error in groupModulesTittles: $e');
    return [];
  }
}



// This method ensure sorting and translating the tittles for videos or sub-models
// The return variable is a list of Strings
List<String> groupAndTranslateSubModulesOrVideosTittle(List<String> items, String state) {
  //implemented try/catch for handling errors
  try {
    //Function to extract numerical values from a string
    String extractNumber(String str) {
      final RegExp regex = RegExp(r'^(\d+(\.\d+)*)');
      final match = regex.firstMatch(str);
      return match?.group(1) ?? '0';}
    //Group items based on numerical values
    Map<String, List<String>> groupedItems = {};
    for (String item in items) {
      String num = extractNumber(item);
      if (!groupedItems.containsKey(num)) {
        groupedItems[num] = [];}
      groupedItems[num]!.add(item);}
    //Sort the grouped items
    List<String> result = [];
    List<String> keys = groupedItems.keys.toList()..sort();

    for (String key in keys) {
      List<String> group = groupedItems[key]!;
      group.sort(); //Sort items within each group
      for (String item in group) {
        if(state == "Not_Translate"){
          //Append the item without translating
          result.add(item);
        }
        else{
          //Append the translated item
          result.add(item.tr);
        }
      }
    }
    return result; }
  catch (e) {
    // Handle exceptions
    print('Error in groupAndTranslateModulesVideosTittle: $e');
    return [];
  }
}


//A method that returns a double which represents the progress in how much the user has watched of the career videos.
//To get the value the method retrieves the list of all topics in the chosen language, and chekcks against shared preferences
//if the videos are true or false, then divides the sum on the amount of headings.
Future<double> getCareerProgress() async {
  double result = 0.0;
  try {
    // Initialize SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get translated items
    List<String> itemResult = await groupAndTranslateWithoutHeadlinesCareer();

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
    print('Error in groupAndTranslateDetailsWithoutChaptersCareer: $e');
    return result;
  }
}

//This method takes in a list of strings that are all the career topic headings in the parameter.
// It then checks if these topics have been seen (true /false), and add the values in a mapping in order to return the nested list
// for adding a tic or not to the view if the user have watched the video or not.
//For the languages that dont use latin numerals we have to use another method to make the list.
Future<List<List<bool>>> getDataAboutUserHaveSeenVideos(List<String> careerItems) async {
  try {
    String language = await getCurrentLanguage();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if(language == "arabisk" || language == "pashto" || language == "urdu" || language == "farsi" || language == "dari"|| language == "tamil" || language == "thai"){
      return getDataAboutUserHaveSeenVideosOtherLanguages(prefs, careerItems);
    }
    else{
      List<String> itemResult = await groupAndTranslateWithoutHeadlinesCareer();
      List<List<bool>> result = [];
      result.add([]);
      String currentChapter = itemResult[0];
      int postion = 0;

      for (String item in itemResult) {
        // Update the mapping to the list according to chapters
        if (compareFirstDigits(item, currentChapter)) {
          result.add([]);
          currentChapter = item;
          postion++;
        }

        bool? checkValue = prefs.getBool(item);
        if (checkValue != null) {
          if (checkValue) {
            print("Video has been seen");
            result[postion].add(true);
          }
          else {
            print("Video has NOT been seen");
            result[postion].add(false);
          }
        }
        else {
          print("Video has NOT been seen");
          result[postion].add(false);
        }
      }

      print("This is the result: $result");
      return result;
    }
  }
  catch (e) {
    print('Error in getDataAboutUserHaveSeenVideos: $e');
    return [];
  }
}

//This method returns a list of strings that are all the video topics in career.
//For the different languages one has to use different regexes in order to traget
// and find the right strings to add to the list:
Future<List<String>> groupAndTranslateWithoutHeadlinesCareer() async {
  try {
    List<String> items = groupAndTranslateSubModulesOrVideosTittle(CareerItems, "");
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
    print('Error in groupAndTranslateWithoutHeadlinesCareer: $e');
    return [];
  }
}




//This method takes in a list of strings in the parameter, which is the videoTitles fetched for the current view.
//The method then retreives the first numeral value from the first item in the list.
// This is for determing which chapter we are in career.
//Then it fetches all the videoUrls for the given path based on the numeral value, this
// videolist of urls is returned back to the view.
Future<List<String>> getVideoUrlsCareer(List<String> careerModuleVideoTitles) async {
  try {

    num extractNumber(String str) {
      final RegExp regex = RegExp(r'^(\d+(\.\d+)?)(_.+)?$');
      final match = regex.firstMatch(str);
      return double.parse(match?.group(1) ?? '0');
    }

    Database database = Database();
    List<String> videoUrls = [];

    num firstItem = extractNumber(careerModuleVideoTitles.first);
    print("Detter er items før: $careerModuleVideoTitles");

    String currentLanguage = await getCurrentLanguage();
    String videoPath = "videos/$currentLanguage/";

    print("This is firstItem: $firstItem");

    if (firstItem == 1.1) {
      videoPath = "${videoPath}karriere/1.Meg_I_Kontekst/";
      videoUrls = await database.fetchAllVideos(videoPath);
    }
    else if (firstItem == 2.1) {
      videoPath = "${videoPath}karriere/2.Muligheter_Og_Begrensninger/";
      videoUrls = await database.fetchAllVideos(videoPath);
    }
    else if (firstItem == 3.1) {
      videoPath = "${videoPath}karriere/3.Valg_Og_Tilfeldigheter/";
      videoUrls = await database.fetchAllVideos(videoPath);
    }
    else if (firstItem == 4.1) {
      videoPath = "${videoPath}karriere/4.Tilpasning_Og_Motstand/";
      videoUrls = await database.fetchAllVideos(videoPath);
    }
    else if (firstItem == 5.1) {
      videoPath = "${videoPath}karriere/5.Endring_Og_Stabilitet/";
      videoUrls = await database.fetchAllVideos(videoPath);
    }
    else {
      print("getVideoUrls: Den er ikke en del av denne listen");
    }
    print("Returning Videos");
    return videoUrls;
  }
  catch (e) {
    print('Error in getVideoUrlsCareer: $e');
    return [];
  }
}

//This list simply aims to retrieve all the videoUrls in Career and return them back to the view
Future<List<String>> getAllVideoUrls() async{
  try{
    Database database = Database();
    List<String> videoUrls = [];

    String currentLanguage =  await getCurrentLanguage();

    String videoPath = "videos/$currentLanguage/karriere/";

    videoUrls = await database.fetchAllVideos(videoPath);

    print("Returning Videos");

    return videoUrls;
  }
  catch (e){
    print('Error in getAllVideoUrls(): $e');
    return [];
  }
}

//This method takes in a nested list of video items and a list of strings that contains urls in the parameter.
//It returns a nested list containting the urls that are provided in the parameter, only now are they nested and not flatten.
//The videoItemsNested is a list that contains all the nextVideos, so we want to make the same list, but with the current url instead of the next ...
Future<List<List<String>>> getAllVideoUrlsNested(List<List<VideoItem>> videoItemsNested, List<String> urls) async{
  try{
    List<List<String>> videoUrlsNested = [];
    int i = 0;

    for (List<VideoItem> videoList in videoItemsNested) {
      videoUrlsNested.add([]);

      for(VideoItem video in videoList){
        videoUrlsNested[i].add(urls.first);
        urls.remove(urls.first);
      }

      i++;
    }

    return videoUrlsNested;
  }
  catch (e){
    print('Error in getAllVideoUrlsNested(): $e');
    return [];
  }
}

//A method that returns the currentLanguage in the application:
Future<String> getCurrentLanguage() async{
  String currentLanguage = "";
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? language = prefs.getInt('selectedLanguage');
    if (language == 0) {
      currentLanguage = "engelsk";
    }
    else if (language == 1) {
      currentLanguage = "spansk";
    }
    else if (language == 2) {
      currentLanguage = "swahili";
    }
    else if (language == 3) {
      currentLanguage = "kurmanji";
    }
    else if (language == 4) {
      currentLanguage = "norsk";
    }
    else if (language == 5) {
      currentLanguage = "somali";
    }
    else if (language == 6) {
      currentLanguage = "tyrkisk";
    }
    else if (language == 7) {
      currentLanguage = "ukrainsk";
    }
    else if (language == 8) {
      currentLanguage = "urdu";
    }
    else if (language == 9) {
      currentLanguage = "arabisk";
    }
    else if (language == 10) {
      currentLanguage = "pashto";
    }
    else if (language == 11) {
      currentLanguage = "farsi";
    }
    else if (language == 12) {
      currentLanguage = "tamil";
    }
    else if (language == 13) {
      currentLanguage = "thai";
    }
    else if (language == 14) {
      currentLanguage = "amharisk";
    }
    else if (language == 15) {
      currentLanguage = "tigrinja";
    }
    else {
      print("getCurrentLanguge: Den er ikke en del av denne listen");
    }
    return currentLanguage;
  }
  catch (e){
    print('Error in getCurrentLanguage(): $e');
    return currentLanguage;
  }
}

//A method that takes in a list of strings containting urls, and a list of strings containing titles in the parameter.
//If the method are to return a list populated of video items, then the sizes of the url list and title list have to be the same.
//If they are the same, then the we start iterating through the lists, starting from behind.
// The reason is to get all the items to know there next item. But when we are done adding the items from behind,
// the last item is first in the list, so we have to turn the list, and then return it.
Future<List<VideoItem>> nextVideoItems(List<String> url, List<String> title) async {
  try {
    List<VideoItem> nextVideoReversed = [];
    List<VideoItem> nextVideo = [];

    // Check if both lists are not empty and have the same length
    if (url.isNotEmpty && title.isNotEmpty && url.length == title.length) {
      // Iterate through the list of titles and URLs
      VideoItem videoItem;
      int counter = -1;
      for (int i = url.length; i != 0; i--) {
        // Create a new VideoItem
        if (i == url.length) {
          //The last item should be emptey
          videoItem = VideoItem(title: "", url: "", nextItem: null);
        }
        else {
          videoItem = VideoItem(title: title[i],
              url: url[i],
              nextItem: nextVideoReversed.elementAt(counter));
        }
        // Add the VideoItem to the list
        nextVideoReversed.add(videoItem);
        counter++;
      }

      for (int i = nextVideoReversed.length - 1; i > -1; i--) {
        nextVideo.add(nextVideoReversed[i]);
      }

    }
    else {
      int urlSize = url.length;
      int titleSize = title.length;
    }

    return nextVideo;
  }
  catch (e){
    print('Error in nextVideoItems(): $e');
    return [];
  }
}

//A method that takes in two strings in the parameter.
// Then the method tries to extract an integer from each of the strings, if it is successfull, the integers are compared.
//If they are the same it returns true, if not, it returns false.
bool compareFirstDigits(String string1, String string2) {
  print("comparing string 1: $string1, with string2: $string2");
  // Extract digits from the beginning of each string
  int? digit1 = int.tryParse(
      string1.split('').firstWhere((c) => c.contains(RegExp(r'\d')),
          orElse: () => ""));
  int? digit2 = int.tryParse(
      string2.split('').firstWhere((c) => c.contains(RegExp(r'\d')),
          orElse: () => ""));

  print("The value to compare is $digit1, vs $digit2");
  // Compare the extracted digits
  return digit1 != digit2;
}

//This method takes in the headings for career items as a list of strings, and shared preferences in the parameter.
//It then iterates over the list of headings, fetches the corresponding videotopics for each chapter and checks if the videos have been watched.
//The nested list with boolean values are then returned
List<List<bool>> getDataAboutUserHaveSeenVideosOtherLanguages(SharedPreferences prefs, List<String> careerItems){
  try{
    List<List<bool>> returnList = [];
    int i = 0;

    for(String heading in careerItems){
      returnList.add([]);
      List<String> anIteration = getCareerModulesVideosTittle(i, "");

      for(String item in anIteration){
        bool? checkValue = prefs.getBool(item);
        if (checkValue != null) {
          if (checkValue) {
            print("Video has been seen");
            returnList[i].add(true);
          }
          else {
            print("Video has NOT been seen");
            returnList[i].add(false);
          }
        }
        else {
          print("Video has NOT been seen");
          returnList[i].add(false);
        }
      }

      i++;
    }

    return returnList;
  }
  catch(e){
    print('Error in getDataAboutUserHaveSeenVideosOtherLanguages: $e');
    return [];
  }
}

//This method takes in a list of videoitems and a list of strings that are the headings for career in the parameter.
//The method then iterates over the headings, for each heading a new nested list is added, and the corresponding video titles are fetched.
//Since the videoItems are in the right order, it is only about getting the right amount mapped in the same nested list.
//Then the nested list of video items are returned to be used in the view matching the headings and video titles nested there.
List<List<VideoItem>> videosMappedInOtherLanguages(List<VideoItem> videoItems, List<String> careerItems){
  List<List<VideoItem>> returnlist = [];
  int i = 0;
  int j = 0;
  for(String heading in careerItems){
    returnlist.add([]);
    List<String> anIteration = getCareerModulesVideosTittle(i, "");
    for(String item in anIteration){
      returnlist[i].add(videoItems[j]);
      j++;
    }
    i++;
  }

  return returnlist;
}

//This method takes in a list of videoitems and a list of strings that are the headings for career in the parameter.
//It then checks for the current language, and then decides which method to use.
//If the else is triggered, then a nested list of video items are created. For each iteration of the video items we check if we
// have entered a new chapter by comparing the titles, if we have,  then we add a new nested list and starts to add there.
// If not, then we add videos in the curretn nested list.
//When finsished, the nested list of videoitems is returned.
Future<List<List<VideoItem>>> nextVideoItemsNested(List<VideoItem> videoItems, List<String> careerItems) async{
  try {
    String language = await getCurrentLanguage();

    if(language == "arabisk" || language == "pashto" || language == "urdu" || language == "farsi" || language == "dari"|| language == "tamil" || language == "thai"){
      return videosMappedInOtherLanguages(videoItems, careerItems);
    }
    else {
      List<List<VideoItem>> result = [];
      result.add([]);
      String currentVideoChapter = videoItems[0].title;
      int postion = 0;

      for (VideoItem video in videoItems) {
        if (compareFirstDigits(currentVideoChapter, video.title)) {
          result[postion].add(video);
          result.add([]);
          currentVideoChapter = video.title;
          postion++;
        }
        else {
          String title = video.title;
          print("Adding this video: $title, this is position: $postion");
          result[postion].add(video);
        }
      }

      return result;
    }
  }
  catch (e){
    print('Error in nextVideoItemsNested: $e');
    return [];
  }
}


