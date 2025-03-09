import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'DataModel.dart';
import 'chapter-db.dart';


class DatamodelDto {
  final List<ChapterDto> chapters;
  final String category;

  DatamodelDto({required this.chapters, required this.category});

}

/*
@JsonSerializable()
class DatamodelDTO {
  final int id;
  @JsonKey(name: 'Chapters')
  final String category;
  List<ChapterDTO> chapters;
  final int totalVideos;
  int watchedVideos;
  double progress;

  DatamodelDTO({
    required this.id,
    required this.chapters,
    required this.category,
    required this.totalVideos,
    required this.watchedVideos,
    required this.progress,
  });

  factory DatamodelDTO.fromJson(Map<String, dynamic> json, String category, {int? id}) {
    final modelId = id ?? json['id'] ?? DateTime.now().millisecondsSinceEpoch;

    List<ChapterDTO> chapterDTOs = [];
    if (json['chapters'] != null) {
      chapterDTOs = (json['chapters'] as List)
          .map((chapter) => ChapterDTO.fromJson(chapter))
          .toList();
    }

    int totalVideosCount = json['totalVideos'] ?? _calculateTotalVideos(chapterDTOs);
    int watchedVideosCount = json['watchedVideos'] ?? _calculateWatchedVideos(chapterDTOs);
    double progressValue = json['progress'] ?? (totalVideosCount > 0 ? watchedVideosCount / totalVideosCount : 0.0);

    return DatamodelDTO(
      id: modelId,
      chapters: chapterDTOs,
      category: category,
      totalVideos: totalVideosCount,
      watchedVideos: watchedVideosCount,
      progress: progressValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'Chapters': chapters.map((chapter) => chapter.toJson()).toList(),
      'totalVideos': totalVideos,
      'watchedVideos': watchedVideos,
      'progress': progress,
    };
  }

  void updateProgress() {
    watchedVideos = _calculateWatchedVideos(chapters);
    progress = totalVideos > 0 ? watchedVideos / totalVideos : 0.0;
  }

  Datamodel toDatamodel() {
    Datamodel model = Datamodel(
      chapters: chapters.map((chapterDTO) => chapterDTO.toChapter()).toList(),
      category: category,
    );
    return model;
  }

  static int _calculateTotalVideos(List<ChapterDTO> chapters) {
    var count = 0;
    for (var c in chapters) {
      count += c.videos.length;
      for (var v in c.videos) {
        count += v.tasks?.length ?? 0;
      }
    }
    return count;
  }

  static int _calculateWatchedVideos(List<ChapterDTO> chapters) {
    var count = 0;
    for (var c in chapters) {
      for (var v in c.videos) {
        if (v.watched) count++;
        v.tasks?.forEach((t) {
          if (t.watched) count++;
        });
      }
    }
    return count;
  }

  // Query methods
  VideoDTO? findVideoById(int videoId) {
    for (var chapter in chapters) {
      for (var video in chapter.videos) {
        if (video.id == videoId) {
          return video;
        }
      }
    }
    return null;
  }

  TaskDTO? findTaskById(int taskId) {
    for (var chapter in chapters) {
      for (var video in chapter.videos) {
        if (video.tasks != null) {
          for (var task in video.tasks!) {
            if (task.id == taskId) {
              return task;
            }
          }
        }
      }
    }
    return null;
  }

  ChapterDTO? findChapterById(int chapterId) {
    try {
      return chapters.firstWhere((chapter) => chapter.id == chapterId);
    } catch (e) {
      return null;
    }
  }

  ChapterDTO? findChapterByVideoId(int videoId) {
    for (var chapter in chapters) {
      for (var video in chapter.videos) {
        if (video.id == videoId) {
          return chapter;
        }
      }
    }
    return null;
  }

  VideoDTO? findVideoByUrl(String url) {
    for (var chapter in chapters) {
      for (var video in chapter.videos) {
        if (video.url == url) {
          return video;
        }
      }
    }
    return null;
  }

  TaskDTO? findTaskByUrl(String url) {
    for (var chapter in chapters) {
      for (var video in chapter.videos) {
        if (video.tasks != null) {
          for (var task in video.tasks!) {
            if (task.url == url) {
              return task;
            }
          }
        }
      }
    }
    return null;
  }

  List<VideoDTO> findUnwatchedVideos() {
    List<VideoDTO> result = [];
    for (var chapter in chapters) {
      for (var video in chapter.videos) {
        if (!video.watched) {
          result.add(video);
        }
      }
    }
    return result;
  }

  List<TaskDTO> findUnwatchedTasks() {
    List<TaskDTO> result = [];
    for (var chapter in chapters) {
      for (var video in chapter.videos) {
        if (video.tasks != null) {
          for (var task in video.tasks!) {
            if (!task.watched) {
              result.add(task);
            }
          }
        }
      }
    }
    return result;
  }
}

class ChapterDTO {
  final int id;
  final String title;
  List<VideoDTO> videos;

  ChapterDTO({
    required this.id,
    required this.title,
    required this.videos,
  });


  factory ChapterDTO.fromJson(Map<String, dynamic> json) {

    return ChapterDTO(
      id: json['id'],
      title: json['yitle'],
      videos: (json['videos'] as List)
          .map((video) => VideoDTO.fromJson(video))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'videos': videos.map((video) => video.toJson()).toList(),
    };
  }

  Chapter toChapter() {
    return Chapter(
      title: title,
      videos: videos.map((videoDTO) => videoDTO.toVideo()).toList(),
    );
  }
}

class VideoDTO {
  final int id;
  final String title;
  final String url;
  final List<TaskDTO>? tasks;
  String? languageCode;
  Duration? totalLength;
  Duration? watchedLength;
  bool watched;

  VideoDTO({
    required this.id,
    required this.title,
    required this.url,
    this.tasks,
    this.languageCode,
    this.totalLength,
    this.watchedLength,
    required this.watched,
  });


  factory VideoDTO.fromJson(Map<String, dynamic> json) {
    return VideoDTO(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      tasks: json['tasks'] != null
          ? (json['tasks'] as List)
          .map((task) => TaskDTO.fromJson(task))
          .toList()
          : null,
      languageCode: json['language_code'],
      totalLength: json['total_length'],
      watchedLength: json['watched_length'],
      watched: json['watched'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'tasks': tasks?.map((task) => task.toJson()).toList(),
      'language_code': languageCode,
      'total_length': totalLength,
      'watched_length': watchedLength,
      'watched': watched,
    };
  }

  Video toVideo() {
    Video video = Video(
      title: title,
      url: url,
      tasks: tasks?.map((taskDTO) => taskDTO.toTask()).toList(),
      languageCode: languageCode,
      totalLength: totalLength,
      watchedLength: watchedLength,
    );
    video.watched = watched;
    return video;
  }

}

class TaskDTO {
  final int id;
  final String title;
  final String url;
  bool watched;

  TaskDTO({
    required this.id,
    required this.title,
    required this.url,
    required this.watched,
  });


  factory TaskDTO.fromJson(Map<String, dynamic> json) {
    return TaskDTO(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      watched: json['watched'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'watched': watched,
    };
  }

  Task toTask() {
    Task task = Task(
      title: title,
      url: url,
    );
    task.watched = watched;
    return task;
  }
}

 */