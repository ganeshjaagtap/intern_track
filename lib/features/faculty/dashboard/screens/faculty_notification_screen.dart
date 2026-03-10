import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

    await FirebaseFirestore.instance.collection("notifications").add({

      "title": titleController.text,
      "desc": descController.text,
      "type": selectedType,
      "sender": "Faculty",
      "target": "all",
      "createdAt": Timestamp.now(),

    });

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

              /// OPEN POPUP
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(title),
                    content: Text(message),
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

                          Text(
                            time,
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey),
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