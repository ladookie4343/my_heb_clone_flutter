import 'package:flutter/material.dart';
import 'package:my_heb_clone/providers/user_provider.dart';
import 'package:my_heb_clone/widgets/heb_app_bar.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var orders = context.watch<UserProvider>().user!.orders;
    return Scaffold(
      appBar: buildAppBar(
        context,
        title: Text(
          'Orders',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          for (int i = 0; i < orders.length; i++)
            Text('${orders[i].id}'),
        ]
      ),
    );
  }
}
