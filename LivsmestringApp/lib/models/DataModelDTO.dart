
/*
class DatamodelDto {
  final int? id;
  final String category;
  final List<ChapterDto> chapters;
  late final int _totalVideos;
  late int _watchedVideos;
  late double _progress;

  DatamodelDto({
    this.id,
    required this.category,
    required this.chapters,
  }) {
    _totalVideos = _calculateTotalVideos();
    _watchedVideos = _calculateWatchedVideos();
    _progress = _watchedVideos / (_totalVideos > 0 ? _totalVideos : 1);
  }

  int _calculateTotalVideos() {
    var count = 0;
    for (var chapter in chapters) {
      count += chapter.videos.length;
      for (var video in chapter.videos) {
        count += video.tasks?.length ?? 0;
      }
    }
    return count;
  }

  int _calculateWatchedVideos() {
    var count = 0;
    for (var chapter in chapters) {
      for (var video in chapter.videos) {
        if (video.watched) count++;
        video.tasks?.forEach((task) {
          if (task.watched) count++;
        });
      }
    }
    return count;
  }

  double get progress => _progress;
}

class ChapterDto {
  final int? id;
  final int categoryId;
  final String title;
  final List<VideoDto> videos;

  ChapterDto({
    this.id,
    required this.categoryId,
    required this.title,
    required this.videos,
  });
}

class VideoDto {
  final int? id;
  final int chapterId;
  final String title;
  final String url;
  final String? languageCode;
  bool watched;
  List<TaskDto>? tasks;
  Duration? totalLength;
  Duration? watchedLength;

  VideoDto({
    this.id,
    required this.chapterId,
    required this.title,
    required this.url,
    this.languageCode,
    this.watched = false,
    this.tasks,
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
      totalLength: _parseDuration(map['total_length']),
      watchedLength: _parseDuration(map['watched_length']),
      tasks: null, // Will be populated separately
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
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  double getVideoProgress() {
    if (watchedLength == null || totalLength == null) {
      return 0.0;
    } else {
      double progress = (watchedLength!.inSeconds.toDouble() / totalLength!.inSeconds.toDouble());
      if (progress >= 0.95) {
        watched = true;
        return 1.0;
      } else {
        return progress;
      }
    }
  }
}

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
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
  double getTaskProgress() {
    if (watchedLength == null || totalLength == null) {
      return 0.0;
    } else {
      double progress = (watchedLength!.inSeconds.toDouble() / totalLength!.inSeconds.toDouble());
      if (progress >= 0.95) {
        watched = true;
        return 1.0;
      } else {
        return progress;
      }
    }
  }
}

// Helper function to parse duration strings
Duration? _parseDuration(String? durationStr) {
  if (durationStr == null) return null;

  try {
    final parts = durationStr.split(':');
    if (parts.length == 3) {
      return Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
        seconds: int.parse(parts[2]),
      );
    } else if (parts.length == 2) {
      return Duration(
        minutes: int.parse(parts[0]),
        seconds: int.parse(parts[1]),
      );
    } else {
      return Duration(seconds: int.parse(durationStr));
    }
  } catch (e) {
    return null;
  }
}

 */