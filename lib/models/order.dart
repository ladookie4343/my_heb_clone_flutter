import 'package:my_heb_clone/models/cart_item.dart';

class Order {
  String? id;
  final String storeId;
  final DateTime createdDate;
  final DateTime pickupTime;
  final bool cancelled;
  final List<CartItem> items;

  Order({
    this.id,
    required this.storeId,
    required this.createdDate,
    required this.pickupTime,
    required this.cancelled,
    required this.items,
  });

  static List<Order> parseOrders(Map<String, dynamic>? jsonObjects) {
    if (jsonObjects == null) {
      return [];
    }
    return jsonObjects.keys
        .map((key) => Order(
              id: key,
              storeId: jsonObjects[key]['storeId'],
              createdDate: DateTime.parse(jsonObjects[key]['createdDate']),
              pickupTime: DateTime.parse(jsonObjects[key]['pickupTime']),
              cancelled: jsonObjects[key]['cancelled'],
              items: List<CartItem>.from(jsonObjects[key]['items']
                  .map((item) => CartItem.fromJson(item))
                  .toList()),
            ))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'createdDate': createdDate.toIso8601String(),
        'storeId': storeId,
        'pickupTime': pickupTime.toIso8601String(),
        'items': items,
        'cancelled': cancelled,
      };
}
