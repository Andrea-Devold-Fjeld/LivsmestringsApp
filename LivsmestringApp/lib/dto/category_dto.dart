import 'chapter_dto.dart';

class CategoryDTO {
  final int id;
  final String name;
  List<ChapterDTO> chapters;

  CategoryDTO({required this.id, required this.name, this.chapters = const []});

  factory CategoryDTO.fromMap(Map<String, dynamic> map) {
    return CategoryDTO(
      id: map['id'],
      name: map['name'],
      chapters: (map['chapters'] as List<dynamic>?)
          ?.map((chapterMap) => ChapterDTO.fromMap(chapterMap))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'chapters': chapters.map((chapter) => chapter.toMap()).toList(),
    };
  }
}