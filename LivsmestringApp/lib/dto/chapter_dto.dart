
import 'package:livsmestringapp/dto/video_dto.dart';

class ChapterDto {
  final int? id;
  final int categoryId;
  final String title;
  List<VideoDto> videos;

  ChapterDto({
    this.id,
    required this.categoryId,
    required this.title,
    this.videos = const [],
  });

  factory ChapterDto.fromMap(Map<String, dynamic> map) {
    return ChapterDto(
      id: map['id'],
      categoryId: map['category_id'],
      title: map['title'],
      videos: (map['videos'] as List<dynamic>?)
          ?.map((videoMap) => VideoDto.fromMap(videoMap))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'category_id': categoryId,
      'title': title,
      'videos': videos.map((video) => video.toMap()).toList(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}