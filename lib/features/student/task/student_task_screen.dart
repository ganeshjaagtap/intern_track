import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentTaskScreen extends StatelessWidget {
  const StudentTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(title: const Text("Group Tasks"), backgroundColor: const Color(0xFF6BB6FF)),
      body: StreamBuilder<DocumentSnapshot>(
        // 1. Get the student's assigned group ID
        stream: FirebaseFirestore.instance.collection('user').doc(currentUid).snapshots(),
        builder: (context, userSnap) {
          if (!userSnap.hasData) return const Center(child: CircularProgressIndicator());
          
          final userData = userSnap.data!.data() as Map<String, dynamic>?;
          final String? groupId = userData?['assignedGroupId'];

          if (groupId == null) {
            return const Center(child: Text("You are not assigned to a project group yet."));
          }

          // 2. Fetch tasks for this specific group
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tasks')
                .where('assignedToGroupId', isEqualTo: groupId)
                .snapshots(),
            builder: (context, taskSnap) {
              if (!taskSnap.hasData) return const Center(child: CircularProgressIndicator());
              
              var allTasks = taskSnap.data!.docs;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    _buildFirebaseColumn("To Do", "todo", Colors.orange, allTasks),
                    _buildFirebaseColumn("Working", "progress", Colors.blue, allTasks),
                    _buildFirebaseColumn("Done", "done", Colors.green, allTasks),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFirebaseColumn(String title, String status, Color color, List<QueryDocumentSnapshot> docs) {
    final filtered = docs.where((d) => d['status'] == status).toList();

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                var task = filtered[index].data() as Map<String, dynamic>;
                var deadline = (task['deadline'] as Timestamp).toDate();

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(value: task['progress'] ?? 0.0, color: color),
                        const SizedBox(height: 8),
                        Text("Due: ${deadline.day}/${deadline.month}", style: const TextStyle(fontSize: 10, color: Colors.red)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}