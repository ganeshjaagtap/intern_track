import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HodNotificationsScreen extends StatefulWidget {
  const HodNotificationsScreen({super.key});

  @override
  State<HodNotificationsScreen> createState() => _HodNotificationsScreenState();
}

class _HodNotificationsScreenState extends State<HodNotificationsScreen>
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

  /// Publish Notification
  Future<void> publishNotification() async {

    if (titleController.text.isEmpty || descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter title and description")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("notifications").add({
      "title": titleController.text,
      "desc": descController.text,
      "type": selectedType,
      "sender": "HOD",
      "target": "all",
      "createdAt": Timestamp.now(),
    });

    titleController.clear();
    descController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notification Published")),
    );
  }

  /// Open notification details
  void openDetails(Map<String, dynamic> data, String docId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NotificationDetailsScreen(data: data, docId: docId),
      ),
    );
  }

  /// Notification List
  Widget notificationList(String type, IconData icon) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("notifications")
          .where("type", isEqualTo: type)
          .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading notifications"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No notifications found"));
        }

        final docs = snapshot.data!.docs;

        docs.sort((a, b) {
          Timestamp t1 = a["createdAt"];
          Timestamp t2 = b["createdAt"];
          return t2.compareTo(t1);
        });

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {

            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final docId = doc.id;

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: Icon(icon),
                title: Text(data["title"] ?? ""),
                subtitle: Text(data["desc"] ?? ""),
                onTap: () => openDetails(data, docId),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Notifications"),
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

          /// ALERTS
          notificationList("alert", Icons.notifications),

          /// NOTICES
          notificationList("notice", Icons.campaign),

          /// PUBLISH TAB
          Padding(
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
                  onChanged: (value){
                    setState(() {
                      selectedType = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Notification Type",
                  ),
                ),

                const SizedBox(height:20),

                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height:20),

                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height:20),

                ElevatedButton(
                  onPressed: publishNotification,
                  child: const Text("Publish Notification"),
                )

              ],
            ),
          )

        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////
/// Notification Details Screen
///////////////////////////////////////////////////////////////

class NotificationDetailsScreen extends StatelessWidget {

  final Map<String, dynamic> data;
  final String docId;

  const NotificationDetailsScreen({
    super.key,
    required this.data,
    required this.docId,
  });

  /// Delete notification
  Future<void> deleteNotification(BuildContext context) async {

    await FirebaseFirestore.instance
        .collection("notifications")
        .doc(docId)
        .delete();

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notification deleted")),
    );
  }

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

            Text(
              data["title"] ?? "",
              style: const TextStyle(
                fontSize:22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height:10),

            Text(
              "Sent by: ${data["sender"] ?? ""}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height:20),

            Text(
              data["desc"] ?? "",
              style: const TextStyle(fontSize:16),
            ),

            const SizedBox(height:20),

            Text(
              time,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height:40),

            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text("Delete Notification"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => deleteNotification(context),
              ),
            )
          ],
        ),
      ),
    );
  }
}