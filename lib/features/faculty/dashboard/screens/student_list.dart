import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/features/faculty/dashboard/screens/student_detail_screen.dart';

class StudentListScreen extends StatefulWidget {
  final String department;

  const StudentListScreen({super.key, this.department = "IoT"});

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

  /// Helper to convert dynamic map to String map for your detail screen
  Map<String, String> _prepareStudentData(Map<String, dynamic> data, String id) {
    Map<String, String> result = {'docId': id};
    
    // Fill basic fields
    result['name'] = (data['fullName'] ?? data['name'] ?? 'N/A').toString();
    result['roll'] = (data['enrollmentNo'] ?? data['roll'] ?? 'N/A').toString();
    result['phone'] = (data['phoneNumber'] ?? data['phone'] ?? 'N/A').toString();
    result['email'] = (data['email'] ?? 'N/A').toString();
    
    // Fill internship fields
    result['company'] = (data['company'] ?? 'N/A').toString();
    result['role'] = (data['internshipRole'] ?? 'N/A').toString();
    result['status'] = (data['internshipStatus'] ?? 'N/A').toString();
    result['type'] = (data['internshipType'] ?? 'N/A').toString();
    result['start'] = (data['startDate'] ?? 'N/A').toString();
    result['end'] = (data['endDate'] ?? 'N/A').toString();
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.department} Students"),
        backgroundColor: const Color(0xFF6BB6FF),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          /// Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by name or roll no...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          const SizedBox(height: 10),

          /// Student List Logic
          Expanded(
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('user').doc(currentUid).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const Center(child: Text("Faculty data not found"));
                }

                final facultyData = userSnapshot.data!.data() as Map<String, dynamic>;
                
                // ✅ GET THE UNIQUE ID (Checks facultyId field first)
                final String myId = (facultyData['facultyId'] ?? facultyData['uid'] ?? "").toString();

                return StreamBuilder<QuerySnapshot>(
                  // ✅ DATABASE FILTER: Only fetch students assigned to this Faculty ID
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

                    // Apply Search Query Filter locally
                    final filteredDocs = matchedDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = (data['fullName'] ?? data['name'] ?? '').toString().toLowerCase();
                      final roll = (data['enrollmentNo'] ?? '').toString().toLowerCase();
                      return name.contains(_searchQuery.toLowerCase()) || roll.contains(_searchQuery.toLowerCase());
                    }).toList();

                    if (filteredDocs.isEmpty && _searchQuery.isNotEmpty) {
                      return const Center(child: Text("No matching students found"));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final name = data['fullName'] ?? data['name'] ?? 'N/A';
                        final roll = data['enrollmentNo'] ?? 'N/A';

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF6BB6FF).withOpacity(0.2),
                              child: Text(name[0].toUpperCase(), style: const TextStyle(color: Color(0xFF1976D2))),
                            ),
                            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Roll No: $roll"),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_ind_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              "No Students Assigned",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 8),
            Text(
              "Your ID: $id",
              style: const TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(
              "Ask your students to enter this ID in their Profile Settings under 'Faculty Mentor ID'.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}