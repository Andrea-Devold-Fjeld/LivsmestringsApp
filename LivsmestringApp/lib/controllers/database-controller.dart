import 'dart:developer';
import 'dart:ui';

import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:livsmestringapp/dto/category_dto.dart';
import 'package:livsmestringapp/models/DataModelDTO.dart';
import 'package:livsmestringapp/models/VideoUrl.dart';
import 'package:livsmestringapp/models/cateregory.dart';
import 'package:sqflite/sqflite.dart';

import '../databse/database_operation.dart';
import '../models/DataModel.dart';

class DatabaseController extends GetxController {
  final Future<Database> db;

  DatabaseController(this.db);

  Future<void> insertDatamodel(Datamodel data) async {
    await insertDataModel(db, data);
  }
  Future<void> markVideoWatched(String videoTitle) async {
    await updateVideoWatchStatus(db, videoTitle, true);
  }

  Future<void> markTaskWatched(String taskUrl) async {
    await updateTaskWatchStatus(db, taskUrl, true);
  }


  Future<CategoryDto> getDatamodelWithLAnguage(String category, String language) async {
    var data = await getDataModelWithLanguage(db, category, language);
    return data;
  }

  Future<ProgressModel> getVideoProgress(int categoryId, Locale locale) async {
    return await getProgress(db, categoryId, locale);
  }

  Future<List<CategoryClass>> getCategories() async {
    return await getAllCategories(db);
  }

  Future<void> updateTotalLength(Duration duration, String url) async {
    return await updateTotalVideoLength(db, duration, url);
  }

  Future<void> updateWatchTime(Duration duration, String url) async {
    return await updateVideoWatchTime(db, duration, url);
  }

}