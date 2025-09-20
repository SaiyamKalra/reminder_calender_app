import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:reminder_calender_app/calenderPage/domain/event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventProvider extends ChangeNotifier {
  final List<Event> _events = [];

  List<Event> get events => _events;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  EventProvider() {
    Future.microtask(() => loadEvents());
  }

  List<Event> get eventOfSelectedDate {
    return _events.where((event) {
      final selected = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      final eventDate = DateTime(
        event.fromDate.year,
        event.fromDate.month,
        event.fromDate.day,
      );
      return selected.isAtSameMomentAs(eventDate);
    }).toList()..sort((a, b) => a.fromDate.compareTo(b.fromDate));
  }

  void deleteSelectedData(Event event) {
    final removed = _events.remove(event);
    saveEvents();
    if (removed) {
      notifyListeners();
    }
  }

  Future<void> saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJsonList = _events.map((event) => event.toJson()).toList();
    final eventsString = jsonEncode(eventsJsonList);
    await prefs.setString('events_key', eventsString);
  }

  Future<void> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsString = prefs.getString('events_key');

    if (eventsString != null) {
      final List<dynamic> eventsJsonList = jsonDecode(eventsString);
      final loadedEvents = eventsJsonList
          .map((json) => Event.fromJson(json))
          .toList();

      _events.clear();
      _events.addAll(loadedEvents);
      notifyListeners();
    }
  }

  void addEvent(Event event) {
    _events.add(event);
    saveEvents();
    notifyListeners();
  }
}
