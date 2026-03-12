import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter_application_2/features/HOD/report/hod_student_list_screen.dart';
import 'package:flutter_application_2/features/HOD/screens/report/hod_student_list_screen.dart';
import 'student_list_screen.dart';
import 'active_internships_screen.dart';
import 'completed_internships_screen.dart';
import 'review_approvals_screen.dart';

class MentorDashboardScreen extends StatelessWidget {
  const MentorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _NeedsAttentionCard(),
              SizedBox(height: 30),
              Text(
                "Internship Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              _StatsSection(),
              SizedBox(height: 30),
              Text(
                "Quick Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              _QuickActions(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  // ✅ Helper function to safely check the boolean value from Firestore
  bool _isUserApproved(dynamic isApproved) {
    if (isApproved == null) return false;
    if (isApproved is bool) return isApproved;
    if (isApproved is String) return isApproved.toLowerCase() == 'true';
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 'student')
          .where('dept', isEqualTo: 'IT')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = snapshot.data!.docs;
        int total = students.length;

        // ✅ Updated with safe check
        int active = students.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return _isUserApproved(data['isApproved']);
        }).length;

        // ✅ Updated with safe check
        int pending = students.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return !_isUserApproved(data['isApproved']);
        }).length;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: "Total Students",
                    value: total.toString(),
                    icon: Icons.groups,
                    color: Colors.blue,
                    screen: const StudentListScreen(department: "IT"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: "Active Now",
                    value: active.toString(),
                    icon: Icons.bolt,
                    color: Colors.orange,
                    screen: const ActiveInternshipsScreen(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: "Completed",
                    value: "0",
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                    screen: const CompletedInternshipsScreen(),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: "Pending",
                    value: pending.toString(),
                    icon: Icons.hourglass_empty,
                    color: Colors.deepOrange,
                    screen: const ReviewApprovalsScreen(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    Widget? screen,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(.15),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 15),
            Text(value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class _NeedsAttentionCard extends StatelessWidget {
  const _NeedsAttentionCard();

  // ✅ Helper function duplicated here for safety
  bool _isUserApproved(dynamic isApproved) {
    if (isApproved == null) return false;
    if (isApproved is bool) return isApproved;
    if (isApproved is String) return isApproved.toLowerCase() == 'true';
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 'student')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final docs = snapshot.data!.docs;

        // ✅ Updated with safe check
        int pending = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return !_isUserApproved(data['isApproved']);
        }).length;

        if (pending == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 10),
              Text("$pending students waiting for approval"),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MentorActionTile(
          icon: Icons.fact_check_outlined,
          title: "Review Approvals",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ReviewApprovalsScreen()),
          ),
        ),
        const SizedBox(height: 10), // Added spacing for cleaner look
        MentorActionTile(
          icon: Icons.bar_chart_rounded,
          title: "View Reports",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HodStudentListScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class MentorActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const MentorActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.blue),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}