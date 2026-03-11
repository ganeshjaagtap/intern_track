import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_application_2/features/interns/screens/InternshipDetailsScreen.dart';
import 'package:flutter_application_2/features/interns/screens/InternshipbriefDetail.dart';
import 'package:flutter_application_2/features/student/models/company_details_screen.dart';
import 'package:flutter_application_2/features/student/profile/NotificationScreen.dart';
import 'package:flutter_application_2/features/student/reports/ReportScreen.dart';
import 'package:flutter_application_2/features/student/reports/SubmitReportScreen.dart';
import 'package:flutter_application_2/features/student/task/student_task_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  /// COMPANY DATA
  static final List<Map<String, dynamic>> companies = [
    {
      "id": "1",
      "name": "Microsoft",
      "industry": "Software Development",
      "email": "recruitment@microsoft.com",
      "description":
          "Microsoft empowers every person and organization on the planet to achieve more.",
      "website": "www.microsoft.com",
    },
    {
      "id": "2",
      "name": "Google",
      "industry": "Cloud Engineering",
      "email": "hr@google.com",
      "description":
          "Google's mission is to organize the world's information.",
      "website": "www.google.com",
    },
    {
      "id": "3",
      "name": "Amazon",
      "industry": "Backend Development",
      "email": "jobs@amazon.com",
      "description":
          "Amazon focuses on customer obsession and innovation.",
      "website": "www.amazon.com",
    },
  ];

  static final List<GroupMember> groupMembers = [
    const GroupMember(
      name: "Siddhika Deshmukh",
      enrollmentNumber: "IT2026-001",
      projectRole: "Team Leader",
    ),
    const GroupMember(
      name: "Shruti Paraye",
      enrollmentNumber: "IT2026-014",
      projectRole: "Backend Developer",
    ),
    const GroupMember(
      name: "Ganesh Jagtap",
      enrollmentNumber: "IT2026-027",
      projectRole: "UI/UX Designer",
    ),
    const GroupMember(
      name: "Abhijeet Apare",
      enrollmentNumber: "IT2026-033",
      projectRole: "QA Engineer",
    ),
  ];

  void _showGroupMemberDialog(BuildContext context, GroupMember member) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Group Member"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                child: Text(_initials(member.name)),
              ),
              const SizedBox(height: 12),
              Text(
                member.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("Enrollment: ${member.enrollmentNumber}"),
              const SizedBox(height: 4),
              Text("Role: ${member.projectRole}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0];
    return "${parts[0][0]}${parts[1][0]}";
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
        title: const Text(
          "INTERN TRACKER",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
        ],
      ),

      /// BODY
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("user")
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          String name = "Student";
          String company = "Company";

          if (snapshot.hasData && snapshot.data!.data() != null) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            name = data["fullName"] ?? "Student";
            company = data["company"] ?? "Company";
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// 🔹 DYNAMIC NAME + COMPANY
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),

                Text("Intern at $company"),

                const SizedBox(height: 16),

                /// DEADLINE ALERT
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD6D6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.red),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Week report submission pending",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SubmitReportScreen(),
                            ),
                          );
                        },
                        child: const Text("Submit"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                /// STATS
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const InternshipBriefDetailsScreen(),
                            ),
                          );
                        },
                        child: const MiniStatCard(
                          icon: Icons.bar_chart,
                          value: "1",
                          label: "Active",
                          bg: Color(0xFFD9ECFF),
                          iconColor: Colors.blue,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => StudentTaskScreen()),
                          );
                        },
                        child: const MiniStatCard(
                          icon: Icons.task_alt,
                          value: "7",
                          label: "Tasks",
                          bg: Color(0xFFE8E4FF),
                          iconColor: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: const MiniStatCard(
                        icon: Icons.access_time,
                        value: "45/120",
                        label: "Days Completed",
                        bg: Color(0xFFFFE6D9),
                        iconColor: Colors.deepOrange,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ReportScreen()),
                          );
                        },
                        child: const MiniStatCard(
                          icon: Icons.description,
                          value: "7",
                          label: "Reports",
                          bg: Color(0xFFFFF2CC),
                          iconColor: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                const Text(
                  "Internship Progress",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [

                      const TabBar(
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.grey,
                        tabs: [
                          Tab(text: "Companies"),
                          Tab(text: "My Progress"),
                          Tab(text: "My Group"),
                        ],
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        height: 220,
                        child: TabBarView(
                          children: [

                            /// COMPANY LIST - DYNAMIC FROM FIRESTORE
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('company')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                final companies = snapshot.data!.docs;
                                if (companies.isEmpty) {
                                  return const Center(
                                    child: Text('No companies available'),
                                  );
                                }

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListView.builder(
                                    itemCount: companies.length,
                                    itemBuilder: (context, index) {
                                      final companyData =
                                          companies[index].data()
                                              as Map<String, dynamic>;
                                      final companyWithId = {
                                        ...companyData,
                                        'id': companies[index].id,
                                      };

                                      return ListTile(
                                        leading: const Icon(Icons.business),
                                        title: Text(
                                            companyData['name'] ?? 'Unknown'),
                                        subtitle: Text(
                                            companyData['industry'] ?? ''),
                                        trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  CompanyDetailScreen(
                                                      companyData:
                                                          companyWithId),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            ),

                            /// PROGRESS
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Flutter Developer Intern",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Techsurya IT Solutions",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  SizedBox(height: 14),
                                  LinearProgressIndicator(value: 0.65),
                                  SizedBox(height: 10),
                                  Text("65% Internship Completed"),
                                ],
                              ),
                            ),

                            /// GROUP
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListView.builder(
                                itemCount: groupMembers.length,
                                itemBuilder: (context, index) {
                                  final member = groupMembers[index];

                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(_initials(member.name)),
                                    ),
                                    title: Text(member.name),
                                    subtitle: Text(member.projectRole),
                                    onTap: () =>
                                        _showGroupMemberDialog(context, member),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GroupMember {
  final String name;
  final String enrollmentNumber;
  final String projectRole;

  const GroupMember({
    required this.name,
    required this.enrollmentNumber,
    required this.projectRole,
  });
}

class MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color bg;
  final Color iconColor;

  const MiniStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.bg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}