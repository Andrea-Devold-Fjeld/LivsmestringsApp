import 'package:livsmestringapp/dto/task_dto.dart';
import 'package:livsmestringapp/services/parse_duration.dart';

/// A data transfer object representing a video.
class VideoDto {
  final int? id;
  final int chapterId;
  final String title;
  final String url;
  final String? languageCode;
  bool watched;
  List<TaskDto> tasks;
  Duration? totalLength;
  Duration? watchedLength;

  VideoDto({
    this.id,
    required this.chapterId,
    required this.title,
    required this.url,
    this.languageCode,
    this.watched = false,
    this.tasks = const [],
    this.totalLength,
    this.watchedLength,
  });

  factory VideoDto.fromMap(Map<String, dynamic> map) {
    return VideoDto(
      id: map['id'],
      chapterId: map['chapter_id'],
      title: map['title'],
      url: map['url'],
      languageCode: map['language_code'] ?? 'en',
      watched: map['watched'] == 1,
      totalLength: map['total_length'] != null ? ParseDuration.parse(map['total_length']) : null,
      watchedLength: map['watched_length'] != null ?ParseDuration.parse(map['watched_length']): null,
      tasks: (map['tasks'] as List<dynamic>?)
          ?.map((taskMap) => TaskDto.fromMap(taskMap))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'chapter_id': chapterId,
      'title': title,
      'url': url,
      'language_code': languageCode,
      'watched': watched ? 1 : 0,
      'total_length': totalLength?.toString(),
      'watched_length': watchedLength?.toString(),
      'tasks': tasks.map((task) => task.toMap()).toList(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  double getVideoProgress() {
    if (watchedLength == null || totalLength == null) {
      return 0.0;
    }

    double progress = watchedLength!.inSeconds.toDouble() / totalLength!.inSeconds.toDouble();
    if (progress >= 0.95) {
      watched = true;
      return 1.0;
    }
    return progress;
  }
}
