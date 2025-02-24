import 'video_dto.dart';

class ChapterDTO {
  final int id;
  final int categoryId;
  final String title;
  List<VideoDTO> videos;

  ChapterDTO({required this.id, required this.categoryId, required this.title, this.videos = const []});

  factory ChapterDTO.fromMap(Map<String, dynamic> map) {
    return ChapterDTO(
      id: map['id'],
      categoryId: map['category_id'],
      title: map['title'],
      videos: (map['videos'] as List<dynamic>?)
          ?.map((videoMap) => VideoDTO.fromMap(videoMap))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'title': title,
      'videos': videos.map((video) => video.toMap()).toList(),
    };
  }
}