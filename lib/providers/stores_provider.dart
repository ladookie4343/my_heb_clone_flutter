import 'dart:collection';

import 'package:my_heb_clone/models/day_availability.dart';
import 'package:my_heb_clone/models/store.dart';
import 'package:my_heb_clone/services/heb_http_service.dart';

class StoresProvider {
  final _hebHttpService = HebHttpService();
  var _stores = <Store>[];
  var _availablePickupTimes = <DayAvailability>[];

  UnmodifiableListView<Store> get stores => UnmodifiableListView(_stores);

  UnmodifiableListView<DayAvailability> get availablePickupTimesByDay =>
      UnmodifiableListView(_availablePickupTimes);

  Future<void> fetchStores() async {
    _stores = await _hebHttpService.getStores();
  }

  Future<void> fetchAvailablePickupTimes(String storeId) async {
    await Future.delayed(Duration(milliseconds: 500));
    List<DayAvailability> dayAvailabilities = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 8; i++) {
      var day = now.add(Duration(days: i));
      var dayAvailability = DayAvailability(
        day: day,
        timeSlots: _generateTimeSlots(day),
      );
      dayAvailabilities.add(dayAvailability);
    }
    _availablePickupTimes = dayAvailabilities;
  }

  List<TimeSlot> _generateTimeSlots(DateTime day) {
    List<TimeSlot> timeSlots = [];
    var beginTime = DateTime.now().day == day.day
        ? DateTime(
            day.year,
            day.month,
            day.day,
            day.minute > 30 ? day.hour + 2 : day.hour + 1, // 1 hour buffer
            day.minute > 30 ? 0 : 30,
          )
        : DateTime(day.year, day.month, day.day, 7, 0);
    var endTime = DateTime(day.year, day.month, day.day, 20, 35);
    while (beginTime.isBefore(endTime)) {
      timeSlots.add(TimeSlot(startTime: beginTime, price: 3.95));
      beginTime = beginTime.add(Duration(minutes: 30));
    }
    return timeSlots;
  }
}


