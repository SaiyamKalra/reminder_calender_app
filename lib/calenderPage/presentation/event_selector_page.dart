import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_calender_app/calenderPage/domain/event.dart';
import 'package:reminder_calender_app/calenderPage/provider/event_provider.dart';
import 'package:reminder_calender_app/utils/custom_text_field.dart';

class EventSelectorPage extends StatefulWidget {
  final Event? event;
  const EventSelectorPage({super.key, this.event});

  @override
  State<EventSelectorPage> createState() => _EventSelectorPageState();
}

class _EventSelectorPageState extends State<EventSelectorPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  late DateTime fromDate;
  late TimeOfDay fromTime;

  @override
  void initState() {
    super.initState();
    if (widget.event == null) {
      fromDate = DateTime.now();
      // toDate = DateTime.now();
    } else {
      fromDate = widget.event!.fromDate;
      // toDate = widget.event!.toDate;
    }
    // Initialize fromTime from the full DateTime object
    fromTime = TimeOfDay.fromDateTime(fromDate);
  }

  // Inside _EventSelectorPageState
  Widget buildDateDropdownField({required String label}) {
    // We use DateFormat for robust date display, but using .split(' ')[0] is okay for simple cases
    String formattedDate = '${fromDate.toLocal()}'.split(' ')[0];

    return GestureDetector(
      onTap: () {
        buildDatePicker();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(8),
          color: Colors.green[300],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formattedDate, style: const TextStyle(color: Colors.white)),
            const Icon(Icons.calendar_today, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget buildTimeDropDown() {
    return GestureDetector(
      onTap: () {
        buildTimePicker();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green[300],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              fromTime.format(context),
              style: const TextStyle(color: Colors.white),
            ),
            const Icon(Icons.access_time, color: Colors.white),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 51, 51, 51),
      appBar: AppBar(centerTitle: true, title: const Text('Event Page')),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    CustomTextField(
                      controller: _titleController,
                      obscureText: false,
                      labeltext: 'Title',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                textAlign: TextAlign.start,
                                'Date',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: buildDateDropdownField(label: 'Date'),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: buildTimeDropDown()),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    CustomTextField(
                      controller: _descriptionController,
                      obscureText: false,
                      hintText: 'Description',
                      maxLine: 5,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          Container(
            height: 50,
            color: Colors.grey[700],
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'C A N C E L',
                    style: TextStyle(color: Colors.green[300]),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    saveForm();
                  },
                  child: Text(
                    'S A V E',
                    style: TextStyle(color: Colors.green[300]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> buildDatePicker() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    setState(() {
      fromDate = DateTime(
        date.year,
        date.month,
        date.day,
        fromTime.hour,
        fromTime.minute,
      );
    });
  }

  Future<void> buildTimePicker() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: fromTime,
    );
    if (time == null) return;
    setState(() {
      fromTime = time;
      fromDate = DateTime(
        fromDate.year,
        fromDate.month,
        fromDate.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future saveForm() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      final event = Event(
        title: _titleController.text,
        description: _descriptionController.text,
        fromDate: fromDate,
        createdAt: DateTime.now(),
      );
      if (kDebugMode) {
        print(event);
      }
      final provider = Provider.of<EventProvider>(context, listen: false);
      provider.addEvent(event);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the necessary data to proceed')),
      );
    }
  }
}
