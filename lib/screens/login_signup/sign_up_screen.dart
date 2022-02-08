import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/models/user.dart';
import 'package:my_heb_clone/providers/user_provider.dart';
import 'package:my_heb_clone/screens/login_signup/form_footer.dart';
import 'package:my_heb_clone/screens/login_signup/heb_text_form_field.dart';
import 'package:my_heb_clone/screens/login_signup/how_to_shop_screen.dart';
import 'package:my_heb_clone/widgets/check_option.dart';
import 'package:my_heb_clone/widgets/heb_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = 'sign-up';

  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late FocusNode emailFocusNode;
  late FocusNode passwordFocusNode;
  late FocusNode phoneNumberFocusNode;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController phoneNumberController;

  final emailFieldKey = GlobalKey<FormFieldState>();
  final passwordFieldKey = GlobalKey<FormFieldState>();
  final phoneNumberFieldKey = GlobalKey<FormFieldState>();

  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? phoneNumber;
  bool optIn = false;
  bool formIsComplete = false;

  bool obscurePassword = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    phoneNumberFocusNode = FocusNode();

    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    phoneNumberController = TextEditingController();

    emailFocusNode.addListener(() {
      if (!emailFocusNode.hasFocus && email != null && email!.isNotEmpty) {
        emailFieldKey.currentState?.validate();
      }
    });

    passwordFocusNode.addListener(() {
      if (!passwordFocusNode.hasFocus &&
          password != null &&
          password!.isNotEmpty) {
        passwordFieldKey.currentState?.validate();
      }
    });

    phoneNumberFocusNode.addListener(() {
      if (!phoneNumberFocusNode.hasFocus &&
          phoneNumber != null &&
          phoneNumber!.isNotEmpty) {
        phoneNumberFieldKey.currentState!.validate();
      }
    });

    firstNameController.addListener(_setCheckFormComplete);
    lastNameController.addListener(_setCheckFormComplete);
    emailController.addListener(_setCheckFormComplete);
    passwordController.addListener(_setCheckFormComplete);
    phoneNumberController.addListener(_setCheckFormComplete);
  }

  void _setCheckFormComplete() {
    setState(() {
      formIsComplete = _checkIsFormComplete();
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    phoneNumberFocusNode.dispose();
    super.dispose();
  }

  void _submitForm() async {
    setState(() {
      loading = true;
    });
    final user = User(
      firstName: firstName!,
      lastName: lastName!,
      email: email!,
      password: password!,
      phoneNumber: phoneNumber,
      optIn: optIn,
      shoppingCart: {},
      orders: []
    );
    await context.read<UserProvider>().createAccount(user);
    setState(() {
      loading = false;
    });
    Navigator.of(context).pushReplacementNamed(HowToShopScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context,
        title: Text(
          'Sign up',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Theme(
        data: ThemeData(
            primarySwatch: formSwatch,
            textTheme: TextTheme(
              bodyText1: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: selectedGrey,
              ),
            )),
        child: SafeArea(
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
                      ..._buildHeader(),
                      ...[
                        HebTextFormField(
                          labelText: 'First name',
                          controller: firstNameController,
                          onChanged: (value) {
                            firstName = value;
                          },
                        ),
                        HebTextFormField(
                          labelText: 'Last name',
                          controller: lastNameController,
                          onChanged: (value) {
                            lastName = value;
                          },
                        ),
                        HebTextFormField(
                          labelText: 'Email',
                          validator: _emailValidator,
                          key: emailFieldKey,
                          focusNode: emailFocusNode,
                          controller: emailController,
                          onChanged: (value) {
                            email = value;
                          },
                        ),
                        HebTextFormField(
                            labelText: 'Password',
                            obscureText: obscurePassword,
                            helperText:
                                'Must be 8 or more characters and include at least 1 number',
                            validator: _passwordValidator,
                            key: passwordFieldKey,
                            focusNode: passwordFocusNode,
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
                        HebTextFormField(
                            keyboardType: TextInputType.number,
                            labelText: 'Mobile number (optional)',
                            helperText:
                                "We'll use this for curbside or delivery communication",
                            validator: _phoneNumberValidator,
                            key: phoneNumberFieldKey,
                            focusNode: phoneNumberFocusNode,
                            controller: phoneNumberController,
                            onChanged: (value) {
                              phoneNumber = value;
                            }),
                        CheckOption(
                          description:
                              'Sign up for exclusive offers and savings. You can opt out at any time.',
                          value: optIn,
                          onChanged: (value) {
                            setState(() {
                              optIn = value!;
                            });
                          },
                        ),
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
              buttonTitle: 'Create account',
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
      ),
    );
  }

  List<Widget> _buildHeader() {
    return [
      Text(
        'Welcome!',
        style: Theme.of(context).textTheme.headline4,
      ),
      SizedBox(height: 8),
      Text(
        'Create a free account to shop, order curbside and delivery, clip coupons, and more.',
        style: Theme.of(context).textTheme.bodyText1,
      ),
      SizedBox(height: 8),
    ];
  }

  String? _emailValidator(String? value) {
    if (value == null) return null;
    final emailRegex = RegExp(r'^\S+@\S+\.\S+$');
    if (emailRegex.hasMatch(value)) {
      return null;
    } else {
      return 'Email address is invalid';
    }
  }

  String? _passwordValidator(String? value) {
    if (value == null) return null;
    if (value.length >= 8 && value.contains(RegExp(r'\d'))) return null;
    return 'Must be 8 or more characters and include at least 1 number';
  }

  String? _phoneNumberValidator(String? value) {
    if (value == null || value.isEmpty) return null;
    final phoneNumberRegex = RegExp(r'^\d\d\d\d\d\d\d\d\d\d$');
    if (phoneNumberRegex.hasMatch(value)) {
      return null;
    } else {
      return 'Phone number is invalid';
    }
  }

  bool _checkIsFormComplete() {
    return firstNameController.value.text.isNotEmpty &&
        lastNameController.value.text.isNotEmpty &&
        emailController.value.text.isNotEmpty &&
        _emailValidator(emailController.value.text) == null &&
        passwordController.value.text.isNotEmpty &&
        _passwordValidator(passwordController.value.text) == null &&
        _phoneNumberValidator(phoneNumberController.value.text) == null;
  }
}
