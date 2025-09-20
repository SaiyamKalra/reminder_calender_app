import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_calender_app/calenderPage/provider/event_provider.dart';
import 'package:reminder_calender_app/calenderPage/service/event_data_source.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class TasksWidget extends StatelessWidget {
  const TasksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final selectedEvents = provider.eventOfSelectedDate;
    if (selectedEvents.isEmpty) {
      return Center(child: Text('No Event found'));
    }
    return SfCalendar(
      view: CalendarView.timelineDay,
      dataSource: EventDataSource(provider.events),
    );
  }
}
