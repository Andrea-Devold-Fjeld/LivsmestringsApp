import '../services/parse_duration.dart';

class TaskDto {
  final int? id;
  final int videoId;
  final String title;
  final String url;
  final String? languageCode;
  Duration? totalLength;
  Duration? watchedLength;
  bool watched;

  TaskDto({
    this.id,
    required this.videoId,
    required this.title,
    required this.url,
    this.languageCode,
    this.totalLength,
    this.watchedLength,
    this.watched = false,
  });

  factory TaskDto.fromMap(Map<String, dynamic> map) {
    return TaskDto(
      id: map['id'],
      videoId: map['video_id'],
      title: map['title'],
      url: map['url'],
      languageCode: map['language_code'] ?? 'en',
      totalLength: ParseDuration.parse(map['total_length']),
      watchedLength: ParseDuration.parse(map['watched_length']),
      watched: map['watched'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'video_id': videoId,
      'title': title,
      'url': url,
      'language_code': languageCode,
      'watched': watched ? 1 : 0,
      'total_length': totalLength?.toString(),
      'watched_length': watchedLength?.toString(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  double getTaskProgress() {
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