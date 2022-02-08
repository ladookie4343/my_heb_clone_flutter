import 'package:flutter/material.dart';
import 'package:my_heb_clone/widgets/heb_app_bar.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context,
        title: Text(
          'Coupons',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: Text('Coupons'),
      ),
    );
  }
}
