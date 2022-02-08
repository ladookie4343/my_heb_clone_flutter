import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/providers/user_provider.dart';
import 'package:provider/provider.dart';

class EstimatedTotal extends StatelessWidget {
  static final _oCcy = NumberFormat('#,##0.00', 'en_US');
  final bool showTax;

  const EstimatedTotal({Key? key, this.showTax = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.bodyText1;
    var userProvider = context.read<UserProvider>();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtotal (${userProvider.totalNumberOfProductsInShoppingCart} item${userProvider.totalNumberOfProductsInShoppingCart > 1 ? 's' : ''})**',
              style: textStyle,
            ),
            Text(
              '\$${_oCcy.format(userProvider.totalPriceOfShoppingCart)}',
              style: textStyle,
            )
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Curbside Fee',
              style: textStyle,
            ),
            Text(
              'FREE',
              style: textStyle,
            )
          ],
        ),
        if (showTax) ...[
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated tax',
                style: textStyle,
              ),
              Text(
                '\$0.00',
                style: textStyle,
              )
            ],
          )
        ],
        Divider(
          color: Colors.black,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Estimated total',
              style: textStyle?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${_oCcy.format(userProvider.totalPriceOfShoppingCart)}',
              style: textStyle?.copyWith(fontWeight: FontWeight.bold),
            )
          ],
        ),
        SizedBox(height: 36),
        Center(
          child: Text(
            '** Prices may vary from in-store prices, and based on\nsubstitutions and final weight of some items.',
            textAlign: TextAlign.center,
            style: TextStyle(color: unselectedGrey),
          ),
        ),
        SizedBox(height: 36),
      ],
    );
  }
}
