import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/models/day_availability.dart';
import 'package:my_heb_clone/models/shopping_method.dart';
import 'package:my_heb_clone/models/store.dart';
import 'package:my_heb_clone/models/user.dart';
import 'package:my_heb_clone/providers/user_provider.dart';
import 'package:my_heb_clone/screens/login_signup/store_finder_screen.dart';
import 'package:my_heb_clone/widgets/heb_alert_dialog.dart';
import 'package:my_heb_clone/widgets/heb_app_bar.dart';
import 'package:my_heb_clone/widgets/pill_button.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'curbside_time_selection_screen.dart';

class StoreConfiguratorScreen extends StatefulWidget {
  const StoreConfiguratorScreen({Key? key}) : super(key: key);

  @override
  State<StoreConfiguratorScreen> createState() =>
      _StoreConfiguratorScreenState();
}

class _StoreConfiguratorScreenState extends State<StoreConfiguratorScreen>
    with SingleTickerProviderStateMixin {
  int _currentTabIndex = 0;
  late TabController _tabController;
  late Store _currentStore;
  late UserProvider _userProvider;
  late User _user;
  TimeSlot? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    _userProvider = context.read<UserProvider>();
    _user = _userProvider.user!;
    _currentStore = _user.store!;
    _currentTabIndex = _user.getShoppingMethodTabIndex();
    _selectedTimeSlot = _user.timeSlot == null
        ? null
        : TimeSlot(startTime: _user.timeSlot!, price: 3.95);
    _tabController =
        TabController(length: 3, initialIndex: _currentTabIndex, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () async {
            bool? isDiscard = true;
            if (isChange) {
              isDiscard = await buildShowDialog(context);
            }
            if (isDiscard == true) {
              Navigator.of(context).pop();
            }
          },
        ),
        bottom: _buildTabBar(),
      ),
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          _buildTabPage(0),
          _buildTabPage(1),
          _buildTabPage(2),
        ],
      ),
    );
  }

  Future<bool?> buildShowDialog(BuildContext context) {
    return showDialog<bool?>(
              context: context,
              builder: (context) => HebAlertDialog(
                title: 'Discard changes?',
                content: "Your changes haven't been applied yet.",
                actions: [
                  HebAlertDialogButton(
                    title: 'CANCEL',
                    isPrimary: false,
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  HebAlertDialogButton(
                    title: 'DISCARD',
                    isPrimary: true,
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              ),
            );
  }

  bool get isChange =>
      _currentTabIndex != _user.getShoppingMethodTabIndex() ||
      _currentStore.id != _user.store!.id ||
      _selectedTimeSlot?.startTime != _user.timeSlot;

  Widget _buildTabPage(int tabIndex) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Placeholder(fallbackHeight: 14.h),
            SizedBox(height: 1.h),
            _buildStoreAddress(tabIndex),
            SizedBox(height: 1.h),
            if (tabIndex == 0)
              _selectedTimeSlot == null
                  ? _buildPickupTimeButton()
                  : _buildTile(
                      Icons.access_time_filled_rounded,
                      'Pickup time',
                      _selectedTimeSlot!.friendlyDescription,
                      onPickupTimePressed,
                    ),
            Expanded(child: Container()),
            PillButton(
              onPressed: onSavePressed(tabIndex),
              child: Text('Save'),
              color: accentColor,
              fullWidth: true,
            )
          ],
        ),
      ),
    );
  }

  VoidCallback? onSavePressed(int tabIndex) {
    return isChange
        ? () {
            if (tabIndex != _user.getShoppingMethodTabIndex()) {
              _userProvider.updateShoppingMethod(getShoppingMethod(tabIndex));
            }
            if (_currentStore.id != _user.store!.id) {
              _userProvider.updateStore(_currentStore);
            }
            if (_selectedTimeSlot?.startTime != _user.timeSlot) {
              _userProvider.updateTimeSlot(_selectedTimeSlot!);
            }
            Navigator.of(context).pop();
          }
        : null;
  }

  Widget _buildStoreAddress(int tabIndex) {
    return _buildTile(
      Icons.location_pin,
      'H-E-B location',
      _currentStore.friendlyAddress,
      () async {
        final chosenStore = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StoreFinderScreen(
              isCacheOnly: true,
              shoppingMethod: getShoppingMethod(tabIndex),
            ),
          ),
        );
        if (chosenStore != null) {
          setState(() {
            _currentStore = chosenStore;
          });
        }
        if (_tabController.index == 0 && !_currentStore.isCurbside) {
          _tabController.animateTo(2);
        }
      },
    );
  }

  Widget _buildTile(IconData? icon, String title, String description,
      VoidCallback? onPressed) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: selectedGrey,
              ),
              SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 16),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 30,
                child: TextButton(
                  onPressed: onPressed,
                  child: Text('Change'),
                  style: TextButton.styleFrom(
                    primary: accentColor,
                    textStyle: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Divider(thickness: 1, color: line),
        ],
      ),
    );
  }

  PreferredSize _buildTabBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(6.h),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        padding: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: TabBar(
          controller: _tabController,
          onTap: (index) => setState(() {
            _currentTabIndex = index;
          }),
          unselectedLabelColor: Colors.black,
          unselectedLabelStyle: TextStyle(
            color: unselectedGrey,
            fontWeight: FontWeight.w400,
          ),
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
          labelPadding: EdgeInsets.symmetric(horizontal: 0.0),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: accentColor,
          ),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            SizedBox(width: 30.w, height: 4.h, child: Tab(text: 'Curbside')),
            SizedBox(width: 30.w, height: 4.h, child: Tab(text: 'Delivery')),
            SizedBox(width: 30.w, height: 4.h, child: Tab(text: 'In-store')),
          ],
        ),
      ),
    );
  }

  VoidCallback get onPickupTimePressed => () async {
        var selectedTimeSlot = await Navigator.of(context).push<TimeSlot>(
          MaterialPageRoute(
            builder: (_) => CurbsideTimeSelectionScreen(
              store: _currentStore,
              selectedTimeSlot: _selectedTimeSlot,
            ),
          ),
        );
        setState(() {
          _selectedTimeSlot = selectedTimeSlot;
        });
      };

  Widget _buildPickupTimeButton() {
    return GestureDetector(
      onTap: onPickupTimePressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.w, horizontal: 3.w),
        decoration: BoxDecoration(
          border: Border.all(color: line),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_filled_rounded, color: accentColor),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                'Choose pickup time',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: accentColor),
          ],
        ),
      ),
    );
  }
}
