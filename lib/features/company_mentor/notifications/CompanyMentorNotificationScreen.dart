import 'package:flutter/material.dart';

class CompanyMentorNotificationScreen extends StatelessWidget {
  const CompanyMentorNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Notifications"),
      ),

      body: ListView(

        padding: const EdgeInsets.all(16),

        children: const [

          NotificationTile(
            icon: Icons.description,
            title: "New Report Submitted",
            subtitle: "John Doe submitted Week 8 report",
            color: Colors.redAccent,
            time: "5 min ago",
          ),

          NotificationTile(
            icon: Icons.check_circle,
            title: "Module Completed",
            subtitle: "Database Integration finished",
            color: Colors.green,
            time: "30 min ago",
          ),

          NotificationTile(
            icon: Icons.rate_review,
            title: "Feedback Requested",
            subtitle: "UI Module requires mentor review",
            color: Colors.orange,
            time: "1 hour ago",
          ),

          NotificationTile(
            icon: Icons.person,
            title: "New Intern Assigned",
            subtitle: "A new intern joined your team",
            color: Colors.blue,
            time: "Yesterday",
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////
// Notification Tile
//////////////////////////////////////////////////////

class NotificationTile extends StatelessWidget {

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String time;

  const NotificationTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.only(bottom: 14),

      child: ListTile(

        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),

        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(subtitle),

        trailing: Text(
          time,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}