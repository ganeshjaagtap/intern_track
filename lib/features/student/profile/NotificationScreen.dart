import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  /// Convert Timestamp → readable date
  String formatTime(Timestamp ts) {
    DateTime dt = ts.toDate();
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  /// Icon based on type
  IconData getIcon(String type) {
    if (type == "alert") return Icons.warning_amber;
    if (type == "notice") return Icons.campaign;
    return Icons.notifications;
  }

  /// Color based on type
  Color getColor(String type) {
    if (type == "alert") return Colors.orange;
    if (type == "notice") return Colors.blue;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      /// APPBAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        title: const Text(
          "NOTIFICATIONS",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      /// BODY
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("notifications")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _emptyState();
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final data = docs[index].data() as Map<String, dynamic>;

              final title = data["title"] ?? "";
              final message = data["desc"] ?? "";
              final type = data["type"] ?? "";
              final ts = data["createdAt"];

              final icon = getIcon(type);
              final color = getColor(type);

              final time = ts != null ? formatTime(ts) : "";

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StudentNotificationDetailsScreen(data: data),
                    ),
                  );
                },
                child: _notificationCard(
                  title,
                  message,
                  time,
                  icon,
                  color,
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Notification Card UI
  Widget _notificationCard(
    String title,
    String message,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ICON
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),

          const SizedBox(width: 12),

          /// CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  message,
                  style: const TextStyle(fontSize: 13),
                ),

                const SizedBox(height: 6),

                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Empty State
  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "No notifications yet",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            "You're all caught up 🎉",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// Notification Details Screen
///////////////////////////////////////////////////////////////

class StudentNotificationDetailsScreen extends StatelessWidget {

  final Map<String, dynamic> data;

  const StudentNotificationDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {

    Timestamp? ts = data["createdAt"];
    String time = "";

    if (ts != null) {
      DateTime dt = ts.toDate();
      time = "${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute}";
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Notification Details"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Title
            Text(
              data["title"] ?? "",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            /// Sender
            Text(
              "Sent by: ${data["sender"] ?? ""}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            /// Description
            Text(
              data["desc"] ?? "",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            /// Time
            Text(
              time,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}