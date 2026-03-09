import 'package:flutter/material.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final reminders = [
      {"title": "Project Review", "date": "12 Feb 2026"},
      {"title": "Faculty Meeting", "date": "15 Feb 2026"},
      {"title": "Student Presentation", "date": "20 Feb 2026"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reminders"),
      ),
      body: ListView.builder(
        itemCount: reminders.length,
        itemBuilder: (context, index) {

          final reminder = reminders[index];

          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.event),
              title: Text(reminder["title"]!),
              subtitle: Text(reminder["date"]!),
            ),
          );
        },
      ),
    );
  }
}