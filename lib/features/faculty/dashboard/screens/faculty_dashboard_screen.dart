import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/features/chat/screens/chat_selection_screen.dart';
import 'package:flutter_application_2/features/faculty/dashboard/bottom_nav_bar.dart';
import 'package:flutter_application_2/features/faculty/dashboard/screens/company_list_screen.dart';
import 'package:flutter_application_2/features/faculty/dashboard/screens/faculty_notification_screen.dart';
import 'package:flutter_application_2/features/faculty/dashboard/screens/student_list.dart';
import 'package:flutter_application_2/features/faculty/dashboard/widgets/Faculty_action_card.dart';
import 'package:flutter_application_2/features/faculty/dashboard/widgets/faculty_stats_card.dart';
import 'package:flutter_application_2/features/faculty/calendar/faculty_calendar_screen.dart';
import 'package:flutter_application_2/features/faculty/groups/groups_screen.dart';
import 'package:flutter_application_2/features/faculty/profile/screens/faculty_profile_screen.dart';
import 'package:flutter_application_2/features/faculty/tasks/assign_tasks_screen.dart';

class FacultyDashboardScreen extends StatefulWidget {
  const FacultyDashboardScreen({super.key});

  @override
  State<FacultyDashboardScreen> createState() =>
      _FacultyDashboardScreenState();
}

class _FacultyDashboardScreenState extends State<FacultyDashboardScreen> {

  int _selectedIndex = 0;

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
        return const FacultyCalendarScreen();
      case 3:
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
      backgroundColor: const Color(0xFFF4F4F4),

      /// APPBAR
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
        title: const Text(
          "INTERN TRACKER",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [

          /// 🔔 REALTIME NOTIFICATION BADGE
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("notifications")
                .snapshots(),

            builder: (context, snapshot) {

              int count = 0;

              if (snapshot.hasData) {
                count = snapshot.data!.docs.length;
              }

              return Stack(
                children: [

                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const FacultyNotificationScreen(),
                        ),
                      );
                    },
                  ),

                  /// 🔴 BADGE
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),

      /// BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Welcome back, Faculty!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            /// STATS
            Row(
              children: [

                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const StudentListScreen(),
                        ),
                      );
                    },
                    child: MiniStatCard(
                      icon: Icons.group,
                      value: "42",
                      label: "Students",
                      bg: const Color(0xFFD9ECFF),
                      iconColor: Colors.blue,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CompaniesScreen(),
                        ),
                      );
                    },
                    child: MiniStatCard(
                      icon: Icons.work,
                      value: "5",
                      label: "Internships",
                      bg: const Color(0xFFFFF2CC),
                      iconColor: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AssignTaskScreen(),
                        ),
                      );
                    },
                    child: MiniStatCard(
                      icon: Icons.assignment,
                      value: "18",
                      label: "Reports",
                      bg: const Color(0xFFFFE6D9),
                      iconColor: Colors.deepOrange,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AssignTaskScreen(),
                        ),
                      );
                    },
                    child: MiniStatCard(
                      icon: Icons.pending_actions,
                      value: "6",
                      label: "Pending",
                      bg: const Color(0xFFDFF5EA),
                      iconColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Recent Activity",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const FacultyActionCard(
              icon: Icons.person,
              title: "View Mentors",
              subtitle: "Manage assigned mentors",
            ),

            const SizedBox(height: 12),

            const FacultyActionCard(
              icon: Icons.work_outline,
              title: "Internship Details",
              subtitle: "View and update internships",
            ),

            const SizedBox(height: 20),

            /// ASSIGN TASK CARD
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AssignTaskScreen(),
                  ),
                );
              },

              child: Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF60B5FF),
                      Color(0xFF5EF2D5),
                    ],
                  ),

                  borderRadius: BorderRadius.circular(16),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),

                child: Row(
                  children: [

                    Container(
                      padding: const EdgeInsets.all(10),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: const Icon(
                        Icons.assignment_add,
                        color: Color(0xFF60B5FF),
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 14),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Assign Task",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Assign tasks to student groups",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}