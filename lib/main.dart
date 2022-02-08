import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/models/cart_item.dart';
import 'package:my_heb_clone/models/order.dart';
import 'package:my_heb_clone/providers/products_provider.dart';
import 'package:my_heb_clone/providers/stores_provider.dart';
import 'package:my_heb_clone/providers/user_provider.dart';
import 'package:my_heb_clone/screens/bottom_tab_bar.dart';
import 'package:my_heb_clone/screens/login_signup/how_to_shop_screen.dart';
import 'package:my_heb_clone/screens/login_signup/intro_screen.dart';
import 'package:my_heb_clone/screens/login_signup/login_screen.dart';
import 'package:my_heb_clone/screens/login_signup/sign_up_screen.dart';
import 'package:my_heb_clone/screens/login_signup/store_finder_screen.dart';
import 'package:my_heb_clone/screens/orders/order_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final productsProvider = ProductsProvider();
  final userProvider = UserProvider();
  final storesProvider = StoresProvider();

  // fetch data and try login while loading screen is up.
  try {
    await productsProvider.fetchDepartments();
    await productsProvider.fetchAllProducts();
    await storesProvider.fetchStores();
    await userProvider.tryAutoLogin();
  } catch (ex) {
    print(ex);
  }

  var multiProvider = MultiProvider(
    providers: [
      Provider(create: (_) => productsProvider),
      Provider(create: (_) => storesProvider),
      ChangeNotifierProvider(create: (_) => userProvider),
    ],
    child: HebApp(),
  );

  runApp(multiProvider);
}

class HebApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => AnnotatedRegion(
        value: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        child: MaterialApp(
          title: 'H-E-B',
          theme: ThemeData(
            primaryColor: hebRed,
            disabledColor: accentColorDisabled,
            textTheme: TextTheme(
              headline4: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: selectedGrey,
              ),
              headline5: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: selectedGrey,
              ),
              headline6: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: selectedGrey,
              ),
              subtitle1: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: selectedGrey,
              ),
              subtitle2: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: selectedGrey,
              ),
              bodyText1: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: selectedGrey,
              ),
              bodyText2: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: selectedGrey,
              ),
            ),
          ),
          routes: {
            SignUpScreen.routeName: (context) => SignUpScreen(),
            LoginScreen.routeName: (context) => LoginScreen(),
            HowToShopScreen.routeName: (context) => HowToShopScreen(),
            StoreFinderScreen.routeName: (context) => StoreFinderScreen(),
            IntroScreen.routeName: (context) => IntroScreen(),
            BottomTabBar.routeName: (context) => BottomTabBar(),
            OrderDetailsScreen.routeName: (context) => OrderDetailsScreen(
                  order: Order(
                    id: '-Mr8SWmpZAIyMIzldKLP',
                    items: [
                      CartItem(
                        productId: '-MjvvpRWX2tc-8huf7Ma',
                        quantity: 1,
                      )
                    ],
                    cancelled: false,
                    pickupTime: DateTime.now(),
                    createdDate: DateTime.now().subtract(Duration(hours: 12)),
                    storeId: '24',
                  ),
                ),
          },
          home: context.read<UserProvider>().user != null
              ? BottomTabBar()
              : IntroScreen(),
          // initialRoute: OrderDetailsScreen.routeName,
        ),
      ),
    );
  }
}
