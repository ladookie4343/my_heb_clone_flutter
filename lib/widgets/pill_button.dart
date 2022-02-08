import 'package:flutter/material.dart';

import 'package:sizer/sizer.dart';

class PillButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color color;
  final bool? fullWidth;
  final bool noPadding;

  const PillButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.color,
    this.fullWidth,
    this.noPadding = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var button = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: color,
        shape: StadiumBorder(),
        padding: noPadding ? null : EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * .12,
        ),
      ),
      onPressed: onPressed,
      child: child,
    );

    if (fullWidth != null && fullWidth!) {
      return SizedBox(width: 95.w, child: button,);
    } else {
      return button;
    }
  }
}
