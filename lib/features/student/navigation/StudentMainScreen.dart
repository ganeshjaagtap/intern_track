import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/features/chat/chat_list_screen.dart';

//import 'package:flutter_application_2/features/chat/screens/chat_selection_screen.dart';

import '../dashboard/StudentDashboardScreen.dart';
import '../attendance/AttendanceScreen.dart';
import '../reports/ReportScreen.dart';
import '../profile/SettingsScreen.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int currentIndex = 0;
  String enrollmentNo = "";
  
  // Dedicated loading variable
  bool isLoading = true; 

  @override
  void initState() {
    super.initState();
    loadStudentData();
  }

  /// LOAD STUDENT DATA FROM FIRESTORE
  Future<void> loadStudentData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection("user")
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          
          if (mounted) {
            setState(() {
              // Safely pull the data. If it doesn't exist, default to ""
              enrollmentNo = data["enrollmentNo"] ?? "";
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print("Error loading student data: $e");
      if (mounted) {
        setState(() {
          isLoading = false; // Stop loading even if there is an error
        });
      }
    }
  }

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Check the isLoading boolean to prevent infinite spinner
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    final List<Widget> screens = [
      const StudentDashboardScreen(),
      AttendanceScreen(
        enrollmentNo: enrollmentNo, // Passes "" if they haven't set it yet
      ),
      const ReportScreen(),
      const SettingsScreen(), 
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: _CustomBottomNav(
        currentIndex: currentIndex,
        onTabSelected: changeTab,
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// CUSTOM BOTTOM NAV
////////////////////////////////////////////////////////////

class _CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const _CustomBottomNav({
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 56,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _navItem(
                      icon: Icons.home,
                      label: "Home",
                      active: currentIndex == 0,
                      onTap: () => onTabSelected(0),
                    ),
                  ),
                  Expanded(
                    child: _navItem(
                      icon: Icons.check_circle_outline,
                      label: "Attendance",
                      active: currentIndex == 1,
                      onTap: () => onTabSelected(1),
                    ),
                  ),
                  const SizedBox(width: 60),
                  Expanded(
                    child: _navItem(
                      icon: Icons.description,
                      label: "Report",
                      active: currentIndex == 2,
                      onTap: () => onTabSelected(2),
                    ),
                  ),
                  Expanded(
                    child: _navItem(
                      icon: Icons.settings,
                      label: "Settings", 
                      active: currentIndex == 3,
                      onTap: () => onTabSelected(3),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// CHAT BUTTON
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChatListScreen(),
                  ),
                );
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.blue,
                    width: 4,
                  ),
                ),
                child: const Icon(
                  Icons.chat_sharp,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool active,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: active ? Colors.blue : Colors.grey,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
