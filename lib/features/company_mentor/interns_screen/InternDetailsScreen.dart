import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../chat/ChatScreen.dart';

class InternDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> studentData; // Pass dynamic data here

  const InternDetailsScreen({super.key, required this.studentData});

  @override
  Widget build(BuildContext context) {
    final String name = studentData['fullName'] ?? "Unnamed";
    final String college = studentData['college_name'] ?? "N/A";
    final String role = studentData['internshipRole'] ?? "Intern";
    final String facultyId = studentData['facultyId'] ?? "";
    final double progressValue = (studentData['totalProgress'] ?? 0.0).toDouble();

    return Scaffold(
      appBar: AppBar(title: const Text("Intern Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// PROFILE CARD
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Text(name[0].toUpperCase(), style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(college),
                          Text(role, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text("${(progressValue * 100).toInt()}%", 
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text("Attendance Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildAttendanceCard(), // You can pass actual attendance data here

            const SizedBox(height: 20),
            const Text("Internship Progress", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            progressTile("Overall Completion", progressValue),

            const SizedBox(height: 20),
            const Text("College Mentor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            /// ✅ DYNAMIC COLLEGE MENTOR FETCH
            _fetchCollegeMentor(facultyId),

            const SizedBox(height: 20),
            const Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            activityTile("No recent activities logged."),
          ],
        ),
      ),
    );
  }

  Widget _fetchCollegeMentor(String fId) {
    if (fId.isEmpty) return const Text("No College Mentor Assigned.");
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 'faculty')
          .where('facultyId', isEqualTo: fId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("Mentor details not found.");
        final mentor = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final String mName = mentor['fullName'] ?? "Mentor";

        return Card(
          child: ListTile(
            leading: const Icon(Icons.school, color: Colors.blue),
            title: Text(mName),
            subtitle: Text(mentor['email'] ?? ""),
            trailing: IconButton(
              icon: const Icon(Icons.message, color: Colors.blue),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ChatScreen(title: mName),
                ));
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _stat("Total", "30"),
            _stat("Present", "27"),
            _stat("Absent", "3"),
          ],
        ),
      ),
    );
  }

  Widget progressTile(String title, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: progress, minHeight: 8, borderRadius: BorderRadius.circular(6)),
      ],
    );
  }

  Widget activityTile(String text) {
    return ListTile(
      leading: const Icon(Icons.check_circle, color: Colors.green),
      title: Text(text),
    );
  }
}

class _stat extends StatelessWidget {
  final String label, value;
  const _stat(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    ]);
  }
}