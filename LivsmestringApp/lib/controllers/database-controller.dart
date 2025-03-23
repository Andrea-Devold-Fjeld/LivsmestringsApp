import 'dart:ui';

import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:livsmestringapp/dto/category_dto.dart';
import 'package:livsmestringapp/models/DataModelDTO.dart';
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
/*
  Future<DatamodelDto> getDatamodel(String category) async {
    return await getDatamodel(db, category);
  }

 */

  Future<DatamodelDto> getDatamodelWithLAnguage(String category, String language) async {
    return await getDataModelWithLanguage(db, category, language);
  }

  Future<ProgressModel> getVideoProgress(int categoryId, Locale locale) async {
    return await getProgress(db, categoryId, locale);
  }

  Future<List<CategoryDTO>> getCategories() async {
    return await getAllCategories(db);
  }

  Future<void> updateTotalLength(Duration duration, String url) async {
    return await updateTotalVideoLength(db, duration, url);
  }

  Future<void> updateWatchTime(Duration duration, String url) async {
    return await updateVideoWatchTime(db, duration, url);
  }

}