// ignore_for_file: non_constant_identifier_names, avoid_unnecessary_containers, prefer_const_constructors, library_private_types_in_public_api, annotate_overrides, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DateTime today = DateTime.now();
  DateTime? _selectedDay;

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
            )
          ],
        ),
      ),
    );
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

  Widget Content() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text("Selected Date: " + today.toString().split(" ")[0]),
          Container(
            child: TableCalendar(
              // locale: 'en_US',
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
            ),
          ),
        ],
      ),
    );
  }
}
