import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../colors.dart';

class HebAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<Widget> actions;

  HebAlertDialog({
    required this.title,
    required this.content,
    required this.actions,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headline6,
      ),
      titlePadding: EdgeInsets.only(top: 4.w, left: 4.w, bottom: 2.w),
      content: Text(
        content,
        style: Theme.of(context).textTheme.bodyText1,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      actions: actions,
    );
  }
}

class HebAlertDialogButton extends StatelessWidget {
  final String title;
  final bool isPrimary;
  final VoidCallback? onPressed;

  const HebAlertDialogButton({
    required this.title,
    required this.isPrimary,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 8.w,
      child: TextButton(
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        style: TextButton.styleFrom(
            primary:
            isPrimary ? accentColor : selectedGrey),
        onPressed: onPressed,
      ),
    );
  }
}