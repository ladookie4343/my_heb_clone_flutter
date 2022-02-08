import 'package:flutter/material.dart';

import 'circular_checkbox.dart';

class CheckOption extends StatelessWidget {
  final bool? value;
  final String description;
  final ValueChanged<bool?>? onChanged;

  CheckOption({
    Key? key,
    this.value,
    required this.description,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircularCheckbox(
            value: value,
            onChanged: onChanged,
          ),
          Expanded(
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ],
      ),
    );
  }
}
