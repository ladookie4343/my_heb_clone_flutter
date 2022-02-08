import 'product.dart';
import 'type.dart';

class Category {
  final String id;
  final String title;
  final String departmentId;
  List<Type> types = [];
  List<Product> products = [];

  Category(this.id, this.title, this.departmentId);

  static List<Category> parseCategories(Map<String, dynamic> jsonObjects) {
    return jsonObjects.keys
        .map((key) => Category(
              key,
              jsonObjects[key]['title'],
              jsonObjects[key]['department_id'],
            ))
        .toList();
  }
}
