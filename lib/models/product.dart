import 'dart:math';

class Product {
  final String id;
  final String title;
  final double price;
  final int? forQuantity;
  final String priceType;
  final String? unitPrice;
  final String imageId;
  final String? typeId;
  final String categoryId;

  Product({
    required this.id,
    required this.title,
    required this.price,
    this.forQuantity,
    required this.priceType,
    this.unitPrice,
    required this.imageId,
    this.typeId,
    required this.categoryId,
  });

  String get friendlyPrice => '\$${price.toStringAsFixed(2)} / $priceType';

  static const images = [
    'asparagus-bunch-000319073.jpg',
    'fresh-kiku-apples-001550047.jpg',
    'fresh-organic-bartlett-pears-000529733.jpg',
    'h-e-b-mild-guacamole-001281062.jpg',
    'h-e-b-original-bacon-001475819.jpg',
    'h-e-b-premium-white-grapes-003835007.jpg',
    'h-e-b-select-ingredients-mexican-style-cheese-thick-shredded-002197067.jpg',
    'nestle-toll-house-chocolate-chip-lovers-cookie-dough-000573265.jpg',
  ];

  static final _random = Random();

  static List<Product> parseProducts(Map<String, dynamic> jsonObjects) {
    return jsonObjects.keys
        .map((key) => Product(
              id: key,
              title: jsonObjects[key]['title'],
              price: jsonObjects[key]['price'],
              forQuantity: jsonObjects[key]['for_quantity'],
              priceType: jsonObjects[key]['price_type'],
              unitPrice: jsonObjects[key]['unit_price'],
              imageId: images[0 + _random.nextInt(images.length)],
              typeId: jsonObjects[key]['type_id'],
              categoryId: jsonObjects[key]['category_id'],
            ))
        .toList();
  }

  factory Product.fromJson(Map<String, dynamic> json, String id) {
    return Product(
      id: id,
      title: json['title'],
      price: json['price'],
      forQuantity: json['for_quantity'],
      priceType: json['price_type'],
      unitPrice: json['unit_price'],
      imageId: images[0 + _random.nextInt(images.length)],
      typeId: json['type_id'],
      categoryId: json['category_id'],
    );
  }
}
