import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/providers/user_provider.dart';
import 'package:my_heb_clone/screens/bottom_tab_bar.dart';
import 'package:my_heb_clone/screens/login_signup/heb_text_form_field.dart';
import 'package:my_heb_clone/services/heb_service_exception.dart';
import 'package:my_heb_clone/widgets/heb_alert_dialog.dart';
import 'package:my_heb_clone/widgets/heb_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'form_footer.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = 'login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  final emailFieldKey = GlobalKey<FormFieldState>();
  final passwordFieldKey = GlobalKey<FormFieldState>();

  String? email;
  String? password;
  bool formIsComplete = false;

  bool obscurePassword = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    emailController.addListener(_setCheckFormComplete);
    passwordController.addListener(_setCheckFormComplete);
  }

  void _setCheckFormComplete() {
    setState(() {
      formIsComplete = _checkIsFormComplete();
    });
  }

  void _submitForm() async {
    setState(() {
      loading = true;
    });
    try {
      await context.read<UserProvider>().login(email!, password!);
      setState(() {
        loading = false;
      });
      Navigator.of(context).pushReplacementNamed(BottomTabBar.routeName);
    } on HebServiceException {
      setState(() {
        loading = false;
      });
      await showDialog(
        context: context,
        builder: (context) => HebAlertDialog(
          title: 'Incorrect email or password',
          content:
              'Try entering your information again or tap "Forgot password" to reset your password.',
          actions: [
            HebAlertDialogButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              title: 'OK',
              isPrimary: true,
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context,
        title: Text(
          'Log in',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Theme(
        data: ThemeData(
          primarySwatch: formSwatch,
          checkboxTheme: CheckboxThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
        child: Stack(children: [
          Form(
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: 10.h,
                  left: 16,
                  right: 16,
                  top: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...[
                      HebTextFormField(
                        labelText: 'Email',
                        fieldKey: emailFieldKey,
                        controller: emailController,
                        autofocus: true,
                        onChanged: (value) {
                          email = value;
                        },
                      ),
                      HebTextFormField(
                          labelText: 'Password',
                          obscureText: obscurePassword,
                          fieldKey: passwordFieldKey,
                          controller: passwordController,
                          suffix: InkWell(
                            onTap: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            child: Icon(obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                          ),
                          onChanged: (value) {
                            password = value;
                          }),
                    ].expand(
                      (widget) => [
                        widget,
                        const SizedBox(
                          height: 48.0,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          FormFooter(
            buttonTitle: 'Log in',
            onPressed: formIsComplete ? _submitForm : null,
          ),
          if (loading)
            Center(
              child: CircularProgressIndicator(
                color: hebRed,
              ),
            )
        ]),
      ),
    );
  }

  bool _checkIsFormComplete() {
    return emailController.value.text.isNotEmpty &&
        passwordController.value.text.isNotEmpty;
  }
}
