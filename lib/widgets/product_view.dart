import 'package:flutter/material.dart';
import 'package:my_heb_clone/models/product.dart';
import 'package:my_heb_clone/widgets/product_description.dart';

import 'add_to_cart_button.dart';

class ProductView extends StatelessWidget {
  final Product product;

  const ProductView({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      width: 160,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                width: 160,
                child: Image.asset('assets/grocery_images/${product.imageId}'),
              ),
              ProductDescription(product: product),
            ],
          ),
          Align(
            child: AddToCartButton(product: product), //Icon(Icons.stars),
            alignment: Alignment(.9, 0),
          ),
        ],
      ),
    );
  }
}
