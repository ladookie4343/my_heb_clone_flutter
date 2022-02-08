import 'package:flutter/material.dart';
import 'package:my_heb_clone/models/product.dart';

class ProductDescription extends StatelessWidget {
  final Product product;

  const ProductDescription({required this.product, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          product.friendlyPrice,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        SizedBox(
          height: 40,
          child: Text(product.title,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(fontSize: 12)),
        ),
      ],
    );
  }
}
