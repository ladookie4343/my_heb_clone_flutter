import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../colors.dart';

class FormFooter extends StatelessWidget {
  final String buttonTitle;
  final VoidCallback? onPressed;

  FormFooter({
    Key? key,
    required this.buttonTitle,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0.0,
      child: Container(
        width: 100.w,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(width: .25)),
        ),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
              child: Text(
                'By tapping "$buttonTitle", I agree to\nTerms & Conditions and acknowledge the Privacy Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: selectedGrey,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: accentColor,
                shape: StadiumBorder(),
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * .33,
                ),
              ),
              // onPressed: formIsComplete ? _submitForm : null,
              onPressed: onPressed,
              child: Text(
                buttonTitle,
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            )
          ],
        ),
      ),
    );
  }
}
