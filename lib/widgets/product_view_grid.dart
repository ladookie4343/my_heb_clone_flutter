import 'package:flutter/material.dart';
import 'package:my_heb_clone/models/product.dart';
import 'package:my_heb_clone/widgets/product_description.dart';
import 'package:sizer/sizer.dart';

import 'add_to_cart_button.dart';

class ProductViewGrid extends StatelessWidget {
  final Product product;

  const ProductViewGrid({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                width: 50.w,
                child: Image.asset(
                  'assets/grocery_images/${product.imageId}',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            ProductDescription(product: product),
          ],
        ),
        Align(
          child: AddToCartButton(product: product), //Icon(Icons.stars),
          alignment: Alignment(.9, 0.3),
        ),
      ],
    );
  }
}
