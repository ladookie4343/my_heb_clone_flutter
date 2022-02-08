import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:sizer/sizer.dart';

AppBar buildAppBar(
  BuildContext context, {
  Widget? title,
  bool? centerTitle,
  Widget? leading,
  PreferredSizeWidget? bottom,
  Widget? action,
}) =>
    AppBar(
      backgroundColor: hebRed,
      leading: leading,
      centerTitle: centerTitle,
      title: title,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.elliptical(100.w, 25.0),
        ),
      ),
      actions: action != null ? [action] : null,
      bottom: bottom,
    );
