import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:my_heb_clone/models/order.dart';
import 'package:my_heb_clone/providers/user_provider.dart';
import 'package:my_heb_clone/screens/bottom_tab_bar.dart';
import 'package:my_heb_clone/screens/checkout/edit_phone_number_screen.dart';
import 'package:my_heb_clone/screens/checkout/place_order_button.dart';
import 'package:my_heb_clone/screens/home/store_configurator_screen.dart';
import 'package:my_heb_clone/screens/orders/order_details_screen.dart';
import 'package:my_heb_clone/widgets/checkout_edit_item.dart';
import 'package:my_heb_clone/screens/checkout/estimated_total.dart';
import 'package:my_heb_clone/widgets/heb_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class CheckoutScreen extends StatefulWidget {
  static final _oCcy = NumberFormat('#,##0.00', 'en_US');

  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var userProvider = context.watch<UserProvider>();
    var user = userProvider.user!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context, title: Text('Checkout')),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                CheckoutEditItem(
                  leading: Image.asset(
                    'assets/images/curbside.png',
                    width: 16,
                    height: 16,
                  ),
                  title: 'Curbside',
                  bodyWidgets: [
                    Text(
                      user.store!.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      user.friendlyTimeSlotString,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                  onChangePressed: () {
                    showMaterialModalBottomSheet(
                      context: context,
                      useRootNavigator: true,
                      builder: (context) => StoreConfiguratorScreen(),
                    );
                  },
                ),
                CheckoutEditItem(
                  leading: Icon(Icons.phone, size: 16),
                  title: 'Contact number',
                  bodyWidgets: [
                    Text(
                      user.phoneNumber ?? 'Please add a phone number.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: user.phoneNumber == null ? Colors.red : null,
                      ),
                    ),
                  ],
                  onChangePressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditPhoneNumberScreen(
                          initialValue: user.phoneNumber ?? '',
                        ),
                      ),
                    );
                  },
                ),
                CheckoutEditItem(
                  leading: Icon(Icons.shopping_cart, size: 16),
                  title: 'Order',
                  bodyWidgets: [
                    Text(
                      '${userProvider.totalNumberOfProductsInShoppingCart} items',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  stackItem: SizedBox(
                    height: 80,
                    width: 100.w,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        SizedBox(width: 10.w),
                        ...user.shoppingCart.values
                            .where((element) => element.quantity > 0)
                            .map((e) => Image.asset(
                                  'assets/grocery_images/${e.product?.imageId}',
                                  width: 48,
                                  height: 48,
                                ))
                            .take(10)
                            .expand((widget) => [widget, SizedBox(width: 10)]),
                        SizedBox(width: 3.w),
                      ],
                    ),
                  ),
                  stackItemHeight: 80,
                  onChangePressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CheckoutEditItem(
                  leading: Icon(Icons.attach_money_outlined, size: 16),
                  title: 'Payment methods',
                  bodyWidgets: [
                    Text(
                      'Visa 4286',
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Text(
                      '\$${userProvider.totalPriceOfShoppingCart}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  onChangePressed: () {},
                ),
                CheckoutEditItem(
                  leading: Icon(Icons.card_giftcard_outlined, size: 16),
                  title: 'Gift card',
                  bodyWidgets: [],
                  onChangePressed: () {},
                  onChangeTitle: 'Redeem',
                ),
                CheckoutEditItem(
                  leading: Icon(Icons.edit_outlined, size: 16),
                  title: 'Promo code',
                  bodyWidgets: [],
                  onChangePressed: () {},
                  onChangeTitle: 'Add code',
                ),
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: EstimatedTotal(showTax: true),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: 100.w,
              height: 40,
              color: Colors.white,
            ),
          ),
          if (_isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: PlaceOrderButton(
        price:
            '\$${CheckoutScreen._oCcy.format(userProvider.totalPriceOfShoppingCart)}',
        onPressed: () async {
          setState(() => _isLoading = true);
          var user = userProvider.user!;
          var order = await userProvider.submitOrder(
            Order(
              storeId: user.store!.id,
              createdDate: DateTime.now(),
              pickupTime: user.timeSlot!,
              cancelled: false,
              items: user.shoppingCart.values
                  .where((element) => element.quantity > 0)
                  .toList(),
            ),
          );
          setState(() => _isLoading = false);
          await showMaterialModalBottomSheet(
            context: context,
            useRootNavigator: true,
            builder: (context) => OrderDetailsScreen(order: order),
          );
          Navigator.of(context).pushReplacement(PageRouteBuilder(
            pageBuilder: (_, __, ___) => BottomTabBar(),
            transitionDuration: Duration.zero,
          ));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
