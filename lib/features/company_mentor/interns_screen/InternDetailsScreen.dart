import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../chat/ChatScreen.dart';

class InternDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> studentData;

  const InternDetailsScreen({super.key, required this.studentData});

  // --- Helper: Safely parse dates ---
  DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Extract IDs and College Details
    final String studentUid = studentData['uid']?.toString() ?? ""; 
    final String enrollmentNo = studentData['enrollmentNo']?.toString() ?? studentUid;
    final String name = studentData['fullName']?.toString() ?? "Unnamed Intern";
    final String profileImageUrl = studentData['profileImageUrl']?.toString() ?? "";
    
    // ✅ FIX: Specifically fetching the college name string
    final String college = studentData['college_name']?.toString() ?? "Government Polytechnic College Aurangabad";
    
    final String role = studentData['internshipRole']?.toString() ?? "Intern";
    final String facultyId = studentData['facultyId']?.toString() ?? "";

    // 2. Timeline Logic
    DateTime startDate = _parseDate(studentData['startDate']);
    DateTime endDate = _parseDate(studentData['endDate']);
    DateTime today = DateTime.now();

    int totalInternshipDays = endDate.difference(startDate).inDays;
    if (totalInternshipDays <= 0) totalInternshipDays = 1;

    int daysPassedSoFar = today.isAfter(endDate) 
        ? totalInternshipDays 
        : today.difference(startDate).inDays;
    if (daysPassedSoFar < 0) daysPassedSoFar = 0;

    double timelinePercent = (daysPassedSoFar / totalInternshipDays).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      appBar: AppBar(
        title: const Text("Intern Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF5F9ED6),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. PROFILE HEADER (Showing your College String)
            _buildProfileHeader(name, college, role, profileImageUrl),
            const SizedBox(height: 24),
            
            _sectionTitle("Internship Timeline"),
            const SizedBox(height: 12),
            _buildTimelineCard(startDate, endDate, daysPassedSoFar, totalInternshipDays, timelinePercent),

            const SizedBox(height: 24),
            _sectionTitle("Attendance Analysis"),
            const SizedBox(height: 12),
            
            /// 2. DYNAMIC ATTENDANCE (Using Past Attendance Logic)
            _buildCalculatedAttendance(enrollmentNo, daysPassedSoFar),

            const SizedBox(height: 24),
            _sectionTitle("College Mentor"),
            const SizedBox(height: 12),
            _fetchCollegeMentor(context, facultyId),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- ATTENDANCE LOGIC: Path -> attendance -> enrollmentNo -> records ---
  Widget _buildCalculatedAttendance(String enrollmentNo, int daysPassedSoFar) {
    if (enrollmentNo.isEmpty) return const Text("Enrollment number not found.");

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendance')
          .doc(enrollmentNo)
          .collection('records')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: LinearProgressIndicator());
        }

        int presentCount = 0;
        int leaveCount = 0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            String status = (data['status'] ?? "").toString().toLowerCase().trim();
            
            if (status == 'present') presentCount++;
            if (status == 'leave') leaveCount++;
          }
        }

        // Logic: Absent = Days Passed - (Present + Leave)
        int absentCount = daysPassedSoFar - (presentCount + leaveCount);
        if (absentCount < 0) absentCount = 0; 

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat("Present", "$presentCount", Colors.green),
              _stat("Absent", "$absentCount", Colors.redAccent),
              _stat("Leave", "$leaveCount", Colors.blue),
            ],
          ),
        );
      },
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildProfileHeader(String name, String college, String role, String profileImageUrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFF5F9ED6).withOpacity(0.1),
            backgroundImage: profileImageUrl.isNotEmpty
                ? NetworkImage(profileImageUrl)
                : null,
            child: profileImageUrl.isEmpty
                ? Text(name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF5F9ED6)))
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                // ✅ This displays the College Name from Firebase
                Text(college, style: const TextStyle(color: Colors.grey, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(role, style: const TextStyle(color: Color(0xFF5F9ED6), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(DateTime start, DateTime end, int passed, int total, double percent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dateLabel("Start", DateFormat('dd MMM yyyy').format(start)),
              _dateLabel("End", DateFormat('dd MMM yyyy').format(end)),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: percent,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: Colors.grey.shade100,
            color: const Color(0xFF5F9ED6),
          ),
          const SizedBox(height: 12),
          Text("$passed / $total Days Completed", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget _fetchCollegeMentor(BuildContext context, String fId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('user').where('facultyId', isEqualTo: fId).where('role', isEqualTo: 'faculty').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Text("No Mentor Assigned.");
        final mentor = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final mentorImageUrl = (mentor['profileImageUrl'] ?? '').toString();
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: mentorImageUrl.isNotEmpty
                  ? NetworkImage(mentorImageUrl)
                  : null,
              child: mentorImageUrl.isEmpty
                  ? const Icon(Icons.school, color: Colors.blue)
                  : null,
            ),
            title: Text(mentor['fullName'] ?? "Mentor", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Text(mentor['department'] ?? "Faculty", style: const TextStyle(fontSize: 12)),
            trailing: IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF5F9ED6)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(title: mentor['fullName']))),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3243)));

  Widget _dateLabel(String label, String date) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)), Text(date, style: const TextStyle(fontWeight: FontWeight.bold))]);

  Widget _stat(String label, String value, Color color) => Column(children: [Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)), Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: color))]);
}
