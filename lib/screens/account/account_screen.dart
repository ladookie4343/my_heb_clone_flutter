import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/providers/user_provider.dart';
import 'package:my_heb_clone/screens/login_signup/intro_screen.dart';
import 'package:my_heb_clone/widgets/heb_app_bar.dart';
import 'package:my_heb_clone/widgets/pill_button.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().user!;
    return Scaffold(
      appBar: buildAppBar(
        context,
        title: Text(
          'Hi, ${user.firstName}!',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: PillButton(
          onPressed: () {
            context.read<UserProvider>().logout();
            Navigator.of(context, rootNavigator: true)
                .pushReplacementNamed(IntroScreen.routeName);
          },
          color: hebRed,
          child: Text('Log out'),
        ),
      ),
    );
  }
}
