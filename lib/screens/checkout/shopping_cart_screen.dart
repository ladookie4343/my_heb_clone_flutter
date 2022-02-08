import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/models/day_availability.dart';
import 'package:my_heb_clone/models/product.dart';
import 'package:my_heb_clone/providers/user_provider.dart';
import 'package:my_heb_clone/screens/checkout/checkout_screen.dart';
import 'package:my_heb_clone/widgets/check_option.dart';
import 'package:my_heb_clone/screens/checkout/estimated_total.dart';
import 'package:my_heb_clone/widgets/heb_alert_dialog.dart';
import 'package:my_heb_clone/widgets/heb_app_bar.dart';
import 'package:my_heb_clone/widgets/pill_button.dart';
import 'package:my_heb_clone/widgets/product_view_cart.dart';
import 'package:my_heb_clone/widgets/store_configuration_header.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../home/curbside_time_selection_screen.dart';

class ShoppingCartScreen extends StatelessWidget {
  const ShoppingCartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var userProvider = context.watch<UserProvider>();
    var shoppingCart = userProvider.user!.shoppingCart;
    var products = shoppingCart.values
        .where((item) => item.quantity > 0)
        .map((e) => e.product)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(
        context,
        title: StoreConfigurationHeader(user: userProvider.user!),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.close),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: PillButton(
        color: accentColor,
        onPressed: () async {
          if (products.length > 0) {
            if (userProvider.user?.timeSlot == null) {
              Navigator.of(context).push<TimeSlot>(
                MaterialPageRoute(
                  builder: (_) => CurbsideTimeSelectionScreen(
                    fromShoppingCart: true,
                    store: userProvider.user!.store!,
                  ),
                ),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CheckoutScreen())
              );
            }
          } else {
            Navigator.of(context).pop();
          }
        },
        child: Text(products.length > 0 ? 'Start checkout' : 'Start shopping'),
        fullWidth: true,
      ),
      body: products.length > 0
          ? _buildShoppingCart(context, products, userProvider)
          : _buildEmptyCartView(context)
    );
  }

  Widget _buildShoppingCart(BuildContext context, List<Product?> products,
      UserProvider userProvider) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CheckOption(
              description:
                  'Substitute all out-of-stock items with a similar item',
              value: true,
              onChanged: (value) {},
            ),
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Pantry',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          ...products.map((p) => ProductViewCart(product: p!)).toList(),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: EstimatedTotal(),
          ),
          Center(
            child: GestureDetector(
              onTap: () async {
                var isConfirmed = await _showDialog(context) ?? false;
                if (isConfirmed) {
                  userProvider.emptyShoppingCart();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: .25.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline_sharp, size: 16),
                    SizedBox(width: 10),
                    Text(
                      'Empty Cart',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEmptyCartView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0),
        child: Column(
          children: [
            SizedBox(height: 30.h),
            Icon(Icons.shopping_cart, size: 48, color: unselectedGrey),
            SizedBox(height: 2.h,),
            Text(
              "Your cart is empty. Once you add items, we'll keep track of them here.",
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showDialog(BuildContext context) {
    return showDialog<bool?>(
      context: context,
      builder: (context) => HebAlertDialog(
        title: 'Empty your cart?',
        content: 'This will remove all items from  your cart',
        actions: [
          HebAlertDialogButton(
            title: 'CANCEL',
            isPrimary: false,
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          HebAlertDialogButton(
            title: 'EMPTY',
            isPrimary: true,
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }
}
