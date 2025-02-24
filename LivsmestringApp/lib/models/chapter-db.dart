import 'video-db.dart';

class Chapter {
  final int? id;
  final int categoryId;
  final String title;
  List<Video> videos;

  Chapter({this.id, required this.categoryId, required this.title, this.videos = const []});

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'],
      categoryId: map['category_id'],
      title: map['title'],
      videos: (map['videos'] as List<dynamic>?)
          ?.map((videoMap) => Video.fromMap(videoMap))
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