class CategoryClass {
  final String name;
  final int id;

  CategoryClass({
    required this.name,
    required this.id,
  });

  static CategoryClass fromMap(Map<String, dynamic> map) {
    return CategoryClass(
      name: map['name'] ?? '',
      id: map['id'],
    );
  }
}