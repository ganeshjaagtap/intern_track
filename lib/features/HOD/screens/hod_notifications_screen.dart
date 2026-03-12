import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  /// PUBLISH NOTIFICATION
  Future<void> publishNotification() async {

    if (titleController.text.isEmpty || descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter title and description")),
      );
      return;
    }

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      String senderName = "HOD";

      if (currentUser != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(currentUser.uid)
            .get();
        
        if (userDoc.exists) {
          senderName = userDoc.get('fullName') ?? userDoc.get('name') ?? 'HOD';
        }
      }

      await FirebaseFirestore.instance.collection("notifications").add({
        "title": titleController.text,
        "desc": descController.text,
        "type": selectedType,
        "senderName": senderName,
        "senderRole": "HOD",
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

  /// OPEN DETAILS SCREEN
  void openDetails(Map<String, dynamic> data, String docId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NotificationDetailsScreen(data: data, docId: docId),
      ),
    );
  }

  /// NOTIFICATION LIST
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

            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                leading: Icon(icon),
                title: Text(data["title"] ?? ""),
                subtitle: Text(data["desc"] ?? ""),
                onTap: () => openDetails(data, doc.id),
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

          /// ALERT TAB
          notificationList("alert", Icons.notifications),

          /// NOTICE TAB
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
/// NOTIFICATION DETAILS SCREEN
///////////////////////////////////////////////////////////////

class NotificationDetailsScreen extends StatefulWidget {

  final Map<String, dynamic> data;
  final String docId;

  const NotificationDetailsScreen({
    super.key,
    required this.data,
    required this.docId,
  });

  @override
  State<NotificationDetailsScreen> createState() =>
      _NotificationDetailsScreenState();
}

class _NotificationDetailsScreenState extends State<NotificationDetailsScreen> {

  late TextEditingController titleController;
  late TextEditingController descController;

  String selectedType = "alert";
  bool isEditing = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.data["title"]);
    descController = TextEditingController(text: widget.data["desc"]);
    selectedType = widget.data["type"] ?? "alert";
  }

  /// UPDATE NOTIFICATION
  Future<void> updateNotification() async {

    await FirebaseFirestore.instance
        .collection("notifications")
        .doc(widget.docId)
        .update({
      "title": titleController.text,
      "desc": descController.text,
      "type": selectedType,
    });

    setState(() {
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notification Updated")),
    );
  }

  /// DELETE NOTIFICATION
  Future<void> deleteNotification() async {

    await FirebaseFirestore.instance
        .collection("notifications")
        .doc(widget.docId)
        .delete();

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Notification Deleted")),
    );
  }

  @override
  Widget build(BuildContext context) {

    Timestamp? ts = widget.data["createdAt"];
    String time = "";

    if (ts != null) {
      DateTime dt = ts.toDate();
      time = "${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute}";
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Notification Details"),
        actions: [

          /// EDIT BUTTON
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: (){
              setState(() {
                isEditing = true;
              });
            },
          ),

          /// DELETE BUTTON
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteNotification,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE
            isEditing
                ? TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                    ),
                  )
                : Text(
                    titleController.text,
                    style: const TextStyle(
                      fontSize:22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

            const SizedBox(height:10),

            /// Publisher Name
            Text(
              "Sent by: ${widget.data["senderName"] ?? widget.data["sender"] ?? "Unknown"}",
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 4),

            /// Publisher Role/Designation
            Text(
              "Role: ${widget.data["senderRole"] ?? widget.data["sender"] ?? ""}",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),

            const SizedBox(height:20),

            /// DESCRIPTION
            isEditing
                ? TextField(
                    controller: descController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Description",
                    ),
                  )
                : Text(
                    descController.text,
                    style: const TextStyle(fontSize:16),
                  ),

            const SizedBox(height:20),

            /// TYPE
            if (isEditing)
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
              ),

            const SizedBox(height:20),

            Text(
              time,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height:40),

            /// SAVE BUTTON
            if (isEditing)
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save Changes"),
                  onPressed: updateNotification,
                ),
              )
          ],
        ),
      ),
    );
  }
}