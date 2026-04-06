import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentDetailsScreen extends StatelessWidget {
  final Map<String, String> student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Information",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Profile Header Section
            Center(
              child: Column(
                children: [
                  StreamBuilder<DocumentSnapshot>(
                    stream: (student["docId"] ?? "").isEmpty
                        ? null
                        : FirebaseFirestore.instance
                            .collection('user')
                            .doc(student["docId"])
                            .snapshots(),
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                      final imageUrl = (data["profileImageUrl"] ?? "").toString();

                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue.shade50,
                        backgroundImage: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : null,
                        child: imageUrl.isEmpty
                            ? Text(
                                (student["name"] ?? "S")[0].toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 40, 
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue),
                              )
                            : null,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    student["name"] ?? "N/A",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Roll No: ${student["roll"] ?? 'N/A'}",
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// Student Information Section
            _sectionHeader("Personal Details"),
            _infoRow("Department", student["dept"]),
            _infoRow("Email", student["email"]),
            _infoRow("Phone", student["phone"]),

            const SizedBox(height: 25),

            /// Internship Details Section
            _sectionHeader("Internship Details"),
            _infoRow("Company", student["company"]),
            _infoRow("Role", student["role"]),
            _infoRow("Type", student["type"]),
            _infoRow("Duration", "${student["start"]} to ${student["end"]}"),
            _statusRow("Status", student["status"]),
            
            // ✅ Attendance Highlighted
            _attendanceRow(student["roll"]),

            const SizedBox(height: 25),

            /// Mentor Details Section
            _sectionHeader("Mentor Coordination"),
            // ✅ Displays Mentor Name (ID is hidden)
            _collegeMentorRow(student["facultyId"], student["collegeMentor"]),
            _infoRow("Company Mentor", student["companyMentor"]),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _attendanceRow(String? enrollmentNo) {
    final normalizedEnrollment = (enrollmentNo ?? "").trim();

    if (normalizedEnrollment.isEmpty || normalizedEnrollment == "N/A") {
      return _infoRow("Attendance", "0%", isHighlight: true);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendance')
          .doc(normalizedEnrollment)
          .collection('records')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _infoRow("Attendance", "...", isHighlight: true);
        }

        int presentCount = 0;
        int totalCount = 0;

        for (final doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>? ?? {};
          final status = (data['status'] ?? '').toString().trim().toLowerCase();

          if (status == 'present') {
            presentCount++;
          }

          if (status == 'present' || status == 'absent' || status == 'leave') {
            totalCount++;
          }
        }

        final percentage = totalCount == 0
            ? 0
            : ((presentCount / totalCount) * 100).round();

        return _infoRow("Attendance", "$percentage%", isHighlight: true);
      },
    );
  }

  Widget _collegeMentorRow(String? facultyId, String? initialFacultyName) {
    final normalizedFacultyId = (facultyId ?? '').trim();
    final fallbackName = (initialFacultyName ?? '').trim();

    if (normalizedFacultyId.isEmpty) {
      return _infoRow(
        "College Mentor",
        fallbackName.isEmpty ? "Not Assigned" : fallbackName,
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 'faculty')
          .where('facultyId', isEqualTo: normalizedFacultyId)
          .snapshots(),
      builder: (context, snapshot) {
        var mentorName = fallbackName.isEmpty ? "Not Assigned" : fallbackName;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final mentorData =
              snapshot.data!.docs.first.data() as Map<String, dynamic>? ?? {};
          mentorName = (mentorData['fullName'] ??
                  mentorData['name'] ??
                  mentorData['facultyName'] ??
                  mentorName)
              .toString()
              .trim();
        }

        return _infoRow("College Mentor", mentorName);
      },
    );
  }

  /// Category Header Styling
  Widget _sectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF6BB6FF),
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.1,
          ),
        ),
        const Divider(thickness: 1, height: 20),
      ],
    );
  }

  /// Professional Label-Value Row
  Widget _infoRow(String label, String? value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                color: isHighlight ? Colors.green.shade700 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Status Row with Dynamic Colors
  Widget _statusRow(String label, String? status) {
    Color statusColor = Colors.grey;
    if (status == "Active" || status == "Ongoing") statusColor = Colors.green;
    else if (status == "Completed") statusColor = Colors.blue;
    else if (status == "Pending") statusColor = Colors.orange;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status ?? "-",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
