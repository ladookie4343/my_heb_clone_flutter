import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/providers/user_provider.dart';
import 'package:my_heb_clone/widgets/heb_app_bar.dart';
import 'package:my_heb_clone/widgets/pill_button.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class EditPhoneNumberScreen extends StatefulWidget {
  final String initialValue;

  const EditPhoneNumberScreen({Key? key, required this.initialValue})
      : super(key: key);

  @override
  _EditPhoneNumberScreenState createState() => _EditPhoneNumberScreenState();
}

class _EditPhoneNumberScreenState extends State<EditPhoneNumberScreen> {
  late TextEditingController _controller;
  bool _isSaveEnabled = false;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(() {
      var text = _controller.text;
      // going forwards
      if (text.length == 4) {
        var s = '(${text.substring(0, 3)}) ${text[3]}';
        _controller.text = s;
        _controller.selection = TextSelection(
          baseOffset: s.length,
          extentOffset: s.length,
        );
      }
      // going backwards (text.length only ever equals 6 going backwards)
      if (text.length == 6) {
        var s = text.substring(1, 4);
        _controller.text = s;
        _controller.selection = TextSelection(
          baseOffset: s.length,
          extentOffset: s.length,
        );
      }

      // going forwards
      if (_controller.text.length == 10 && !_controller.text.contains('-')) {
        var s = '${text.substring(0, 9)}-${text[9]}';
        _controller.text = s;
        _controller.selection = TextSelection(
          baseOffset: s.length,
          extentOffset: s.length,
        );
      }
      // going backwards
      if (_controller.text.length == 10 && _controller.text.contains('-')) {
        var s = '${text.substring(0, 9)}';
        _controller.text = s;
        _controller.selection = TextSelection(
          baseOffset: s.length,
          extentOffset: s.length,
        );
      }
      if (text.length == 14) {
        setState(() {
          _isSaveEnabled = true;
        });
      } else {
        setState(() {
          _isSaveEnabled = false;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = context.read<UserProvider>();
    return Scaffold(
      appBar: buildAppBar(context, title: Text('Contact number')),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Text(
              'Subscribe to order updates by SMS',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 1.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'Mobile number',
                suffixIcon: IconButton(
                  padding: EdgeInsets.all(4),
                  icon: Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                    });
                  },
                ),
              ),
              autofocus: true,
              keyboardType: TextInputType.number,
              controller: _controller,
            ),
            SizedBox(height: 3.h),
            Text(
                'Message and data rates may apply. Message frequency may vary. Text HELP to 99147 for help. Text STOP to 99147 to cancel. Full terms and privacy heb.com/smsterms.'),
          ],
        ),
      ),
      floatingActionButton: PillButton(
        onPressed: _isSaveEnabled
            ? () {
                userProvider.updatePhoneNumber(_controller.text);
                Navigator.of(context).pop();
              }
            : null,
        child: Text('Save'),
        color: accentColor,
        fullWidth: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
