import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:my_heb_clone/models/shopping_method.dart';
import 'package:my_heb_clone/models/user.dart';
import 'package:my_heb_clone/screens/home/store_configurator_screen.dart';

class StoreConfigurationHeader extends StatelessWidget {
  final User user;

  const StoreConfigurationHeader({Key? key, required this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showMaterialModalBottomSheet(
          context: context,
          useRootNavigator: true,
          builder: (context) => StoreConfiguratorScreen(),
        );
      },
      child: _buildTitle(user),
    );
  }

  Widget _buildTitle(User user) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text:
                '${user.getShoppingMethodFriendlyString()} ${user.shoppingMethod == ShoppingMethod.delivery ? 'home' : user.store?.name}\n',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          TextSpan(
            text: user.shoppingMethod == ShoppingMethod.inStore
                ? 'Shop Curbside or Delivery'
                : user.timeSlot != null
                    ? user.friendlyTimeSlotString
                    : 'Choose time',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
          ),
          WidgetSpan(
            child: Icon(
              Icons.keyboard_arrow_down_sharp,
              size: 12,
            ),
          )
        ],
      ),
    );
  }
}
