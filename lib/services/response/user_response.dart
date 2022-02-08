import 'package:my_heb_clone/models/cart_item.dart';
import 'package:my_heb_clone/models/order.dart';

class UserResponse {
  final String email;
  final String firstName;
  final String lastName;
  final bool optIn;
  final String? phoneNumber;
  final String shopType;
  final String storeId;
  final DateTime? timeSlot;
  List<CartItem> cartItems = [];
  List<Order> orders = [];

  UserResponse({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.optIn,
    this.phoneNumber,
    required this.shopType,
    required this.storeId,
    required this.timeSlot,
    required this.cartItems,
    required this.orders,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      optIn: json['optIn'],
      shopType: json['shopType'],
      storeId: json['storeId'],
      timeSlot:
      json['timeSlot'] != null ? DateTime.parse(json['timeSlot']) : null,
      cartItems: json['cart'] != null
          ? List<CartItem>.from(
          json['cart'].map((e) => CartItem.fromJson(e)).toList())
          : [],
      orders: Order.parseOrders(json['orders'])
    );
  }
}
