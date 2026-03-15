import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'student_details_screen.dart';

class ActiveInternshipsScreen extends StatefulWidget {
  const ActiveInternshipsScreen({super.key});

  @override
  State<ActiveInternshipsScreen> createState() => _ActiveInternshipsScreenState();
}

class _ActiveInternshipsScreenState extends State<ActiveInternshipsScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF5F9ED6),
        foregroundColor: Colors.white,
        title: Text(
          "ACTIVE INTERNSHIPS",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // --- TOP SEARCH & HEADER SECTION ---
          _buildHeaderSearch(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("user")
                  .where("internshipStatus", isEqualTo: "Ongoing")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF5F9ED6)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                // Filter students based on search query
                final students = snapshot.data!.docs.where((doc) {
                  final name = (doc['fullName'] ?? '').toString().toLowerCase();
                  final company = (doc['company'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery.toLowerCase()) || 
                         company.contains(searchQuery.toLowerCase());
                }).toList();

                if (students.isEmpty) {
                  return const Center(child: Text("No matching active internships"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final studentData = students[index].data() as Map<String, dynamic>;
                    return _buildActiveInternCard(context, studentData);
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
            hintText: "Search by student or company...",
            hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF5F9ED6)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  // --- UI HELPER: MODERN ACTIVE INTERN CARD ---
  Widget _buildActiveInternCard(BuildContext context, Map<String, dynamic> data) {
    final String name = data['fullName'] ?? "Unnamed";
    final String company = data['company'] ?? "No Company";
    final String role = data['internshipRole'] ?? "Intern";
    final String imageUrl = (data['profileImageUrl'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
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
                  builder: (_) => StudentDetailsScreen(student: data),
                ),
              );
            },
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Green accent bar to represent "Active/Ongoing"
                  Container(width: 6, color: Colors.green),
                  
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
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF5F9ED6), fontSize: 20),
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
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2D3243)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.business_rounded, size: 14, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        company, 
                                        style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.work_outline, size: 14, color: Color(0xFF5F9ED6)),
                                    const SizedBox(width: 5),
                                    Text(
                                      role, 
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF5F9ED6), fontWeight: FontWeight.w600)
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // "Active" Badge on the card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Active",
                              style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
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
      ),
    );
  }

  // --- UI HELPER: EMPTY STATE ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 16),
          Text("No Active Internships", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const Text("There are currently no students with an 'Ongoing' status.", style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}