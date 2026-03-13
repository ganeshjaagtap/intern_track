import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/features/company_mentor/attendance/CompanyMentorAttendanceScreen.dart';
import 'package:flutter_application_2/features/company_mentor/dashboard/task_of_mentor.dart';

import '../bottom_bar/company_mentor_bottom_bar.dart';
import 'MentorAttendanceScreen.dart';
import 'CompanyMentorPendingScreen.dart'; // This will serve as your Review Screen
import 'CompanyMentorPerformanceScreen.dart';
import 'CollegeMentorsScreen.dart';
import '../notifications/CompanyMentorNotificationScreen.dart';

class CompanyMentorDashboardScreen extends StatefulWidget {
  const CompanyMentorDashboardScreen({super.key});

  @override
  State<CompanyMentorDashboardScreen> createState() =>
      _CompanyMentorDashboardScreenState();
}

class _CompanyMentorDashboardScreenState
    extends State<CompanyMentorDashboardScreen> {
  String companyName = "Loading...";
  String location = "Loading...";
  String designation = "Loading...";
  int internCount = 0;
  int reviewCount = 0; // Dynamic count for tasks to be approved
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // 1. Fetch Mentor Profile
        DocumentSnapshot mentorDoc = await FirebaseFirestore.instance
            .collection("user")
            .doc(currentUser.uid)
            .get();

        if (mentorDoc.exists) {
          final data = mentorDoc.data() as Map<String, dynamic>;
          companyName = data["company_name"] ?? "Company Not Provided";
          location = data["company_address"] ?? "Location Not Set";
          designation = data["designation"] ?? "Mentor";
          internCount = data["total_students"] ?? 0;
        }

        // 2. Fetch Count of Tasks marked 'completed' by students but not yet 'approved'
        QuerySnapshot reviewSnap = await FirebaseFirestore.instance
            .collection("tasks")
            .where("assignedByMentorId", isEqualTo: currentUser.uid)
            .where("status", isEqualTo: "completed") // Student finished it
            .get();
            
        reviewCount = reviewSnap.docs.length;
      }
    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF5F9ED6),
        title: const Text(
          "INTERN TRACKER",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CompanyMentorNotificationScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompanyProfileCard(),
              const SizedBox(height: 24),
              
              // --- ROW 1: ACTION CARDS ---
              Row(
                children: [
                  _buildNavCard(
                    context,
                    destination: const TaskOfMentorScreen(),
                    icon: Icons.add_task,
                    value: "Add",
                    label: "Task",
                    bg: const Color(0xFFD6E9FF),
                    iconColor: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildNavCard(
                    context,
                    destination: const CompanyMentorPendingScreen(),
                    icon: Icons.rate_review_outlined, // Updated Icon
                    value: reviewCount.toString(),    // Dynamic Value
                    label: "Review",                 // Updated Label
                    bg: const Color(0xFFFFE4B5),
                    iconColor: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- ROW 2: STAT CARDS ---
              Row(
                children: [
                  _buildNavCard(
                    context,
                    destination: const CompanyMentorPerformanceScreen(),
                    icon: Icons.trending_up,
                    value: "92%",
                    label: "Performance",
                    bg: const Color(0xFFDFF5EA),
                    iconColor: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildNavCard(
                    context,
                    destination: const CollegeMentorsScreen(),
                    icon: Icons.school,
                    value: "6",
                    label: "Mentors",
                    bg: const Color(0xFFE8D5C4),
                    iconColor: Colors.deepOrange,
                  ),
                ],
              ),
              const SizedBox(height: 30),

              const Text(
                "Today's Attendance",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildAttendanceBanner(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CompanyMentorBottomBar(currentIndex: 0),
    );
  }

  // --- UI BUILDING HELPER METHODS ---

  Widget _buildCompanyProfileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            height: 60, width: 60,
            decoration: BoxDecoration(color: const Color(0xFFE6EEF7), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.business, size: 32, color: Colors.blueGrey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: isLoading 
              ? const LinearProgressIndicator()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(companyName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(location, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text("$internCount Interns", style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 12),
                        const Icon(Icons.badge, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Expanded(child: Text(designation, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard(BuildContext context, {required Widget destination, required IconData icon, required String value, required String label, required Color bg, required Color iconColor}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)),
        child: MiniStatCard(icon: icon, value: value, label: label, bg: bg, iconColor: iconColor),
      ),
    );
  }

  Widget _buildAttendanceBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TodayAttendanceScreen())),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.fact_check, color: Colors.white)),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Fill Today's Attendance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("Mark intern attendance for today", style: TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.green),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.white, radius: 18, child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(label, style: const TextStyle(fontSize: 11), maxLines: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}