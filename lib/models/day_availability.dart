import 'package:intl/intl.dart';

class DayAvailability {
  DateTime day;
  List<TimeSlot> timeSlots;

  DayAvailability({
    required this.day,
    required this.timeSlots,
  });

  String monthDayFormat() {
    return DateFormat('MMM dd').format(day);
  }

  @override
  String toString() {
    return friendlyDayString(day);
  }
}

class TimeSlot {
  DateTime startTime;
  double price;

  TimeSlot({
    required this.startTime,
    required this.price,
  });

  String get friendlyDescription =>
      '${friendlyDayString(startTime)}, ${DateFormat('MMMM dd').format(startTime)}\n$timeRangeString';

  String get timeRangeString => friendlyTimeRangeString(startTime);
}

String friendlyDayString(DateTime dateTime) {
  final now = DateTime.now();
  if (dateTime.day == now.day) {
    return 'Today';
  }
  if (dateTime.day == now.day + 1) {
    return 'Tomorrow';
  }
  return DateFormat('EEEE').format(dateTime);
}

String friendlyTimeString(DateTime time) {
  return DateFormat('h:mma').format(time).toLowerCase();
}

String friendlyTimeRangeString(DateTime time) {
  return '${friendlyTimeString(time)}-${friendlyTimeString(time.add(Duration(minutes: 30)))}';
}
