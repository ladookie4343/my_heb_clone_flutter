import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_heb_clone/colors.dart';
import 'package:my_heb_clone/models/day_availability.dart';
import 'package:my_heb_clone/models/store.dart';
import 'package:my_heb_clone/providers/stores_provider.dart';
import 'package:my_heb_clone/providers/user_provider.dart';
import 'package:my_heb_clone/screens/checkout/checkout_screen.dart';
import 'package:my_heb_clone/widgets/circular_checkbox.dart';
import 'package:my_heb_clone/widgets/heb_app_bar.dart';
import 'package:my_heb_clone/widgets/pill_button.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class CurbsideTimeSelectionScreen extends StatefulWidget {
  final Store store;
  final bool fromShoppingCart;
  final TimeSlot? selectedTimeSlot;

  CurbsideTimeSelectionScreen({
    required this.store,
    this.selectedTimeSlot,
    this.fromShoppingCart = false,
  });

  @override
  _CurbsideTimeSelectionScreenState createState() =>
      _CurbsideTimeSelectionScreenState();
}

class _CurbsideTimeSelectionScreenState
    extends State<CurbsideTimeSelectionScreen> {
  bool _loading = true;
  int _currentSelectedDay = 0;
  List<DayAvailability> _availablePickupTimesByDay = [];

  Map<String, bool> _checkboxValues = {};
  Map<String, GlobalKey> _checkboxKeys = {};

  TimeSlot? _previousSelectedTimeSlot;
  TimeSlot? _currentSelectedTimeSlot;

  final _scrollController = ScrollController();

  @override
  void initState() {
    fetchAvailability();
    super.initState();
  }

  void fetchAvailability() async {
    final storesProvider = context.read<StoresProvider>();
    await storesProvider.fetchAvailablePickupTimes(widget.store.id);

    final checkboxEntries = storesProvider.availablePickupTimesByDay
        .expand((e) => e.timeSlots)
        .map((e) => MapEntry(e.startTime.toString(), false));

    final checkboxKeyEntries = storesProvider.availablePickupTimesByDay
        .expand((e) => e.timeSlots)
        .map((e) => MapEntry(e.startTime.toString(), GlobalKey()));

    _checkboxKeys.addEntries(checkboxKeyEntries);
    _checkboxValues.addEntries(checkboxEntries);
    if (widget.selectedTimeSlot != null) {
      _checkboxValues[widget.selectedTimeSlot!.startTime.toString()] = true;
      _previousSelectedTimeSlot = widget.selectedTimeSlot;
      _currentSelectedTimeSlot = widget.selectedTimeSlot;
    }
    _currentSelectedDay =
        _calculateCurrentSelectedDay(storesProvider.availablePickupTimesByDay);

    setState(() {
      _loading = false;
      _availablePickupTimesByDay = storesProvider.availablePickupTimesByDay;
    });

    Future.delayed(Duration.zero, () {
      if (widget.selectedTimeSlot != null) {
        var checkboxKey =
            _checkboxKeys[widget.selectedTimeSlot!.startTime.toString()];
        Scrollable.ensureVisible(
          checkboxKey!.currentContext!,
          duration: Duration(milliseconds: 150),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = context.read<UserProvider>();
    return Scaffold(
      appBar: buildAppBar(
        context,
        title: Text('Choose pickup time'),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop(_previousSelectedTimeSlot);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _buildScreen(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: PillButton(
        color: accentColor,
        onPressed: isNoChanges
            ? null
            : () {
                if (widget.fromShoppingCart) {
                  userProvider.updateTimeSlot(_currentSelectedTimeSlot!);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CheckoutScreen()),
                  );
                } else {
                  Navigator.of(context).pop(_currentSelectedTimeSlot);
                }
              },
        child: Text(widget.fromShoppingCart ? 'Reserve time' : 'Save'),
        fullWidth: true,
      ),
    );
  }

  bool get isNoChanges => (_currentSelectedTimeSlot == null ||
      _previousSelectedTimeSlot?.startTime ==
          _currentSelectedTimeSlot?.startTime);

  Widget _buildScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 4.w, top: 4.w),
          child: Text('Date', style: Theme.of(context).textTheme.headline5),
        ),
        SizedBox(
          height: 8.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _availablePickupTimesByDay.length,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemBuilder: (context, index) {
              return _buildDayButton(index, context);
            },
          ),
        ),
        _buildTimeSlots(),
      ],
    );
  }

  Widget _buildDayButton(int index, BuildContext context) {
    var day = _availablePickupTimesByDay[index];
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentSelectedDay = index;
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: 4.w),
        decoration: BoxDecoration(
          color: index == _currentSelectedDay ? accentColor : Colors.white,
          border: Border.all(color: line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w400,
                  color: index == _currentSelectedDay
                      ? Colors.white
                      : selectedGrey,
                ),
              ),
            ),
            SizedBox(
              width: 12.w,
              child: Divider(
                color: index == _currentSelectedDay ? dayButtonLine : line,
                thickness: 1,
                height: 1,
              ),
            ),
            SizedBox(height: 1.w),
            Text(
              day.monthDayFormat(),
              style: index == _currentSelectedDay
                  ? TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    )
                  : Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 1.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: index == _currentSelectedDay ? Colors.white : free,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'Free',
                style: TextStyle(
                  color:
                      index == _currentSelectedDay ? accentColor : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    var availablePickupTimes =
        _availablePickupTimesByDay[_currentSelectedDay].timeSlots;
    var morningPickupTimes =
        availablePickupTimes.where((e) => e.startTime.hour < 12).toList();
    var afternoonPickupTimes = availablePickupTimes
        .where((e) => e.startTime.hour >= 12 && e.startTime.hour < 17)
        .toList();
    var eveningPickupTimes =
        availablePickupTimes.where((e) => e.startTime.hour >= 17).toList();

    return Expanded(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              children: [
                if (morningPickupTimes.isNotEmpty)
                  _buildTimeSlotGrouping('Morning', morningPickupTimes),
                if (afternoonPickupTimes.isNotEmpty)
                  _buildTimeSlotGrouping('Afternoon', afternoonPickupTimes),
                if (eveningPickupTimes.isNotEmpty)
                  _buildTimeSlotGrouping('Evening', eveningPickupTimes),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotGrouping(String heading, List<TimeSlot> timeSlots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 4.h,
        ),
        Text(heading, style: Theme.of(context).textTheme.headline5),
        ...timeSlots.map((e) => _buildTimeSlot(e)).toList()
      ],
    );
  }

  Widget _buildTimeSlot(TimeSlot timeSlot) {
    String startTime = timeSlot.startTime.toString();
    return Container(
      key: _checkboxKeys[startTime],
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              timeSlot.timeRangeString,
              style: _checkboxValues[startTime] ?? false
                  ? TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: selectedGrey,
                    )
                  : Theme.of(context).textTheme.bodyText1,
            ),
          ),
          Text(NumberFormat.simpleCurrency().format(timeSlot.price)),
          CircularCheckbox(
            value: _checkboxValues[startTime],
            onChanged: (value) {
              setState(() {
                _checkboxValues[_currentSelectedTimeSlot == null
                    ? ''
                    : _currentSelectedTimeSlot!.startTime.toString()] = false;
                _checkboxValues[startTime] = true;
                _currentSelectedTimeSlot = timeSlot;
              });
            },
          ),
        ],
      ),
    );
  }

  int _calculateCurrentSelectedDay(
      List<DayAvailability> availablePickupTimesByDay) {
    if (widget.selectedTimeSlot == null) {
      return 0;
    }
    return availablePickupTimesByDay
        .indexWhere((e) => e.day.day == widget.selectedTimeSlot!.startTime.day);
  }
}
