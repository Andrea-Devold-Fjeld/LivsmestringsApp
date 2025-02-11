
import 'package:get/get.dart';

import '../models/DataModel.dart';

Datamodel findAndReplaceAndTranslate(Datamodel data){
  List<Chapter> newChapter = [];
  for (var c in data.chapters) {
        List<Video> newVideo = [];
        for (var v in c.videos) {
              List<Task> newTask = [];
              v.tasks?.forEach(
                      (t) {
                    newTask.add(Task(title: t.title.replaceAll("_", " ").tr, url: t.url));
                  }
              );
              newVideo.add(Video(title: v.title.replaceAll("_", " ").tr, url: v.url, tasks: newTask));
            }
        newChapter.add(Chapter(title: c.title.replaceAll("_", " ").tr, videos: newVideo));
      }
  return Datamodel(chapters: newChapter);
}


List<String> getCareerModulesTitles(String state, Datamodel data) {
  List<String> newModuleTitle = [];
  for (var v in data.chapters) {
    newModuleTitle.add(v.title);
  }

  return newModuleTitle;
}
