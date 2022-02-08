import 'package:flutter/material.dart';

import '../colors.dart';

class CircularCheckbox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;

  const CircularCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: accentColor,
      ),
    );
  }
}
