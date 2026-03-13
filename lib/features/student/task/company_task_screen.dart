import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CompanyTaskScreen extends StatelessWidget {
  const CompanyTaskScreen({super.key});

  // --- Helper: Get Status Color ---
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'in progress': return Colors.orange;
      default: return Colors.blue;
    }
  }

  // --- Logic: Update Firestore Status ---
  Future<void> _updateStatus(BuildContext context, String docId, String newStatus) async {
    await FirebaseFirestore.instance.collection('tasks').doc(docId).update({
      'status': newStatus,
    });
    Navigator.pop(context); // Close the popup
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Session expired. Please log in again.")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF5F9ED6),
        title: const Text("My Tasks", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('assignedToStudentId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("No tasks assigned yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final taskDoc = docs[index];
              final task = taskDoc.data() as Map<String, dynamic>;
              final String status = task['status'] ?? "todo";
              final String docId = taskDoc.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => _showTaskDetails(context, task, docId),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // Status Color Bar
                          Container(
                            width: 6,
                            decoration: BoxDecoration(
                              color: _getStatusColor(status),
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        status.toUpperCase(),
                                        style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1),
                                      ),
                                      const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(task['title'] ?? "No Title", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(
                                    task['description'] ?? "",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- POPUP: Task Details & Modify State ---
  void _showTaskDetails(BuildContext context, Map<String, dynamic> task, String docId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              const Text("Task Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(task['title'] ?? "", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF5F9ED6))),
              const SizedBox(height: 12),
              Text(task['description'] ?? "No additional details provided.", style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5)),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text("Update Progress", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statusButton(context, docId, "Todo", Colors.blue),
                  _statusButton(context, docId, "In Progress", Colors.orange),
                  _statusButton(context, docId, "Completed", Colors.green),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusButton(BuildContext context, String docId, String label, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: () => _updateStatus(context, docId, label.toLowerCase()),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}