import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/widgets/pill_button.dart';
import 'package:sizer/sizer.dart';

class PlaceOrderButton extends StatelessWidget {
  final String price;
  final VoidCallback? onPressed;

  const PlaceOrderButton({Key? key, required this.price, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(width: 1.0, color: line)),
        color: Colors.white,
      ),
      padding: const EdgeInsets.only(top: 10.0),
      width: double.infinity,
      height: 11.h,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'By tapping "Place order," I agree to\nTerms & Conditions and acknowledge the Privacy Policy.',
              textAlign: TextAlign.center,
            ),
          ),
          PillButton(
            onPressed: onPressed,
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: 'Place order   ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                  text: price,
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                ),
              ]),
            ),
            color: accentColor,
            fullWidth: true,
          )
        ],
      ),
    );
  }
}
