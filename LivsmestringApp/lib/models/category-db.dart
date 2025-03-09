import 'chapter-db.dart';

class Category {
  final int? id;
  final String name;
  List<ChapterDto> chapters;

  Category({this.id, required this.name, this.chapters = const []});

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
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