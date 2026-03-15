import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure google_fonts is in pubspec.yaml
import 'package:flutter_application_2/features/HOD/screens/report/hod_student_reports_screen.dart';

class CompletedInternshipDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> student;

  const CompletedInternshipDetailsScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final String name = student["fullName"] ?? "Student";
    final String studentId = (student["uid"] ?? "").toString();
    final String imageUrl = (student["profileImageUrl"] ?? "").toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF5F9ED6),
        foregroundColor: Colors.white,
        title: Text(
          "INTERNSHIP DOSSIER",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, 
            letterSpacing: 1.1, 
            fontSize: 18
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER PROFILE SECTION ---
            _buildProfileHeader(name, imageUrl),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION: STUDENT INFO ---
                  _buildSectionTitle("Student Information", Icons.person_outline),
                  _buildInfoCard([
                    _infoRow("Enrollment", student["enrollmentNo"]),
                    _infoRow("Department", student["dept"]),
                    _infoRow("Year", student["year"]),
                  ]),

                  const SizedBox(height: 20),

                  // --- SECTION: INTERNSHIP DETAILS ---
                  _buildSectionTitle("Experience Details", Icons.business_center_outlined),
                  _buildInfoCard([
                    _infoRow("Company", student["company"]),
                    _infoRow("Role", student["internshipRole"]),
                    _infoRow("Type", student["internshipType"]),
                    _infoRow("Duration", "${student["startDate"] ?? ''} — ${student["endDate"] ?? ''}"),
                  ]),

                  const SizedBox(height: 20),

                  // --- SECTION: MENTORS ---
                  _buildSectionTitle("Mentorship", Icons.handshake_outlined),
                  _buildInfoCard([
                    _infoRow("College", student["collegeMentor"]),
                    _infoRow("Industry", student["companyMentor"]),
                  ]),

                  const SizedBox(height: 25),

                  // --- STATUS BADGE ---
                  _buildCompletionBadge(),

                  const SizedBox(height: 30),

                  // --- ACTION BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5F9ED6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 2,
                      ),
                      onPressed: () {
                        if (studentId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Student report not available")),
                          );
                          return;
                        }
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
                      icon: const Icon(Icons.description_outlined),
                      label: Text(
                        "VIEW PERFORMANCE REPORT",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER: PROFILE HEADER ---
  Widget _buildProfileHeader(String name, String imageUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF5F9ED6),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 47,
              backgroundColor: const Color(0xFFF0F7FF),
              backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl.isEmpty
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "S",
                      style: GoogleFonts.poppins(
                        fontSize: 35, 
                        fontWeight: FontWeight.bold, 
                        color: const Color(0xFF5F9ED6)
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            name.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Colors.white,
              letterSpacing: 0.8
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPER: SECTION TITLE ---
  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF5F9ED6)),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 13, 
              fontWeight: FontWeight.bold, 
              color: Colors.blueGrey.shade600,
              letterSpacing: 1.0
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPER: INFO CARD ---
  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(children: children),
    );
  }

  // --- UI HELPER: INFO ROW ---
  Widget _infoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.toString() ?? "N/A",
              style: const TextStyle(
                fontWeight: FontWeight.w600, 
                color: Color(0xFF2D3243),
                fontSize: 14
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPER: COMPLETION BADGE ---
  Widget _buildCompletionBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFFF4),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Colors.green, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Status: Completed",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, 
                    color: Colors.green.shade800
                  ),
                ),
                const Text(
                  "All milestones and verification documents have been cleared.",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}