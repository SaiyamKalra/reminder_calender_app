// import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:reminder_calender_app/calenderPage/domain/event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event> appointments) {
    this.appointments = appointments;
  }

  Event getEvent(int index) => appointments![index] as Event;

  @override
  DateTime getStartTime(int index) => getEvent(index).fromDate;

  @override
  DateTime getEndTime(int index) {
    final event = getEvent(index);
    // Assumes a default duration of 1 hour if no 'toDate' is available.
    return event.fromDate.add(const Duration(hours: 1));
  }

  @override
  Color getColor(int index) {
    // ⭐️ FIX: Return a visible color, e.g., blue, green, or the color from your Event model
    return Colors.blue;
  }

  // @override
  String getTitle(int index) => getEvent(index).title;

  // @override
  String getDescription(int index) => getEvent(index).description;
}
