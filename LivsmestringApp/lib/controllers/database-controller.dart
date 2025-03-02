import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:livsmestringapp/dto/category_dto.dart';
import 'package:livsmestringapp/models/VideoUrl.dart';
import 'package:sqflite/sqflite.dart';

import '../databse/database_operation.dart';
import '../models/DataModel.dart';

class DatabaseController extends GetxController {
  final Future<Database> db;

  DatabaseController(this.db);

  Future<void> insertDatamodel(Datamodel data, VideoUrls urls) async {
    await insertDataModel(db, data, urls);
  }
  Future<void> markVideoWatched(String videoTitle) async {
    await updateVideoWatchStatus(db, videoTitle, true);
  }

  Future<void> markTaskWatched(String taskUrl) async {
    await updateTaskWatchStatus(db, taskUrl, true);
  }

  Future<Datamodel> getDatamodel(String category) async {
    return await getDataModel(db, category);
  }

  Future<Datamodel> getDatamodelWithLAnguage(String category, String language) async {
    return await getDatamodelByLanguage(db, category, language);
  }

  Future<ProgressModel> getVideoProgress(int categoryId) async {
    return await getProgress(db, categoryId);
  }

  Future<List<CategoryDTO>> getCategories() async {
    return await getAllCategories(db);
  }

  Future<void> updateUrl(Video video, String url) async {
    return await updateVideoUrl(db, video.title, url);
  }

}