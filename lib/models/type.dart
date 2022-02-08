import 'product.dart';

class Type {
  final String id;
  final String title;
  final String categoryId;

  final List<Product> products = [];

  Type(this.id, this.title, this.categoryId);

  static List<Type> parseTypes(Map<String, dynamic> jsonObjects) {
    return jsonObjects.keys
        .map((key) => Type(
              key,
              jsonObjects[key]['title'],
              jsonObjects[key]['category_id'],
            ))
        .toList();
  }
}
