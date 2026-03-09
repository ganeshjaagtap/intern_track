import 'package:flutter/material.dart';
import 'package:flutter_application_2/university_mentor/screens/mentor_screen.dart';
import 'package:flutter_application_2/university_mentor/screens/companies_screen.dart';
import 'package:flutter_application_2/university_mentor/screens/hod_dashboard_screen.dart';
import 'package:flutter_application_2/university_mentor/screens/mentor_profile_screen.dart';
import 'package:flutter_application_2/university_mentor/screens/hod_notifications_screen.dart'; // ✅ ADD THIS

class MentorMainLayout extends StatefulWidget {
  const MentorMainLayout({super.key});

  @override
  State<MentorMainLayout> createState() => _MentorMainLayoutState();
}

class _MentorMainLayoutState extends State<MentorMainLayout> {

  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MentorDashboardScreen(),
    const MentorScreen(),
    const CompaniesScreen(),
    const MentorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    const primaryBlue = Color(0xFF64A9F6);
    const bgLight = Color(0xFFF5F7F9);

    return Scaffold(
      backgroundColor: bgLight,

      /// APP BAR
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        centerTitle: false,

        title: const Text(
          "INTERN TRACKER",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),

        actions: [

          /// 🔔 NOTIFICATION BUTTON
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Colors.white,
            ),

            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const HodNotificationsScreen(),
                ),
              );

            },
          ),

          const SizedBox(width: 8),
        ],
      ),

      /// BODY
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      /// FLOATING BOTTOM NAV
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),

          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: primaryBlue,
            unselectedItemColor: Colors.grey.shade400,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            backgroundColor: Colors.white,
            elevation: 0,

            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },

            items: const [

              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded),
                label: "Hub",
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.people_alt_rounded),
                label: "Mentors",
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.business_center_rounded),
                label: "Companies",
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_rounded),
                label: "Profile",
              ),

            ],
          ),
        ),
      ),
    );
  }
}