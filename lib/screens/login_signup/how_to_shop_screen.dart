import 'package:flutter/material.dart';
import 'package:my_heb_clone/models/shopping_method.dart';
import 'package:my_heb_clone/providers/user_provider.dart';
import 'package:my_heb_clone/screens/login_signup/store_finder_screen.dart';
import 'package:provider/provider.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:sizer/sizer.dart';

class HowToShopScreen extends StatelessWidget {
  static const routeName = 'how-to-shop';

  const HowToShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: hebRed,
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          width: screenSize.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    EdgeInsets.only(left: 20.w, right: 20.w, bottom: 2.5.h),
                child: Text(
                  'How do you want to shop today?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                "Tell us how you're shopping to see what's available. You can always change this later.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5.h),
              _buildShoppingMethodButton(
                context,
                'curbside.png',
                'Curbside',
                'We prepare your order, you pick it up',
                ShoppingMethod.curbside,
              ),
              SizedBox(height: 3.h),
              _buildShoppingMethodButton(
                context,
                'delivery.png',
                'Delivery',
                'Everything on your list, delivered',
                ShoppingMethod.delivery,
              ),
              SizedBox(height: 3.h),
              _buildShoppingMethodButton(
                context,
                'in_store.png',
                'In-store',
                'Shop in-store with lists and coupons',
                ShoppingMethod.inStore,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShoppingMethodButton(
    BuildContext context,
    String imageFilename,
    String title,
    String description,
    ShoppingMethod shoppingMethod,
  ) {
    return InkWell(
      onTap: () {
        context.read<UserProvider>().updateShoppingMethod(shoppingMethod);
        Navigator.of(context).pushNamed(StoreFinderScreen.routeName);
      },
      child: Container(
        padding: EdgeInsets.all(1.25.w),
        width: MediaQuery.of(context).size.width,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Image.asset('assets/images/$imageFilename'),
            SizedBox(
              width: 8,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyText1,
                  )
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 2.h,
            ),
            SizedBox(
              width: 2.w,
            )
          ],
        ),
      ),
    );
  }
}
