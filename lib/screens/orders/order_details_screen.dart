import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/models/order.dart';
import 'package:sizer/sizer.dart';

class OrderDetailsScreen extends StatelessWidget {
  static const routeName = '/order-details';

  final Order order;

  const OrderDetailsScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: hebRed,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.help, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/images/shopping_bag.png',
                  width: 136,
                  height: 136,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order picked up.\nThank you!',
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Order #HEB${order.id}',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 1.h),
                  ],
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Card(
              child: Container(
                width: 100.w,
                child: Stack(
                  children: [

                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
