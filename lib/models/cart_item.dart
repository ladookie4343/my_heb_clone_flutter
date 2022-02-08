import 'product.dart';

class CartItem {
  final String productId;
  Product? product;
  int _quantity = 1;

  int get quantity => _quantity;

  double get totalPrice => product?.price ?? 0.0 * _quantity;

  CartItem({required this.productId, quantity = 1, this.product})
      : _quantity = quantity;

  void incrementQuantity() {
    _quantity++;
  }

  void decrementQuantity() {
    if (_quantity <= 0) return;
    _quantity--;
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': _quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      quantity: json['quantity'],
    );
  }
}
