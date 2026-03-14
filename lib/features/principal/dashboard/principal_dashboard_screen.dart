import 'package:flutter/material.dart';
import '../students/principal_students_screen.dart';
import '../departments/d_screens/principal_departments_screen.dart';
import '../departments/d_screens/principal_companies_module.dart';
import '../departments/d_screens/principal_profile_screen.dart';
import 'summary_screens/principal_student_summary_screen.dart';
import 'summary_screens/principal_active_intern_summary_screen.dart';
import 'principal_notifications_screen.dart';

class PrincipalDashboardScreen extends StatefulWidget {
  const PrincipalDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PrincipalDashboardScreen> createState() =>
      _PrincipalDashboardScreenState();
}

class _PrincipalDashboardScreenState extends State<PrincipalDashboardScreen> {
  int _currentIndex = 0;
  bool _hasNewNotifications = true;

  final Color jasmine = const Color(0xFFFFE588);
  final Color tangerine = const Color(0xFFF79D65);
  final Color strawberry = const Color(0xFFF35252);
  final Color aquamarine = const Color(0xFF5EF2D5);
  final Color coolSky = const Color(0xFF60B5FF);

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildHomeContent(),
      PrincipalDepartmentScreen(),
      const PrincipalCompanyTab(),
      PrincipalProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBody: true,
      appBar: AppBar(
        backgroundColor: coolSky,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "INTERN TRACKER",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _hasNewNotifications
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() => _hasNewNotifications = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrincipalNotificationsScreen(),
                    ),
                  );
                },
              ),
              if (_hasNewNotifications)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: coolSky, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          const SizedBox(height: 10),
          const Text(
            "Institute Performance Overview",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // ✅ Updated: Overall Student Info Card (No Count)
              _buildStatCard(
                icon: Icons.people,
                number: "View",
                label: "Overall Student Info",
                color: coolSky.withOpacity(0.25),
                iconColor: Colors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrincipalStudentSummaryScreen(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // ✅ Updated: Active Intern Info Card (No Count)
              _buildStatCard(
                icon: Icons.work,
                number: "Track",
                label: "Active Intern Info",
                color: jasmine.withOpacity(0.6),
                iconColor: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const PrincipalActiveInternSummaryScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            "Overall Internship Completion",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPieChartSection("85% Completion Rate", 0.85, aquamarine),
          const SizedBox(height: 32),
          const Text(
            "Departmental Progress",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildBarGraph("Information Tech.", 0.92, coolSky),
          _buildBarGraph("Computer Engineering", 0.80, jasmine),
          _buildBarGraph("Mechanical Engineering", 0.65, tangerine),
          _buildBarGraph("Civil Engineering", 0.40, strawberry),
          const SizedBox(height: 110),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String number,
    required String label,
    required Color color,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 85,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      number,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPieChartSection(String label, double percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 90,
                width: 90,
                child: CircularProgressIndicator(
                  value: percentage,
                  strokeWidth: 12,
                  color: color,
                  backgroundColor: Colors.grey[100],
                ),
              ),
              Text(
                "${(percentage * 100).toInt()}%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Institute Average",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarGraph(String label, double progress, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              color: color,
              backgroundColor: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: coolSky,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.apartment_outlined),
                activeIcon: Icon(Icons.apartment),
                label: "Depts",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business_center_outlined),
                activeIcon: Icon(Icons.business_center),
                label: "Companies",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
