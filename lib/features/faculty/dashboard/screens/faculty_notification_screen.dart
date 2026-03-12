import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FacultyNotificationScreen extends StatefulWidget {
  const FacultyNotificationScreen({super.key});

  @override
  State<FacultyNotificationScreen> createState() =>
      _FacultyNotificationScreenState();
}

class _FacultyNotificationScreenState extends State<FacultyNotificationScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  String selectedType = "alert";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  /// Format date
  String formatTime(Timestamp ts) {
    DateTime dt = ts.toDate();
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  /// Notification icon
  IconData getIcon(String type) {
    if (type == "alert") return Icons.warning_amber;
    if (type == "notice") return Icons.campaign;
    return Icons.notifications;
  }

  /// Notification color
  Color getColor(String type) {
    if (type == "alert") return Colors.orange;
    if (type == "notice") return Colors.blue;
    return Colors.grey;
  }

  /// Publish Notification
  Future<void> publishNotification() async {

    if (titleController.text.isEmpty || descController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter title and description")),
      );

      return;
    }

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      String senderName = "Faculty Member";

      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(currentUser.uid)
            .get();
        
        if (userDoc.exists) {
          senderName = userDoc.get('fullName') ?? userDoc.get('name') ?? 'Faculty Member';
        }
      }

      await FirebaseFirestore.instance.collection("notifications").add({
        "title": titleController.text,
        "desc": descController.text,
        "type": selectedType,
        "senderName": senderName,
        "senderRole": "Faculty",
        "target": "all",
        "createdAt": Timestamp.now(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error publishing notification: $e")),
      );
      return;
    }

    titleController.clear();
    descController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notification Published")),
    );
  }

  /// Notification List
  Widget notificationList(String type) {

    return StreamBuilder<QuerySnapshot>(

      stream: FirebaseFirestore.instance
          .collection("notifications")
          .orderBy("createdAt", descending: true)
          .snapshots(),

      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No notifications"));
        }

        /// FILTER BY TYPE
        final docs = snapshot.data!.docs
            .where((doc) =>
                (doc.data() as Map<String, dynamic>)["type"] == type)
            .toList();

        if (docs.isEmpty) {
          return const Center(child: Text("No notifications"));
        }

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

            return InkWell(

              /// OPEN DETAILS DIALOG
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(title),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(message),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Published by: ${data["senderName"] ?? data["sender"] ?? "Unknown"}",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Designation: ${data["senderRole"] ?? data["sender"] ?? ""}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Date: $time",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Close"),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                );
              },

              child: Container(
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
                  children: [

                    /// ICON
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color),
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
                                fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 4),

                          Text(message),

                          const SizedBox(height: 4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "By: ${data["senderName"] ?? data["sender"] ?? "Unknown"}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                time,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Publish Tab
  Widget publishTab() {

    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        children: [

          DropdownButtonFormField(
            value: selectedType,
            items: const [

              DropdownMenuItem(
                value: "alert",
                child: Text("Alert"),
              ),

              DropdownMenuItem(
                value: "notice",
                child: Text("Notice"),
              ),
            ],

            onChanged: (value) {
              setState(() {
                selectedType = value!;
              });
            },

            decoration: const InputDecoration(
              labelText: "Notification Type",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: "Title",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: descController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: "Description",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: publishNotification,
            child: const Text("Publish Notification"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        title: const Text("FACULTY NOTIFICATIONS"),

        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Alerts"),
            Tab(text: "Notices"),
            Tab(text: "Publish"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [

          notificationList("alert"),
          notificationList("notice"),
          publishTab(),

        ],
      ),
    );
  }
}