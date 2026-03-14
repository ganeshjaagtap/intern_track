import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompanyTaskScreen extends StatelessWidget {
  const CompanyTaskScreen({super.key});

  // --- Helper: Get Status Color ---
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified': return Colors.teal;
      case 'completed': return Colors.green;
      case 'in progress': return Colors.orange;
      case 'todo': return Colors.blue;
      default: return Colors.grey;
    }
  }

  // --- Logic: Update Firestore Status ---
  Future<void> _updateStatus(BuildContext context, String docId, String newStatus) async {
    await FirebaseFirestore.instance.collection('tasks').doc(docId).update({
      'status': newStatus,
      // We clear the rejection reason when the student attempts to fix it/resubmit
      'rejectionReason': FieldValue.delete(), 
    });
    Navigator.pop(context); // Close the popup
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Please log in again.")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF5F9ED6),
        title: const Text("Assigned Tasks", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
            return const Center(child: Text("No tasks assigned by mentor yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final taskDoc = docs[index];
              final task = taskDoc.data() as Map<String, dynamic>;
              final String status = task['status'] ?? "todo";
              final String docId = taskDoc.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  onTap: () => _showTaskDetails(context, task, docId),
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(status).withOpacity(0.1),
                    child: Icon(
                      status == 'verified' ? Icons.verified : Icons.assignment,
                      color: _getStatusColor(status),
                    ),
                  ),
                  title: Text(task['title'] ?? "No Title", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Status: ${status.toUpperCase()}", 
                    style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.w600, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Map<String, dynamic> task, String docId) {
    final String status = task['status'] ?? "todo";
    final bool isLocked = status == 'verified';
    final String? rejectionReason = task['rejectionReason'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 25),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Task Info", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  if (isLocked)
                    const Chip(
                      label: Text("VERIFIED", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                      backgroundColor: Colors.teal,
                    ),
                ],
              ),
              const SizedBox(height: 15),
              Text(task['title'] ?? "", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF5F9ED6))),
              const SizedBox(height: 10),
              Text(task['description'] ?? "", style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.5)),
              
              // --- REJECTION REASON SECTION ---
              if (rejectionReason != null && !isLocked) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text("Mentor Feedback (Rejection Reason):", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(rejectionReason, style: TextStyle(color: Colors.red.shade900, fontSize: 14)),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),

              if (isLocked)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text("This task has been verified and cannot be modified.", 
                      style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  ),
                )
              else ...[
                const Text("Update Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _statusButton(context, docId, "Todo", status == "todo"),
                    const SizedBox(width: 10),
                    _statusButton(context, docId, "In Progress", status == "in progress"),
                    const SizedBox(width: 10),
                    _statusButton(context, docId, "Completed", status == "completed"),
                  ],
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _statusButton(BuildContext context, String docId, String label, bool isActive) {
    Color color = _getStatusColor(label);
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _updateStatus(context, docId, label.toLowerCase()),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? color : Colors.white,
          foregroundColor: isActive ? Colors.white : color,
          elevation: isActive ? 2 : 0,
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }
}