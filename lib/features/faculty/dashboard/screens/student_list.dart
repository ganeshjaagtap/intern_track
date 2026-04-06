import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/features/faculty/dashboard/screens/student_detail_screen.dart';

class StudentListScreen extends StatefulWidget {
  final String department;

  const StudentListScreen({super.key, this.department = "IT"});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// ✅ UPDATED: Capturing all info for the Student Information Screen
  Map<String, String> _prepareStudentData(Map<String, dynamic> data, String id) {
    Map<String, String> result = {'docId': id};
    
    result['name'] = (data['fullName'] ?? data['name'] ?? 'N/A').toString();
    result['roll'] = (data['enrollmentNo'] ?? data['roll'] ?? 'N/A').toString();
    result['phone'] = (data['phoneNumber'] ?? data['phone'] ?? 'N/A').toString();
    result['email'] = (data['email'] ?? 'N/A').toString();
    result['dept'] = (data['dept'] ?? 'N/A').toString();
    result['college'] = (data['college'] ?? 'N/A').toString();
    result['facultyId'] = (data['facultyId'] ?? '').toString();
    
    // Internship Info
    result['company'] = (data['company'] ?? 'N/A').toString();
    result['companyMentor'] = (data['companyMentor'] ?? 'N/A').toString();
    result['role'] = (data['internshipRole'] ?? 'N/A').toString();
    result['status'] = (data['internshipStatus'] ?? 'N/A').toString();
    result['type'] = (data['internshipType'] ?? 'N/A').toString();
    result['start'] = (data['startDate'] ?? 'N/A').toString();
    result['end'] = (data['endDate'] ?? 'N/A').toString();
    
    // ✅ Mentor Name (instead of ID)
    result['collegeMentor'] = (data['collegeMentor'] ??
            data['facultyMentorName'] ??
            data['facultyName'] ??
            '')
        .toString();
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("My Students", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),

          /// Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search students...",
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('user').doc(currentUid).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final facultyData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};
                final String myId = (facultyData['facultyId'] ?? facultyData['uid'] ?? "").toString();

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('user')
                      .where('role', isEqualTo: 'student')
                      .where('facultyId', isEqualTo: myId) 
                      .snapshots(),
                  builder: (context, studentSnapshot) {
                    if (studentSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!studentSnapshot.hasData || studentSnapshot.data!.docs.isEmpty) {
                      return _buildEmptyState(myId);
                    }

                    final matchedDocs = studentSnapshot.data!.docs;

                    final filteredDocs = matchedDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['fullName'] ?? '').toString().toLowerCase();
                      final roll = (data['enrollmentNo'] ?? '').toString().toLowerCase();
                      return name.contains(_searchQuery.toLowerCase()) || roll.contains(_searchQuery.toLowerCase());
                    }).toList();

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20, top: 10),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        
                        final name = data['fullName'] ?? 'N/A';
                        final roll = data['enrollmentNo'] ?? 'N/A';
                        final dept = data['dept'] ?? 'N/A';
                        final imageUrl = (data['profileImageUrl'] ?? '').toString();

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.blue.shade50,
                              backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                              child: imageUrl.isEmpty
                                  ? Text(name[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))
                                  : null,
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text("Roll: $roll | Dept: $dept", style: const TextStyle(color: Colors.black54)),
                                const SizedBox(height: 8),
                                
                                /// ✅ Updated Row: Only show Attendance Badge (Mentor ID Removed)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _AttendanceBadge(enrollmentNo: roll.toString()),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentDetailsScreen(
                                    student: _prepareStudentData(data, doc.id),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String id) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No Students Linked", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(height: 8),
          const Text("Students must enter your ID to link:", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
            child: Text(id, style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _AttendanceBadge extends StatelessWidget {
  final String enrollmentNo;

  const _AttendanceBadge({required this.enrollmentNo});

  @override
  Widget build(BuildContext context) {
    if (enrollmentNo.isEmpty || enrollmentNo == 'N/A') {
      return const _AttendanceLabel(label: 'Attendance: 0%');
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendance')
          .doc(enrollmentNo)
          .collection('records')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const _AttendanceLabel(label: 'Attendance: ...');
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

        return _AttendanceLabel(label: 'Attendance: $percentage%');
      },
    );
  }
}

class _AttendanceLabel extends StatelessWidget {
  final String label;

  const _AttendanceLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.analytics_outlined, size: 14, color: Colors.green),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
