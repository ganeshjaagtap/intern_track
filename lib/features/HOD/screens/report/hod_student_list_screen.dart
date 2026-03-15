import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure you have google_fonts in pubspec.yaml
import 'hod_student_reports_screen.dart';

class HodStudentListScreen extends StatefulWidget {
  const HodStudentListScreen({super.key});

  @override
  State<HodStudentListScreen> createState() => _HodStudentListScreenState();
}

class _HodStudentListScreenState extends State<HodStudentListScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF), // Clean premium background
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF5F9ED6),
        foregroundColor: Colors.white,
        title: Text(
          "STUDENT DIRECTORY",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // --- TOP SEARCH SECTION ---
          _buildHeaderSearch(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("user")
                  .where("role", isEqualTo: "student")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF5F9ED6)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                // Filter logic for the list
                final students = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data["fullName"] ?? "").toString().toLowerCase();
                  final enrollment = (data["enrollmentNo"] ?? "").toString().toLowerCase();
                  return name.contains(searchQuery.toLowerCase()) || 
                         enrollment.contains(searchQuery.toLowerCase());
                }).toList();

                if (students.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text("No matching students found", style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final data = students[index].data() as Map<String, dynamic>;
                    final studentId = data["uid"] ?? students[index].id;
                    return _buildStudentCard(context, data, studentId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPER: PREMIUM SEARCH HEADER ---
  Widget _buildHeaderSearch() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 25),
      decoration: const BoxDecoration(
        color: Color(0xFF5F9ED6),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: TextField(
          onChanged: (val) => setState(() => searchQuery = val),
          decoration: InputDecoration(
            hintText: "Search by name or enrollment...",
            hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF5F9ED6)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  // --- UI HELPER: MODERN STUDENT CARD ---
  Widget _buildStudentCard(BuildContext context, Map<String, dynamic> data, String studentId) {
    final String name = data['fullName'] ?? "Unnamed";
    final String enrollment = data['enrollmentNo'] ?? "N/A";
    final String dept = data['dept'] ?? "IT Department";
    final String imageUrl = (data['profileImageUrl'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HodStudentReportsScreen(
                    studentId: studentId,
                    studentName: name,
                  ),
                ),
              );
            },
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Blue accent bar for role branding
                  Container(width: 6, color: const Color(0xFF5F9ED6)),
                  
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: const Color(0xFFF0F7FF),
                            backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                            child: imageUrl.isEmpty
                                ? Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : "S",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold, 
                                      color: const Color(0xFF5F9ED6), 
                                      fontSize: 20
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name, 
                                  style: GoogleFonts.poppins(
                                    fontSize: 16, 
                                    fontWeight: FontWeight.bold, 
                                    color: const Color(0xFF2D3243)
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.badge_outlined, size: 14, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Text(
                                      enrollment, 
                                      style: const TextStyle(fontSize: 12, color: Colors.grey)
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.account_tree_outlined, size: 14, color: Color(0xFF5F9ED6)),
                                    const SizedBox(width: 5),
                                    Text(
                                      dept, 
                                      style: const TextStyle(
                                        fontSize: 12, 
                                        color: Color(0xFF5F9ED6), 
                                        fontWeight: FontWeight.w500
                                      )
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI HELPER: EMPTY STATE ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(Icons.group_off_rounded, size: 80, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 16),
          Text(
            "No Students Found", 
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)
          ),
          const Text(
            "The database currently has no registered students.", 
            style: TextStyle(color: Colors.grey, fontSize: 13)
          ),
        ],
      ),
    );
  }
}