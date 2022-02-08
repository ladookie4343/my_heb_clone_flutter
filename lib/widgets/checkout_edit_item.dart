import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';

class CheckoutEditItem extends StatelessWidget {
  final Widget leading;
  final Widget? stackItem;
  final double? stackItemHeight;
  final String title;
  final List<Widget> bodyWidgets;
  final VoidCallback onChangePressed;
  final String onChangeTitle;

  const CheckoutEditItem({
    Key? key,
    required this.leading,
    required this.title,
    required this.bodyWidgets,
    required this.onChangePressed,
    this.onChangeTitle = 'Change',
    this.stackItem,
    this.stackItemHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1, color: line),
            ),
          ),
          padding: EdgeInsets.only(top: 40, bottom: 15),
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: leading,
              ),
              Expanded(
                flex: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    SizedBox(height: 10),
                    ...bodyWidgets,
                    if (stackItemHeight != null)
                      SizedBox(height: stackItemHeight)
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onChangePressed,
                  child: Text(
                    onChangeTitle,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2
                        ?.copyWith(color: accentColor),
                  ),
                ),
              )
            ],
          ),
        ),
        if (stackItem != null) Positioned(bottom: 10, left: 0, child: stackItem!)
      ],
    );
  }
}
