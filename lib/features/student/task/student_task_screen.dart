import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentTaskScreen extends StatelessWidget {
  const StudentTaskScreen({super.key});

  // Helper to update task status/progress
  Future<void> _updateTask(String taskId, String newStatus, double newProgress) async {
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'status': newStatus,
      'progress': newProgress,
    });
  }

  void _showTaskActionDialog(BuildContext context, String taskId, String currentStatus, double currentProgress, String title, String description) {
    double tempProgress = currentProgress;
    String tempStatus = currentStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 20),
              const Text("Update Status:", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: tempStatus,
                isExpanded: true,
                items: ["todo", "progress", "done"].map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
                onChanged: (val) => setDialogState(() => tempStatus = val!),
              ),
              const SizedBox(height: 20),
              Text("Progress: ${(tempProgress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
              Slider(
                value: tempProgress,
                onChanged: (val) => setDialogState(() => tempProgress = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                _updateTask(taskId, tempStatus, tempProgress);
                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(title: const Text("Group Tasks"), backgroundColor: const Color(0xFF6BB6FF)),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('user').doc(currentUid).snapshots(),
        builder: (context, userSnap) {
          if (!userSnap.hasData) return const Center(child: CircularProgressIndicator());
          final userData = userSnap.data!.data() as Map<String, dynamic>?;
          final String? groupId = userData?['assignedGroupId'];

          if (groupId == null) {
            return const Center(child: Text("You are not assigned to a project group yet."));
          }

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
                    _buildFirebaseColumn(context, "To Do", "todo", Colors.orange, allTasks),
                    _buildFirebaseColumn(context, "Working", "progress", Colors.blue, allTasks),
                    _buildFirebaseColumn(context, "Done", "done", Colors.green, allTasks),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFirebaseColumn(BuildContext context, String title, String status, Color color, List<QueryDocumentSnapshot> docs) {
    final filtered = docs.where((d) => d['status'] == status).toList();

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                var taskDoc = filtered[index];
                var task = taskDoc.data() as Map<String, dynamic>;
                var deadline = (task['deadline'] as Timestamp).toDate();
                String description = task['description'] ?? "No description provided";

                return GestureDetector(
                  onTap: () => _showTaskActionDialog(context, taskDoc.id, task['status'], (task['progress'] as num).toDouble(), task['title'], description),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['title'], 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // 🔹 ADDED DESCRIPTION HERE
                          Text(
                            description,
                            style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: (task['progress'] as num).toDouble(),
                            color: color,
                            backgroundColor: color.withOpacity(0.1),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 12, color: Colors.red),
                              const SizedBox(width: 4),
                              Text("${deadline.day}/${deadline.month}", style: const TextStyle(fontSize: 10, color: Colors.red)),
                            ],
                          ),
                        ],
                      ),
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