import 'chapter_dto.dart';

class CategoryDto {
  final int? id;
  final String name;
  List<ChapterDto> chapters;
  late final int _totalVideos;
  late int _watchedVideos;
  late double _progress;

  CategoryDto({
    this.id,
    required this.name,
    this.chapters = const [],
  }) {
    _totalVideos = _calculateTotalVideos();
    _watchedVideos = _calculateWatchedVideos();
    _progress = _totalVideos > 0 ? _watchedVideos / _totalVideos : 0.0;
  }

  int _calculateTotalVideos() {
    var count = 0;
    for (var chapter in chapters) {
      count += chapter.videos.length;
      for (var video in chapter.videos) {
        count += video.tasks.length;
      }
    }
    return count;
  }

  int _calculateWatchedVideos() {
    var count = 0;
    for (var chapter in chapters) {
      for (var video in chapter.videos) {
        if (video.watched) count++;
        for (var task in video.tasks) {
          if (task.watched) count++;
        }
      }
    }
    return count;
  }

  double get progress => _progress;

  factory CategoryDto.fromMap(Map<String, dynamic> map) {
    return CategoryDto(
      id: map['id'],
      name: map['name'],
      chapters: (map['chapters'] as List<dynamic>?)
          ?.map((chapterMap) => ChapterDto.fromMap(chapterMap))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'chapters': chapters.map((chapter) => chapter.toMap()).toList(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}