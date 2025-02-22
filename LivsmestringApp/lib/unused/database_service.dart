import 'package:firebase_storage/firebase_storage.dart';

/*
class Database {
  FirebaseStorage storage = FirebaseStorage.instance;
  //A method that takes in a path as a string in the paramether and returns the video url.
  //It uses the path to make a storage reference and donwload the url.
  Future<String> fetchVideoUrl(String videoPath) async {
    try {
      String downloadUrl = await storage.ref(videoPath).getDownloadURL();
      return downloadUrl;
    }
    catch (e){
      print("Error in fetchVideoUrl(): $e");
      return "";
    }
  }

  //This method takes in string that is a folderpath in the parameter.
  //In the logic inside it calls itslef recursively in order to fetch all
  // of the folders and references contained inside the first path.
  //It then returns a list of video urls as strings in an array.
  Future<List<String>> fetchAllVideos(String folderPath) async {
    try {
      List<String> downloadUrls = [];
      print("This is folderPath: $folderPath");
      Reference videosFolderRef = storage.ref(folderPath);

      ListResult result = await videosFolderRef.listAll();

      List<Future<List<String>>> futures = [];
      for (var folder in result.prefixes) {
        print("Folder: $folder");
        String fullPath = folder.fullPath;
        print("FullPath: $fullPath");

        // Collect futures from recursive calls
        futures.add(fetchAllVideos(folder.fullPath));
      }

      for (var item in result.items) {
        String downloadUrl = await item.getDownloadURL();
        print('Download URL: $downloadUrl');
        downloadUrls.add(downloadUrl);
      }
      // Wait for all recursive calls to complete
      List<List<String>> subFolderUrls = await Future.wait(futures);

      // Flatten the nested list hiearchy:
      for (var urls in subFolderUrls) {
        downloadUrls.addAll(urls);
      }

      print("This is downloadUrls: $downloadUrls");
      return downloadUrls;
    }
    catch (e){
      print("Error in fetchAllVideos(): $e");
      return [];
    }
  }

}

 */
