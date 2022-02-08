import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/providers/user_provider.dart';

import 'package:my_heb_clone/screens/account/account_screen.dart';
import 'package:my_heb_clone/screens/coupons/coupons_screen.dart';
import 'package:my_heb_clone/screens/home/home_screen.dart';
import 'package:my_heb_clone/screens/orders/orders_screen.dart';
import 'package:my_heb_clone/screens/shop/shop_screen.dart';
import 'package:my_heb_clone/screens/checkout/shopping_cart_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../utils.dart';

class BottomTabBar extends StatefulWidget {
  static const String routeName = 'main';

  BottomTabBar({Key? key}) : super(key: key);

  @override
  State<BottomTabBar> createState() => _BottomTabBarState();
}

class _BottomTabBarState extends State<BottomTabBar> {
  final List<Widget> _screens = [
    HomeScreen(),
    ShopScreen(),
    CouponsScreen(),
    OrdersScreen(),
    AccountScreen(),
  ];

  int _currentIndex = 0;
  CupertinoTabController _controller = CupertinoTabController();
  final _fabKey = GlobalKey();
  Rect? _fabRect;
  Rect? _pageTransitionRect;
  late int _numberOfItemsInCart;

  @override
  void initState() {
    _controller.addListener(_indexListener);
    super.initState();
  }

  @override
  void dispose() {
    _controller.removeListener(_indexListener);
    super.dispose();
  }

  void _indexListener() {
    setState(() {
      _currentIndex = _controller.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _numberOfItemsInCart = context.select<UserProvider, int>((userProvider) {
      return userProvider.totalNumberOfProductsInShoppingCart;
    });

    return Stack(
      children: [
        CupertinoTabScaffold(
          controller: _controller,
          tabBuilder: (context, index) {
            return CupertinoTabView(
              builder: (_) => _screens[index],
            );
          },
          tabBar: CupertinoTabBar(
            border: Border(top: BorderSide.none),
            currentIndex: 0,
            iconSize: 24.0,
            activeColor: selectedGrey,
            inactiveColor: unselectedGrey,
            items: _buildBottomNavigationBarItems(),
          ),
        ),
        if (_currentIndex != 4)
          Positioned(
            bottom: 8.5.h,
            right: 3.w,
            child: FloatingActionButton(
              key: _fabKey,
              backgroundColor: _numberOfItemsInCart == 0 ? gray2 : accentColor,
              shape:
                  CircleBorder(side: BorderSide(color: Colors.white, width: 2)),
              onPressed: () {
                _startPageTransition();
              },
              child: _numberOfItemsInCart == 0
                  ? Center(
                      child: Icon(
                        Icons.shopping_cart,
                        size: 16,
                        color: selectedGrey,
                      ),
                    )
                  : Row(
                      children: [
                        SizedBox(width: 3.w),
                        Icon(
                          Icons.shopping_cart,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '$_numberOfItemsInCart',
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              ?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ),
        _pageTransition,
      ],
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavigationBarItems() {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.food_bank_outlined),
        label: 'Shop',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.content_cut),
        label: 'Coupons',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.list),
        label: 'Orders',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_box),
        label: 'Account',
      ),
    ];
  }

  void _startPageTransition() {
    setState(() {
      _fabRect = getWidgetRect(_fabKey);
      _pageTransitionRect = _fabRect;
    });

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final fullScreenSize = MediaQuery.of(context).size.longestSide;
      setState(() {
        _pageTransitionRect = _pageTransitionRect?.inflate(fullScreenSize);
      });
    });
  }

  Widget get _pageTransition {
    if (_pageTransitionRect == null) {
      return Container();
    }

    return AnimatedPositioned.fromRect(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _numberOfItemsInCart == 0 ? gray2 : accentColor,
        ),
      ),
      rect: _pageTransitionRect ?? Rect.zero,
      duration: Duration(milliseconds: 300),
      onEnd: () async {
        bool shouldNavigatePage = _pageTransitionRect != _fabRect;
        if (shouldNavigatePage) {
          await Navigator.of(context, rootNavigator: true).push(
            FadeRouteBuilder(
              page: ShoppingCartScreen(),
            ),
          );
          setState(() {
            _pageTransitionRect = _fabRect;
          });
        } else {
          setState(() {
            _pageTransitionRect = null;
          });
        }
      },
    );
  }
}

class FadeRouteBuilder<T> extends PageRouteBuilder<T> {
  FadeRouteBuilder({required Widget page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration(milliseconds: 200),
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) =>
              FadeTransition(opacity: animation, child: child),
        );
}
