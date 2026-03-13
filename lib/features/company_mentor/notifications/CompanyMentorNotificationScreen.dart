import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bottom_bar/company_mentor_bottom_bar.dart';

class CompanyMentorNotificationScreen extends StatefulWidget {
  const CompanyMentorNotificationScreen({super.key});

  @override
  State<CompanyMentorNotificationScreen> createState() =>
      _CompanyMentorNotificationScreenState();
}

class _CompanyMentorNotificationScreenState
    extends State<CompanyMentorNotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  String selectedType = "alert";
  String? mentorId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    mentorId = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _tabController.dispose();
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  /// PUBLISH NOTIFICATION
  Future<void> publishNotification() async {
    if (titleController.text.isEmpty || descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a title and description"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (mentorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Mentor not logged in!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      String senderName = "Company Mentor";

      if (mentorId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(mentorId)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>? ?? {};
          senderName = (userData['fullName'] ?? 'Company Mentor').toString();
        }
      }

      await FirebaseFirestore.instance.collection("notifications").add({
        "title": titleController.text,
        "desc": descController.text,
        "type": selectedType,
        "senderName": senderName,
        "senderRole": "Company Mentor",
        "senderId": mentorId, // SECURE: Locks this notice to this mentor
        "target": "students", // Targets their interns
        "createdAt": FieldValue.serverTimestamp(),
      });

      titleController.clear();
      descController.clear();
      
      // Move back to the first tab so they can see their published notice
      _tabController.animateTo(selectedType == "alert" ? 0 : 1);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Notification Published Successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error publishing: $e"), backgroundColor: Colors.red),
      );
    }
  }

  /// OPEN DETAILS SCREEN
  void openDetails(Map<String, dynamic> data, String docId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MentorNotificationDetailsScreen(data: data, docId: docId),
      ),
    );
  }

  /// NOTIFICATION LIST (ONLY SHOWS MENTOR'S OWN POSTS)
  Widget notificationList(String type, IconData icon) {
    if (mentorId == null) return const Center(child: Text("Please log in."));

    return StreamBuilder<QuerySnapshot>(
      // Filter by type AND make sure the mentor only sees their own posts
      stream: FirebaseFirestore.instance
          .collection("notifications")
          .where("type", isEqualTo: type)
          .where("senderId", isEqualTo: mentorId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "You haven't published any ${type}s yet.",
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        // Sort locally by timestamp (newest first)
        docs.sort((a, b) {
          Timestamp? t1 = a["createdAt"] as Timestamp?;
          Timestamp? t2 = b["createdAt"] as Timestamp?;
          if (t1 == null || t2 == null) return 0;
          return t2.compareTo(t1);
        });

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF5F9ED6).withOpacity(0.2),
                  child: Icon(icon, color: const Color(0xFF5F9ED6)),
                ),
                title: Text(
                  data["title"] ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  data["desc"] ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
        title: const Text("Manage Notifications"),
        backgroundColor: const Color(0xFF5F9ED6),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "My Alerts"),
            Tab(text: "My Notices"),
            Tab(text: "Publish"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          /// ALERT TAB
          notificationList("alert", Icons.notifications_active),

          /// NOTICE TAB
          notificationList("notice", Icons.campaign),

          /// PUBLISH TAB
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: "Notification Type",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: const [
                    DropdownMenuItem(value: "alert", child: Text("Urgent Alert")),
                    DropdownMenuItem(value: "notice", child: Text("General Notice")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    hintText: "E.g., Weekly Report Due",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: descController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: "Description",
                    hintText: "Type your message here...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text("Publish Now", style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF5F9ED6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: publishNotification,
                )
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: const CompanyMentorBottomBar(currentIndex: 3),
    );
  }
}

///////////////////////////////////////////////////////////////
/// NOTIFICATION DETAILS & EDIT SCREEN
///////////////////////////////////////////////////////////////

class MentorNotificationDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;

  const MentorNotificationDetailsScreen({
    super.key,
    required this.data,
    required this.docId,
  });

  @override
  State<MentorNotificationDetailsScreen> createState() =>
      _MentorNotificationDetailsScreenState();
}

class _MentorNotificationDetailsScreenState extends State<MentorNotificationDetailsScreen> {
  late TextEditingController titleController;
  late TextEditingController descController;

  String selectedType = "alert";
  bool isEditing = false;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.data["title"]);
    descController = TextEditingController(text: widget.data["desc"]);
    selectedType = widget.data["type"] ?? "alert";
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  /// UPDATE NOTIFICATION
  Future<void> updateNotification() async {
    setState(() => isProcessing = true);

    try {
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
        isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Notification Updated"), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() => isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  /// DELETE NOTIFICATION
  Future<void> deleteNotification() async {
    // Show confirmation dialog before deleting
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Notification?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    try {
      await FirebaseFirestore.instance
          .collection("notifications")
          .doc(widget.docId)
          .delete();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notification Deleted"), backgroundColor: Colors.grey),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Timestamp? ts = widget.data["createdAt"] as Timestamp?;
    String time = "Pending/Just now";

    if (ts != null) {
      DateTime dt = ts.toDate();
      time = "${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5F9ED6),
        title: Text(isEditing ? "Edit Notification" : "Notification Details"),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: deleteNotification,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// PUBLISHER NAME AND ROLE
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
                    "Published by: ${widget.data["senderName"] ?? widget.data["sender"] ?? "Unknown"}",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Designation: ${widget.data["senderRole"] ?? "Company Mentor"}",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            /// DATE INFO
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Published on: $time",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// TYPE SELECTION (EDIT MODE ONLY)
            if (isEditing) ...[
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: "Notification Type"),
                items: const [
                  DropdownMenuItem(value: "alert", child: Text("Alert")),
                  DropdownMenuItem(value: "notice", child: Text("Notice")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
            ],

            /// TITLE
            isEditing
                ? TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(
                    titleController.text,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

            const SizedBox(height: 20),

            /// DESCRIPTION
            isEditing
                ? TextField(
                    controller: descController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Text(
                      descController.text,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),

            const SizedBox(height: 40),

            /// SAVE BUTTON (EDIT MODE ONLY)
            if (isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: isProcessing 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Icon(Icons.save),
                  label: const Text("Save Changes", style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  onPressed: isProcessing ? null : updateNotification,
                ),
              )
          ],
        ),
      ),
    );
  }
}
