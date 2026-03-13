import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_application_2/features/interns/screens/InternshipbriefDetail.dart';
import 'package:flutter_application_2/features/student/models/company_details_screen.dart';
import 'package:flutter_application_2/features/student/notifications/student_event_notifications_screen.dart';
import 'package:flutter_application_2/features/student/profile/NotificationScreen.dart';
import 'package:flutter_application_2/features/student/reports/SubmitReportScreen.dart';
import 'package:flutter_application_2/features/student/task/student_task_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  String _formatEventDate(dynamic value) {
    if (value is Timestamp) {
      final dt = value.toDate();
      return "${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }
    return "";
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return "U";
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return "${parts[0][0]}${parts[1][0]}".toUpperCase();
  }

  String _getInternshipRole(Map<String, dynamic> userData) {
    const fallbackFields = ['internshipRole', 'roleTitle', 'internRole', 'designation'];
    for (String field in fallbackFields) {
      if (userData.containsKey(field) && userData[field] != null && userData[field].toString().isNotEmpty) {
        return userData[field].toString();
      }
    }
    final company = userData["company_name"] ?? userData["company"];
    return company != null ? "Intern at $company" : "Intern";
  }

  void _showMentorDetailsModal(BuildContext context, String? facultyId, String? mentorId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, scrollController) => _buildMentorDetailsSheet(context, scrollController, facultyId, mentorId),
      ),
    );
  }

  Widget _buildMentorDetailsSheet(BuildContext context, ScrollController scrollController, String? facultyId, String? mentorId) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text("Mentor Details", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: "Faculty Mentor"),
              Tab(text: "Company Mentor"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // ✅ TAB 1: Logic for College Faculty
                _buildTabContent(context, facultyId, "faculty", "facultyId"),
                // ✅ TAB 2: Logic for Company Mentor (Matches student's mentorId)
                _buildTabContent(context, mentorId, "mentor", "mentorId"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, String? id, String role, String field) {
    if (id == null || id.isEmpty) {
      return Center(child: Text("No ${role == 'faculty' ? 'Faculty' : 'Company'} Mentor Assigned"));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: _fetchMentorCard(context, id, role, field),
    );
  }

  Widget _fetchMentorCard(BuildContext context, String id, String role, String idFieldName) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: role)      // Compares the role
          .where(idFieldName, isEqualTo: id)   // Compares the specific ID assigned to student
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) return const Center(child: Text("Mentor details not found."));

        final mentorData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        
        // Map fields based on whether it is a Faculty or Company mentor
        final String mName = mentorData['mentor_name'] ?? mentorData['fullName'] ?? "Mentor";
        final String mPhone = mentorData['phone'] ?? mentorData['phoneNumber'] ?? "N/A";
        final String mEmail = mentorData['email'] ?? "N/A";
        final String mInfo = mentorData['company_name'] ?? mentorData['dept'] ?? "N/A";

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Text(_initials(mName), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(mName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(mInfo, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (mPhone != "N/A") {
                  final uri = Uri(scheme: 'tel', path: mPhone);
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                }
              },
              icon: const Icon(Icons.call),
              label: const Text("CALL MENTOR", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            const Text("Details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            _mentorDetailRow(Icons.email, "Email", mEmail),
            _mentorDetailRow(Icons.phone, "Phone", mPhone),
            _mentorDetailRow(Icons.badge, "Mentor ID", id),
            if (mentorData['company_address'] != null)
               _mentorDetailRow(Icons.location_on, "Office", mentorData['company_address']),
          ],
        );
      },
    );
  }

  Widget _mentorDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
        title: const Text("INTERN TRACKER", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("user").doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String? facultyId = userData["facultyId"];
          final String? mentorId = userData["mentorId"]; // Assigned Company Mentor ID

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userData["fullName"] ?? "Student", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(_getInternshipRole(userData), style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 20),
                _buildAlertCard(context),

                // Alert Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD6D6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.red, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Week report submission pending",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitReportScreen())),
                        child: const Text("Submit", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("notifications")
                      .where("recipientId", isEqualTo: uid)
                      .snapshots(),
                  builder: (context, eventSnapshot) {
                    if (!eventSnapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final docs = eventSnapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return (data["type"] ?? "").toString() == "event";
                    }).toList();

                    docs.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aTs = aData["createdAt"];
                      final bTs = bData["createdAt"];

                      if (aTs is Timestamp && bTs is Timestamp) {
                        return bTs.compareTo(aTs);
                      }
                      return 0;
                    });

                    if (docs.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final latest = docs.first.data() as Map<String, dynamic>;
                    final eventType =
                        (latest["eventType"] ?? "Event").toString();
                    final eventDate = _formatEventDate(latest["eventDateTime"]);
                    final eventSummary =
                        (latest["title"] ?? eventType).toString();

                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const StudentEventNotificationsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9ECFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.event_available,
                                color: Colors.blue,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Upcoming Events",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      eventDate.isEmpty
                                          ? eventSummary
                                          : "$eventSummary • $eventDate",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "View",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
                
                // Stat Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
                  children: [
                    _buildStatCard(context, onTap: () {}, icon: Icons.bar_chart, value: "1", label: "Active", bg: const Color(0xFFD9ECFF), iconColor: Colors.blue),
                    _buildStatCard(context, onTap: () {}, icon: Icons.task_alt, value: "7", label: "Tasks", bg: const Color(0xFFE8E4FF), iconColor: Colors.deepPurple),
                    _buildStatCard(context, onTap: () {}, icon: Icons.schedule, value: "45/120", label: "Days Completed", bg: const Color(0xFFFFE8CC), iconColor: Colors.orange),
                    _buildStatCard(
                      context, 
                      onTap: () => _showMentorDetailsModal(context, facultyId, mentorId), 
                      icon: Icons.person_outline, 
                      value: (facultyId != null && mentorId != null) ? "2" : "1", 
                      label: "My Mentor", 
                      bg: const Color(0xFFD9F0E8), 
                      iconColor: Colors.teal
                    ),
                  ],
                ),
                // ... (Tabs section)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: const Color(0xFFFFD6D6), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.red, size: 24),
          const SizedBox(width: 12),
          const Expanded(child: Text("Week report submission pending", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {},
            child: const Text("Submit", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {required VoidCallback onTap, required IconData icon, required String value, required String label, required Color bg, required Color iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 16, color: iconColor)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}