import 'package:flutter/material.dart';

class HebTextFormField extends StatelessWidget {
  final String labelText;
  final String? helperText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool autofocus;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;
  final Key? fieldKey;
  final TextEditingController? controller;
  final void Function(String p1)? onChanged;

  HebTextFormField({
    Key? key,
    required this.labelText,
    this.helperText,
    this.keyboardType,
    this.obscureText = false,
    this.autofocus = false,
    this.suffix,
    this.validator,
    this.focusNode,
    this.fieldKey,
    this.controller,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: fieldKey,
      focusNode: focusNode,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      autofocus: autofocus,
      textInputAction: TextInputAction.next,
      scrollPadding: const EdgeInsets.only(bottom: 120),
      decoration: InputDecoration(
        suffix: suffix,
        isDense: true,
        contentPadding: const EdgeInsets.only(top: 8),
        floatingLabelStyle: TextStyle(
          fontWeight: FontWeight.w900,
        ),
        labelText: labelText,
        helperText: helperText,
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
