import 'package:my_heb_clone/models/category.dart';

class Department {
  final String id;
  final String title;
  List<Category> categories = [];

  Department(this.id, this.title);

  Category getCategory(String categoryId) {
    return categories.firstWhere((category) => category.id == categoryId);
  }

  @override
  String toString() {
    return title;
  }

  static List<Department> parseDepartments(Map<String, dynamic> jsonObjects) {
    return jsonObjects.keys
        .map((key) => Department(key, jsonObjects[key]['title']))
        .toList();
  }
}
