import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_application_2/features/interns/screens/InternshipbriefDetail.dart';
import 'package:flutter_application_2/features/student/models/company_details_screen.dart';
import 'package:flutter_application_2/features/student/profile/NotificationScreen.dart';
import 'package:flutter_application_2/features/student/reports/ReportScreen.dart';
import 'package:flutter_application_2/features/student/reports/SubmitReportScreen.dart';
import 'package:flutter_application_2/features/student/task/student_task_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return "${parts[0][0]}${parts[1][0]}".toUpperCase();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("user").doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String name = userData["fullName"] ?? "Student";
          final String company = userData["company_name"] ?? userData["company"] ?? "Not Assigned";
          final String? assignedGroupId = userData["assignedGroupId"];
          final String? facultyId = userData["facultyId"]; 

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Intern at $company", style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),

                /// DEADLINE ALERT
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFFFD6D6), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.red),
                      const SizedBox(width: 12),
                      const Expanded(child: Text("Week report submission pending", style: TextStyle(fontWeight: FontWeight.bold))),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitReportScreen())),
                        child: const Text("Submit"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InternshipBriefDetailsScreen())),
                        child: const MiniStatCard(icon: Icons.bar_chart, value: "1", label: "Active", bg: Color(0xFFD9ECFF), iconColor: Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentTaskScreen())),
                        child: const MiniStatCard(icon: Icons.task_alt, value: "7", label: "Tasks", bg: Color(0xFFE8E4FF), iconColor: Colors.deepPurple),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                /// TAB CONTROLLER
                DefaultTabController(
                  length: 4, 
                  child: Column(
                    children: [
                      const TabBar(
                        isScrollable: true,
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue,
                        tabs: [
                          Tab(text: "Companies"),
                          Tab(text: "My Progress"),
                          Tab(text: "My Group"),
                          Tab(text: "My Mentor"),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 380, // Height for content
                        child: TabBarView(
                          children: [
                            _buildCompaniesTab(),
                            _buildProgressTab(userData),
                            _buildDynamicGroupTab(assignedGroupId),
                            _buildMentorTab(facultyId), 
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ✅ TAB 4: MENTOR INFO WITH CALL & INTERN COUNT
  Widget _buildMentorTab(String? facultyId) {
    if (facultyId == null || facultyId.isEmpty) {
      return const Center(child: Text("No mentor assigned in your profile."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('facultyId', isEqualTo: facultyId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Mentor details not found."));
        }

        final mentorData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final String mName = mentorData['fullName'] ?? "Mentor Name";
        final String mPhone = mentorData['phoneNumber'] ?? "N/A";
        final String mEmail = mentorData['email'] ?? "N/A";
        final String mDept = mentorData['dept'] ?? mentorData['company_name'] ?? "IT Department";

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Text(_initials(mName), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ),
                const SizedBox(height: 10),
                Text(mName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                /// CALL BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      if (mPhone != "N/A") {
                        final Uri launchUri = Uri(scheme: 'tel', path: mPhone);
                        if (await canLaunchUrl(launchUri)) {
                          await launchUrl(launchUri);
                        }
                      }
                    },
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text("CALL MENTOR"),
                  ),
                ),

                const Divider(height: 25),

                /// DYNAMIC INTERN COUNT
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('user')
                      .where('role', isEqualTo: 'student')
                      .where('facultyId', isEqualTo: facultyId)
                      .snapshots(),
                  builder: (context, internSnap) {
                    int count = internSnap.hasData ? internSnap.data!.docs.length : 0;
                    return _mentorDetailRow(Icons.groups, "Total Interns Under Him", "$count Students");
                  },
                ),

                const SizedBox(height: 10),
                _mentorDetailRow(Icons.badge, "Mentor ID", facultyId!),
                const SizedBox(height: 10),
                _mentorDetailRow(Icons.business, "Department", mDept),
                const SizedBox(height: 10),
                _mentorDetailRow(Icons.email, "Email", mEmail),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _mentorDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

  /// ✅ TAB 1: Companies
  Widget _buildCompaniesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('company').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.business, color: Colors.blue),
                title: Text(data['name'] ?? 'Unknown'),
                subtitle: Text(data['industry'] ?? 'Industry'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CompanyDetailScreen(companyData: {...data, 'id': docs[index].id}))),
              ),
            );
          },
        );
      },
    );
  }

  /// ✅ TAB 2: Progress
  Widget _buildProgressTab(Map<String, dynamic> userData) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Internship Progress", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: 0.65, backgroundColor: Colors.grey[200], color: Colors.blue),
            const SizedBox(height: 10),
            const Text("65% Completed"),
          ],
        ),
      ),
    );
  }

  /// ✅ TAB 3: Group Members
  Widget _buildDynamicGroupTab(String? groupId) {
    if (groupId == null) return const Center(child: Text("No group assigned."));
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('groups').doc(groupId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: CircularProgressIndicator());
        final groupData = snapshot.data!.data() as Map<String, dynamic>;
        final String groupName = groupData['groupName'] ?? "Unnamed Project";
        final List<String> studentIds = List<String>.from(groupData['studentIds'] ?? []);

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Text(groupName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: studentIds.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('user').doc(studentIds[index]).get(),
                    builder: (context, userSnap) {
                      if (!userSnap.hasData) return const SizedBox();
                      final member = userSnap.data!.data() as Map<String, dynamic>;
                      return ListTile(
                        leading: CircleAvatar(child: Text(_initials(member['fullName'] ?? "T"))),
                        title: Text(member['fullName'] ?? "Teammate"),
                        subtitle: Text(member['enrollmentNo'] ?? ""),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color bg;
  final Color iconColor;

  const MiniStatCard({super.key, required this.icon, required this.value, required this.label, required this.bg, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}