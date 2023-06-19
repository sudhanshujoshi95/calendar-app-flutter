// ignore_for_file: non_constant_identifier_names, avoid_unnecessary_containers, prefer_const_constructors, library_private_types_in_public_api, annotate_overrides, prefer_interpolation_to_compose_strings, depend_on_referenced_packages, unused_import

import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Flutter Local Notifications
  initializeNotifications();

  runApp(MaterialApp(
    home: MyApp(),
  ));
}

void initializeNotifications() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  _MyAppState createState() => _MyAppState();
}

class Event {
  final DateTime date;
  final String title;
  final String description;

  Event({
    required this.date,
    required this.title,
    required this.description,
  });
}

class _MyAppState extends State<MyApp> {
  DateTime today = DateTime.now();
  DateTime? _selectedDay;
  List<Event> events = [];

  final titleController = TextEditingController();
  final descpController = TextEditingController();

  showAddEventDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add New Event',
          textAlign: TextAlign.center,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            TextField(
              controller: descpController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              addEvent();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void addEvent() {
    final title = titleController.text;
    final description = descpController.text;

    if (title.isNotEmpty && description.isNotEmpty && _selectedDay != null) {
      final event = Event(
        date: _selectedDay!,
        title: title,
        description: description,
      );

      setState(() {
        events.add(event);
        scheduleReminder(event);
      });
    }
  }

  void scheduleReminder(Event event) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    tz.initializeTimeZones();

    tz.TZDateTime eventDateTime = tz.TZDateTime.from(
      event.date,
      tz.getLocation('Asia/Mumbai'),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      event.title,
      event.description,
      eventDateTime.subtract(const Duration(minutes: 30)),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }

  Widget Content() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text("Selected Date: " + today.toString().split(" ")[0]),
          Container(
            child: TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: today,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    today = focusedDay;
                  });
                }
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              eventLoader: (day) => getEventsForDay(day),
            ),
          ),
          const SizedBox(height: 20),
          if (_selectedDay != null)
            Column(
              children: [
                Text(
                  "Events on ${_selectedDay.toString().split(" ")[0]}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Column(
                  children: getEventsForDay(_selectedDay!)
                      .map(
                        (event) => ListTile(
                          title: Text(event.title),
                          subtitle: Text(event.description),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  List<Event> getEventsForDay(DateTime day) {
    return events.where((event) => isSameDay(event.date, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Schedule",
          ),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: Content(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddEventDialog(),
        label: Icon(
          Icons.add,
        ),
        backgroundColor: Colors.blue[900],
      ),
    );
  }
}

class Future {}
