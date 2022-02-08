import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/providers/products_provider.dart';
import 'package:my_heb_clone/providers/stores_provider.dart';
import 'package:my_heb_clone/screens/login_signup/login_screen.dart';
import 'package:my_heb_clone/screens/login_signup/sign_up_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import 'package:my_heb_clone/widgets/heb_intro_page_scroller.dart';

import '../bottom_tab_bar.dart';

class IntroScreen extends StatefulWidget {
  static const String routeName = 'intro-screen';

  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {

  @override
  void initState() {
    super.initState();
    // pre-fetch some data in the background
    context.read<StoresProvider>().fetchStores();
    context.read<ProductsProvider>().fetchDepartments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0XFF2C1309),
        constraints: BoxConstraints.expand(),
        child: Stack(children: [
          Image.asset(
            'assets/images/intro_background.jpg',
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Center(
            child: Container(
              width: 85.w,
              height: 490,
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
              ),
              child: Column(
                children: [
                  Expanded(flex: 8, child: HebIntroPageScroller()),
                  Expanded(
                    flex: 2,
                    child: _buildButtons(context),
                  )
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                primary: Colors.black,
                side: BorderSide(
                  width: 1,
                  color: selectedGrey,
                ),
                shape: StadiumBorder(),
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(LoginScreen.routeName);
              },
              child: Text(
                'Log in',
                style: TextStyle(
                  color: selectedGrey,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: accentColor,
                shape: StadiumBorder(),
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(SignUpScreen.routeName);
              },
              child: Text(
                'Sign up',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            )
          ],
        ),
        TextButton(
          style: TextButton.styleFrom(primary: accentColor),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(BottomTabBar.routeName);
          },
          child: Text(
            'Continue as guest',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
