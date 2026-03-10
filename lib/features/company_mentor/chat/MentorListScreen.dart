import 'package:flutter/material.dart';
import 'ChatScreen.dart';

class MentorListScreen extends StatelessWidget {
  const MentorListScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final List<String> mentors = [
      "Prof. Sudhir Cavan",
      "Prof. R. S. Sindge",
      "Prof. M. B. Dahival",
      "Prof. J. V. Patil",
    ];

    return Scaffold(

      appBar: AppBar(
        title: const Text("College Mentors"),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),

        itemCount: mentors.length,

        itemBuilder: (context, index) {

          final mentor = mentors[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),

            child: ListTile(

              leading: CircleAvatar(
                child: Text(mentor[0]),
              ),

              title: Text(
                mentor,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: const Text("College Mentor"),

              trailing: const Icon(Icons.arrow_forward_ios, size: 16),

              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(title: mentor),
                  ),
                );

              },
            ),
          );
        },
      ),
    );
  }
}