import 'dart:developer';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:livsmestringapp/models/VideoUrl.dart';

import '../models/DataModel.dart';

Datamodel findAndReplaceAndTranslate(Datamodel data, VideoUrlsResponse urls, Locale locale) {
  log("in find and replace for locale: ${locale.languageCode}");

  List<Chapter> newChapters = [];

  // Process each chapter
  for (var chapter in data.chapters) {
    List<Video> newVideos = [];

    // Process each video in the chapter
    for (var video in chapter.videos) {
      String videoTitle = video.title;
      String? videoUrl;

      // Find matching video URL from the response
      for (var urlVideo in urls.videoUrls) {
        // Compare video titles (normalized for comparison)
        if (urlVideo.title.toLowerCase().replaceAll("_", " ") ==
            videoTitle.toLowerCase().replaceAll("_", " ")) {

          // Find the right language URL
          for (var lang in urlVideo.languages) {
            if (lang.language == locale.languageCode) {
              videoUrl = lang.url;
              log("Found URL for video '${videoTitle}' in ${locale.languageCode}: ${videoUrl}");
              break;
            }
          }

          // If no exact language match, try to use a default
          if (videoUrl == null && urlVideo.languages.isNotEmpty) {
            videoUrl = urlVideo.languages[0].url;
            log("No URL for '${videoTitle}' in ${locale.languageCode}, using default: ${videoUrl}");
          }

          break;
        }
      }

      // Process tasks for this video
      List<Task> newTasks = [];
      if (video.tasks != null) {
        for (var task in video.tasks!) {
          String taskTitle = task.title;
          String? taskUrl;

          // Find matching task URL from the response (if applicable)
          for (var urlVideo in urls.videoUrls) {
            if (urlVideo.title.toLowerCase().replaceAll("_", " ") ==
                taskTitle.toLowerCase().replaceAll("_", " ")) {

              // Find the right language URL for the task
              for (var lang in urlVideo.languages) {
                if (lang.language == locale.languageCode) {
                  taskUrl = lang.url;
                  break;
                }
              }

              // If no exact language match, try to use a default
              if (taskUrl == null && urlVideo.languages.isNotEmpty) {
                taskUrl = urlVideo.languages[0].url;
              }

              break;
            }
          }

          // Add the task with the found URL or the original URL if not found
          newTasks.add(Task(
              title: task.title.replaceAll("_", " ").tr,
              url: taskUrl ?? task.url
          ));
        }
      }

      // Add the video with the found URL or the original URL if not found
      newVideos.add(Video(
          title: video.title.replaceAll("_", " ").tr,
          url: videoUrl ?? video.url,
          tasks: newTasks.isEmpty ? null : newTasks
      ));
    }

    // Add the chapter with updated videos
    newChapters.add(Chapter(
        title: chapter.title.replaceAll("_", " ").tr,
        videos: newVideos
    ));
  }

  return Datamodel(
      chapters: newChapters,
      category: data.category
  );
}

List<String> getCareerModulesTitles(String state, Datamodel data) {
  List<String> newModuleTitle = [];
  for (var chapter in data.chapters) {
    newModuleTitle.add(chapter.title);
  }
  return newModuleTitle;
}