import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/models/product.dart';
import 'package:my_heb_clone/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'add_to_cart_button.dart';

class ProductViewCart extends StatelessWidget {
  final Product product;

  const ProductViewCart({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var quantity =
        context.watch<UserProvider>().numberOfProductInShoppingCart(product.id);
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: 32),
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        width: 20.w,
                        child: Image.asset(
                          'assets/grocery_images/${product.imageId}',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 64),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        SizedBox(height: 48),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(product.friendlyPrice),
                            Text(
                              '\$${(product.price * quantity).toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.25),
                  borderRadius: BorderRadius.circular(25),
                ),
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 1.h, bottom: 1.h, right: 10.w),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: selectedGrey,
                            width: 0.25,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.circle_outlined, size: 20),
                          SizedBox(width: 2.w),
                          Text('Allow substitution')
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        children: [
                          Icon(Icons.text_snippet_outlined, size: 20),
                          SizedBox(width: 2.w),
                          Text('Add instructions')
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Divider(),
            ],
          ),
        ),
        Positioned(
          bottom: 12.7.h,
          right: 33.w,
          child: AddToCartButton(product: product),
        ),
      ],
    );
  }
}
