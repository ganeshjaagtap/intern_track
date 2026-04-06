import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_application_2/features/faculty/attendance/faculty_attendance_screen.dart';
import 'package:flutter_application_2/features/faculty/dashboard/bottom_nav_bar.dart';
import 'package:flutter_application_2/features/faculty/dashboard/screens/company_list_screen.dart';
import 'package:flutter_application_2/features/faculty/dashboard/screens/faculty_company_mentors_screen.dart';
import 'package:flutter_application_2/features/faculty/dashboard/screens/faculty_notification_screen.dart';
import 'package:flutter_application_2/features/faculty/dashboard/screens/student_list.dart';
import 'package:flutter_application_2/features/faculty/dashboard/screens/faculty_student_list_screen.dart';
import 'package:flutter_application_2/features/faculty/dashboard/widgets/Faculty_action_card.dart';
import 'package:flutter_application_2/features/faculty/calendar/faculty_calendar_screen.dart';
import 'package:flutter_application_2/features/faculty/groups/groups_screen.dart';
import 'package:flutter_application_2/features/faculty/profile/screens/faculty_profile_screen.dart';
import 'package:flutter_application_2/features/faculty/tasks/assign_tasks_screen.dart';

class FacultyDashboardScreen extends StatefulWidget {
  const FacultyDashboardScreen({super.key});

  @override
  State<FacultyDashboardScreen> createState() => _FacultyDashboardScreenState();
}

class _FacultyDashboardScreenState extends State<FacultyDashboardScreen> {
  int _selectedIndex = 0;

  // --- DYNAMIC DATA VARIABLES ---
  bool isLoading = true;
  String facultyName = "Faculty";
  String facultyId = "";
  String department = "";
  String college = "";

  @override
  void initState() {
    super.initState();
    _loadFacultyData();
  }

  /// LOAD FACULTY DATA FROM FIRESTORE
  Future<void> _loadFacultyData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection("user").doc(user.uid).get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              facultyName = data["fullName"] ?? "Faculty";
              facultyId = (data["facultyId"] ?? data["uid"] ?? user.uid).toString();
              department = data["dept"] ?? "";
              college = data["college"] ?? "";
              isLoading = false;
            });
          }
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error loading faculty data: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 1:
        return const GroupsScreen();
      case 2:
        return const FacultyAttendanceScreen();
      case 3:
        // ✅ FIXED: Removed 'const' keyword to resolve "Not a constant expression" error
        return const FacultySettingsScreen();
      default:
        return _buildDashboardContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getSelectedScreen(),
      bottomNavigationBar: FacultyBottomNav(
        currentIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }

  Widget _buildDashboardContent() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      /// APPBAR
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
        title: const Text(
          "INTERN TRACKER",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("notifications").snapshots(),
            builder: (context, snapshot) {
              int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FacultyNotificationScreen()),
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back, $facultyName!",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                  ),
                  const SizedBox(height: 20),

                  /// PROFILE WARNING
                  if (department.isEmpty || college.isEmpty) ...[
                    _buildWarningCard(),
                    const SizedBox(height: 20),
                  ],

                  const Text(
                    "Overview",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  /// 4-TAB GRID (Student Style)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.45,
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("user")
                            .where("role", isEqualTo: "student")
                            .where("facultyId", isEqualTo: facultyId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          final studentCount = snapshot.hasData ? snapshot.data!.docs.length.toString() : "";
                          return _buildGridCard(
                            context,
                            title: "Students",
                            count: studentCount,
                            icon: Icons.people_alt_rounded,
                            color: Colors.blue,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentListScreen())),
                          );
                        },
                      ),
                      _buildGridCard(
                        context,
                        title: "Internships",
                        icon: Icons.business_center_rounded,
                        color: Colors.orange,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompaniesScreen())),
                      ),
                      _buildGridCard(
                        context,
                        title: "Reports",
                        icon: Icons.assignment_rounded,
                        color: Colors.deepOrange,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FacultyStudentListScreen())),
                      ),
                      _buildGridCard(
                        context,
                        title: "Events",
                        icon: Icons.event_available_rounded,
                        color: Colors.green,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FacultyCalendarScreen(showBackButton: true))),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "Management",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  FacultyActionCard(
                    icon: Icons.person_search_rounded,
                    title: "View Mentors",
                    subtitle: "Manage assigned company mentors",
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FacultyCompanyMentorsScreen())),
                  ),
                  const SizedBox(height: 15),

                  /// ASSIGN TASK GRADIENT CARD
                  _buildAssignTaskCard(context),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Please complete your profile in settings.",
              style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, {required String title, String? count, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: 10),
              if (count != null && count.isNotEmpty) ...[
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignTaskCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignTaskScreen(initialGroupId: ''))),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF60B5FF), Color(0xFF5EF2D5)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.add_task_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Assign New Task", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text("Task groups and individuals", style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
