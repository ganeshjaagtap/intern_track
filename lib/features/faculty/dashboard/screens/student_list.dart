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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.department} Students"),
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
                hintText: "Search student...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          /// Student List - Fetch from Firestore
          Expanded(
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('user')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return const Center(child: Text("Faculty data not found"));
                }

                final facultyData = userSnapshot.data!.data() as Map<String, dynamic>;
                final facultyName = (facultyData['name'] ?? '').toString().trim();

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('user')
                      .where('role', isEqualTo: 'student')
                      .snapshots(),
                  builder: (context, studentSnapshot) {
                    if (studentSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!studentSnapshot.hasData) {
                      return const Center(
                        child: Text("Error loading students"),
                      );
                    }

                    /// Filter students where collegeMentor matches faculty name (case-insensitive & trimmed)
                    final matchedStudents = studentSnapshot.data!.docs
                        .where((doc) {
                          try {
                            final data = doc.data() as Map<String, dynamic>;
                            // Get collegeMentor field directly from student document
                            var studentCollegeMentor = (data['collegeMentor'] ?? '').toString().trim();
                            // Remove all extra whitespace and special characters
                            studentCollegeMentor = studentCollegeMentor.replaceAll(RegExp(r'\s+'), ' ');
                            // Match with faculty name (case-insensitive)
                            return studentCollegeMentor.isNotEmpty && 
                                   studentCollegeMentor.toLowerCase() == facultyName.toLowerCase();
                          } catch (e) {
                            return false;
                          }
                        })
                        .toList();

                    if (matchedStudents.isEmpty) {
                      return Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "No students assigned to you",
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Debug Info:",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                      const SizedBox(height: 8),
                                      Text("Faculty Name: '$facultyName'",
                                          style: const TextStyle(fontSize: 12)),
                                      Text(
                                          "Total Students with role='student': ${studentSnapshot.data!.docs.length}",
                                          style: const TextStyle(fontSize: 12)),
                                      const SizedBox(height: 12),
                                      const Text("Student List (Matched/All):",
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      for (var doc in studentSnapshot.data!.docs)
                                        Builder(
                                          builder: (context) {
                                            final data = doc.data() as Map<String, dynamic>;
                                            final collegeMentor = (data['collegeMentor'] ?? '').toString().trim();
                                            final isMatched = collegeMentor.isNotEmpty && collegeMentor.toLowerCase() == facultyName.toLowerCase();
                                            return Text(
                                              "${isMatched ? '✓' : '✗'} ${doc['name'] ?? 'Unknown'} | collegeMentor: '$collegeMentor'",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isMatched ? Colors.green : Colors.red,
                                                fontWeight: isMatched ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    final allStudents = matchedStudents
                        .map((doc) => {
                              ...doc.data() as Map<String, dynamic>,
                              'docId': doc.id,
                            })
                        .toList();

                    /// Filter students based on search query
                    final filteredStudents = allStudents.where((student) {
                      final name = (student['fullName'] ?? student['name'] ?? '')
                          .toString()
                          .toLowerCase();
                      final roll = (student['enrollmentNo'] ?? student['roll'] ?? '')
                          .toString();
                      return name.contains(_searchQuery.toLowerCase()) ||
                          roll.contains(_searchQuery);
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        final studentName = student['fullName'] ?? student['name'] ?? 'N/A';
                        final rollNo = student['enrollmentNo'] ?? student['roll'] ?? 'N/A';

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(studentName[0]),
                            ),
                            title: Text(studentName),
                            subtitle: Text("Roll No: $rollNo"),
                            trailing: const Icon(Icons.arrow_forward_ios,
                                size: 16),
                            onTap: () {
                              // Extract nested data BEFORE converting to strings
                              final studentToDisplay = Map<String, String>();
                              
                              // First, add all top-level fields as strings
                              student.forEach((key, value) {
                                if (value != null && value is! Map) {
                                  studentToDisplay[key] = value.toString();
                                }
                              });
                              
                              // Map Firestore field names to expected field names
                              if (!studentToDisplay.containsKey('name') && studentToDisplay.containsKey('fullName')) {
                                studentToDisplay['name'] = studentToDisplay['fullName']!;
                              }
                              if (!studentToDisplay.containsKey('roll') && studentToDisplay.containsKey('enrollmentNo')) {
                                studentToDisplay['roll'] = studentToDisplay['enrollmentNo']!;
                              }
                              if (!studentToDisplay.containsKey('phone') && studentToDisplay.containsKey('phoneNumber')) {
                                studentToDisplay['phone'] = studentToDisplay['phoneNumber']!;
                              }
                              
                              // Try to get internship details from nested object
                              if (student['internship'] != null && student['internship'] is Map) {
                                final internship = student['internship'] as Map;
                                if (internship['role'] != null) studentToDisplay['role'] = internship['role'].toString();
                                if (internship['type'] != null) studentToDisplay['type'] = internship['type'].toString();
                                if (internship['startDate'] != null) studentToDisplay['start'] = internship['startDate'].toString();
                                if (internship['endDate'] != null) studentToDisplay['end'] = internship['endDate'].toString();
                                if (internship['status'] != null) studentToDisplay['status'] = internship['status'].toString();
                              }
                              
                              // Check for top-level date fields (not nested)
                              if ((studentToDisplay['start']?.isEmpty ?? true) && student['startDate'] != null) {
                                studentToDisplay['start'] = student['startDate'].toString();
                              }
                              if ((studentToDisplay['end']?.isEmpty ?? true) && student['endDate'] != null) {
                                studentToDisplay['end'] = student['endDate'].toString();
                              }
                              
                              // Also check for top-level internship fields with different names
                              if (studentToDisplay['type']?.isEmpty ?? true) {
                                if (studentToDisplay.containsKey('internshipType')) {
                                  studentToDisplay['type'] = studentToDisplay['internshipType']!;
                                }
                              }
                              if (studentToDisplay['role']?.isEmpty ?? true) {
                                if (studentToDisplay.containsKey('internshipRole')) {
                                  studentToDisplay['role'] = studentToDisplay['internshipRole']!;
                                }
                              }
                              if (studentToDisplay['status']?.isEmpty ?? true) {
                                if (studentToDisplay.containsKey('internshipStatus')) {
                                  studentToDisplay['status'] = studentToDisplay['internshipStatus']!;
                                }
                              }
                              if ((studentToDisplay['start']?.isEmpty ?? true) && studentToDisplay.containsKey('internshipStartDate')) {
                                studentToDisplay['start'] = studentToDisplay['internshipStartDate']!;
                              }
                              if ((studentToDisplay['end']?.isEmpty ?? true) && studentToDisplay.containsKey('internshipEndDate')) {
                                studentToDisplay['end'] = studentToDisplay['internshipEndDate']!;
                              }
                              
                              // Extract mentor details if nested
                              if (student['mentor'] != null && student['mentor'] is Map) {
                                final mentor = student['mentor'] as Map;
                                if (mentor['collegeMentor'] != null && !studentToDisplay.containsKey('collegeMentor')) {
                                  studentToDisplay['collegeMentor'] = mentor['collegeMentor'].toString();
                                }
                                if (mentor['companyMentor'] != null && !studentToDisplay.containsKey('companyMentor')) {
                                  studentToDisplay['companyMentor'] = mentor['companyMentor'].toString();
                                }
                              }
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      StudentDetailsScreen(
                                          student: studentToDisplay),
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
}