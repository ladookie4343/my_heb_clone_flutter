import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:my_heb_clone/models/day_availability.dart';
import 'package:my_heb_clone/models/cart_item.dart';
import 'package:my_heb_clone/models/order.dart';
import 'package:my_heb_clone/models/shopping_method.dart';
import 'package:my_heb_clone/models/store.dart';

import 'auth.dart';
import 'product.dart';

class User {
  String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  String? phoneNumber;
  final bool optIn;
  Auth? auth;
  ShoppingMethod? shoppingMethod;
  Store? store;
  DateTime? timeSlot;
  List<String>? recentSearches;
  Map<String, CartItem> shoppingCart = {};
  final List<Order> orders;

  User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.phoneNumber,
    required this.optIn,
    this.auth,
    this.shoppingMethod,
    this.store,
    this.timeSlot,
    this.recentSearches,
    required this.shoppingCart,
    required this.orders,
  });

  set idFromServer(id) {
    id = id;
  }

  String get friendlyTimeSlotString =>
      '${friendlyDayString(timeSlot!)}, ${friendlyTimeRangeString(timeSlot!)}';

  String getShoppingMethodFriendlyString() {
    switch (shoppingMethod) {
      case ShoppingMethod.inStore:
        return 'In-store at';
      case ShoppingMethod.curbside:
        return 'Curbside at';
      case ShoppingMethod.delivery:
        return 'Delivery to';
      default:
        return '';
    }
  }

  int getShoppingMethodTabIndex() {
    switch (shoppingMethod) {
      case ShoppingMethod.curbside:
        return 0;
      case ShoppingMethod.delivery:
        return 1;
      case ShoppingMethod.inStore:
        return 2;
      default:
        return 0;
    }
  }

  void addProductToShoppingCart(Product product) {
    if (shoppingCart.containsKey(product.id)) {
      shoppingCart[product.id]!.incrementQuantity();
    } else {
      shoppingCart[product.id] =
          CartItem(productId: product.id, product: product);
    }
  }

  int removeProductFromShoppingCart(Product product) {
    String productId = product.id;
    if (shoppingCart.containsKey(productId)) {
      shoppingCart[productId]!.decrementQuantity();
      return shoppingCart[productId]!.quantity;
    } else {
      throw Exception(
          'Removing non-existent product from shopping cart: $productId');
    }
  }

  void emptyShoppingCart() {
    shoppingCart.clear();
  }

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
      id: parsedJson['id'],
      firstName: parsedJson['firstName'],
      lastName: parsedJson['lastName'],
      email: parsedJson['email'],
      password: 'password',
      optIn: parsedJson['optIn'],
      phoneNumber: parsedJson['phoneNumber'],
      shoppingMethod: EnumToString.fromString(
          ShoppingMethod.values, parsedJson['shoppingMethod']),
      auth: Auth.fromJson(parsedJson['auth'], isRefresh: false),
      store: Store.fromJson(parsedJson['store']),
      recentSearches: List.from(parsedJson['recentSearches']),
      timeSlot: parsedJson['timeSlot'] != null
          ? DateTime.parse(parsedJson['timeSlot'])
          : null,
      shoppingCart: parsedJson['shoppingCart'] != null
          ? json.decode(parsedJson['shoppingCart'])
          : null,
      orders: parsedJson['orders'] == null
          ? []
          : Order.parseOrders(parsedJson['orders']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'optIn': optIn,
        'shoppingMethod': EnumToString.convertToString(shoppingMethod),
        'timeSlot': timeSlot?.toIso8601String(),
        'store': store,
        'auth': auth,
        'recentSearches': recentSearches,
        'shoppingCart': json.encode(shoppingCart),
      };
}
