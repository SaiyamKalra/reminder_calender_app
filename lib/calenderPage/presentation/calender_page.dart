// calenderPage/presentation/calender_page.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:reminder_calender_app/calenderPage/presentation/event_selector_page.dart';
import 'package:reminder_calender_app/calenderPage/presentation/widget/tasks_widget.dart';
import 'package:reminder_calender_app/calenderPage/provider/event_provider.dart';
import 'package:reminder_calender_app/calenderPage/service/event_data_source.dart';
import 'package:reminder_calender_app/config.dart';
import 'package:reminder_calender_app/settings/presentation/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  String? username;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserNameAndSignIn();
  }

  Future<void> getUserNameAndSignIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      final url = Uri.parse('$getData/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (kDebugMode) {
          print('User data response: $data');
        }

        if (data["status"] == true) {
          final user = data["user"];

          // Save user details locally
          await prefs.setString("userId", user["id"]);
          await prefs.setString("username", user["username"]);
          await prefs.setString("email", user["email"]);

          // Update state so UI refreshes
          setState(() {
            username = user["username"];
            _isLoading = false;
          });

          if (kDebugMode) {
            print("Saved user: ${user["username"]} (${user["id"]})");
          }
        } else {
          if (kDebugMode) {
            print("Fetch failed: ${data["message"]}");
          }
        }
      } else {
        if (kDebugMode) {
          print("Server error: ${response.statusCode}");
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final events = provider.events;
    final selectedEvents = provider.eventOfSelectedDate;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      appBar: AppBar(
        title: const Center(child: Text('Calendar Page')),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
                child: const Icon(Icons.person),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 10),
                SfCalendar(
                  view: CalendarView.month,
                  backgroundColor: Colors.white,
                  dataSource: EventDataSource(events),
                  initialSelectedDate: DateTime.now(),
                  onSelectionChanged: (details) {
                    if (details.date != null) {
                      Future.microtask(() {
                        Provider.of<EventProvider>(
                          // ignore: use_build_context_synchronously
                          context,
                          listen: false,
                        ).setDate(details.date!);
                      });
                    }
                  },
                  onLongPress: (details) {
                    if (details.date != null) {
                      final provider = Provider.of<EventProvider>(
                        context,
                        listen: false,
                      );

                      Future.microtask(() {
                        provider.setDate(details.date!);
                        showModalBottomSheet(
                          // ignore: use_build_context_synchronously
                          context: context,
                          builder: (context) => TasksWidget(),
                        );
                      });
                    }
                  },
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        "Today's Events",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (selectedEvents.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No Event found',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: selectedEvents.length,
                      itemBuilder: (context, index) {
                        final event = selectedEvents[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10,
                          ),
                          child: Dismissible(
                            key: Key(event.fromDate.toString()),
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              final provider = Provider.of<EventProvider>(
                                context,
                                listen: false,
                              );
                              provider.deleteSelectedData(event);
                            },
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.green[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: ListTile(
                                  title: Text(
                                    event.title,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    '${event.fromDate.hour.toString().padLeft(2, '0')}:${event.fromDate.minute.toString().padLeft(2, '0')} - ${event.fromDate.add(const Duration(hours: 1)).hour.toString().padLeft(2, '0')}:${event.fromDate.add(const Duration(hours: 1)).minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventSelectorPage()),
          );
        },
        child: Center(child: Text('+', style: TextStyle(fontSize: 30))),
      ),
    );
  }
}
