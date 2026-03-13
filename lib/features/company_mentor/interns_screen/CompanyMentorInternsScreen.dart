import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure you ran 'flutter pub add google_fonts'
import '../bottom_bar/company_mentor_bottom_bar.dart';
import 'InternDetailsScreen.dart';

class CompanyMentorInternsScreen extends StatefulWidget {
  const CompanyMentorInternsScreen({super.key});

  @override
  State<CompanyMentorInternsScreen> createState() => _CompanyMentorInternsScreenState();
}

class _CompanyMentorInternsScreenState extends State<CompanyMentorInternsScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final String currentAuthUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF), // Soft premium background
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF5F9ED6),
        title: Text(
          "INTERN DIRECTORY",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1.1, color: Colors.white, fontSize: 18),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('user').doc(currentAuthUid).get(),
        builder: (context, mentorSnapshot) {
          if (mentorSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF5F9ED6)));
          }

          final mentorData = mentorSnapshot.data?.data() as Map<String, dynamic>?;
          final String mentorProfileId = mentorData?['mentorId']?.toString() ?? "";

          return Column(
            children: [
              // --- TOP SEARCH SECTION ---
              _buildHeaderSearch(),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('user')
                      .where('role', isEqualTo: 'student')
                      .where('companyMentorId', isEqualTo: mentorProfileId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data?.docs.where((doc) {
                      final name = (doc['fullName'] ?? '').toString().toLowerCase();
                      return name.contains(searchQuery.toLowerCase());
                    }).toList() ?? [];

                    if (docs.isEmpty) {
                      return _buildEmptyState(mentorProfileId);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Padding for bottom bar
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final String docId = docs[index].id;
                        if (data['uid'] == null) data['uid'] = docId;

                        return _buildInternCard(context, data);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const CompanyMentorBottomBar(currentIndex: 1),
    );
  }

  // --- UI HELPER: PREMIUM SEARCH HEADER ---
  Widget _buildHeaderSearch() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
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
            hintText: "Search interns...",
            hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF5F9ED6)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  // --- UI HELPER: MODERN INTERN CARD ---
  Widget _buildInternCard(BuildContext context, Map<String, dynamic> data) {
    final String name = data['fullName'] ?? "Unnamed";
    final String college = data['college_name'] ?? "Government Polytechnic College Aurangabad";
    final String role = data['internshipRole'] ?? "Intern";

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
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InternDetailsScreen(studentData: data))),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Accent color bar
                  Container(width: 6, color: const Color(0xFF5F9ED6)),
                  
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: const Color(0xFFF0F7FF),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : "?",
                              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF5F9ED6), fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2D3243))),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.school_outlined, size: 14, color: Colors.grey),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(college, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.badge_outlined, size: 14, color: Color(0xFF5F9ED6)),
                                    const SizedBox(width: 5),
                                    Text(role, style: const TextStyle(fontSize: 12, color: Color(0xFF5F9ED6), fontWeight: FontWeight.w500)),
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
  Widget _buildEmptyState(String id) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(Icons.person_search_rounded, size: 80, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 16),
          Text("No Interns Found", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          Text("No students assigned to Mentor ID: $id", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}