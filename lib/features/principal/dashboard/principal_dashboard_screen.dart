import 'package:cloud_firestore/cloud_firestore.dart';
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

  static const Map<String, String> _departmentAliases = {
    'it': 'IT Department',
    'information technology': 'IT Department',
    'information tech': 'IT Department',
    'information tech.': 'IT Department',
    'cse': 'Computer Science',
    'computer science': 'Computer Science',
    'computer engineering': 'Computer Science',
    'computer': 'Computer Science',
    'cs': 'Computer Science',
    'me': 'Mechanical Engineering',
    'mechanical': 'Mechanical Engineering',
    'mechanical engineering': 'Mechanical Engineering',
    'civil': 'Civil Engineering',
    'ce': 'Civil Engineering',
    'civil engineering': 'Civil Engineering',
    'ee': 'Electrical Engineering',
    'electrical': 'Electrical Engineering',
    'electrical engineering': 'Electrical Engineering',
    'eee': 'Electrical Engineering',
    'electronics': 'Electronics Engineering',
    'electronics engineering': 'Electronics Engineering',
    'entc': 'Electronics Engineering',
    'e&tc': 'Electronics Engineering',
    'extc': 'Electronics Engineering',
    'automobile': 'Automobile Engineering',
    'automobile engineering': 'Automobile Engineering',
    'chemical': 'Chemical Engineering',
    'chemical engineering': 'Chemical Engineering',
    'instrumentation': 'Instrumentation Engineering',
    'instrumentation engineering': 'Instrumentation Engineering',
  };

  static const List<String> _departmentOrder = [
    'IT Department',
    'Computer Science',
    'Mechanical Engineering',
    'Civil Engineering',
    'Electrical Engineering',
    'Electronics Engineering',
    'Automobile Engineering',
    'Chemical Engineering',
    'Instrumentation Engineering',
    'Others',
  ];

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
          _buildOverallInternshipCompletionSection(),
          const SizedBox(height: 32),
          const Text(
            "Departmental Progress",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDepartmentProgressSection(),
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

  Widget _buildOverallInternshipCompletionSection() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 'student')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _buildPieChartSection(
            "Unable to load completion data",
            0,
            aquamarine,
          );
        }

        final docs = snapshot.data?.docs ?? const [];
        final totalStudents = docs.length;
        final completedStudents = docs.where((doc) {
          final status = doc.data()['internshipStatus']?.toString() ?? '';
          return _isCompletedStatus(status);
        }).length;

        final completionRate = totalStudents == 0
            ? 0.0
            : completedStudents / totalStudents;

        return _buildPieChartSection(
          "$completedStudents/$totalStudents Students Completed",
          completionRate,
          aquamarine,
        );
      },
    );
  }

  Widget _buildDepartmentProgressSection() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 'student')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "Unable to load department progress right now.",
              style: TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? const [];
        if (docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              "No student data available yet.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final progressByDept = <String, _DepartmentProgress>{};

        for (final doc in docs) {
          final data = doc.data();
          final department = _normalizeDept(data['dept']?.toString());
          final status = data['internshipStatus']?.toString() ?? '';

          final current = progressByDept.putIfAbsent(
            department,
            () => const _DepartmentProgress(total: 0, activeOrCompleted: 0),
          );

          progressByDept[department] = _DepartmentProgress(
            total: current.total + 1,
            activeOrCompleted: current.activeOrCompleted +
                (_isPursuingOrCompletedStatus(status) ? 1 : 0),
          );
        }

        final entries = progressByDept.entries.toList()
          ..sort((a, b) {
            final indexA = _departmentOrder.indexOf(a.key);
            final indexB = _departmentOrder.indexOf(b.key);
            final safeA = indexA == -1 ? _departmentOrder.length : indexA;
            final safeB = indexB == -1 ? _departmentOrder.length : indexB;
            return safeA.compareTo(safeB);
          });

        return Column(
          children: List.generate(entries.length, (index) {
            final entry = entries[index];
            final progress = entry.value.total == 0
                ? 0.0
                : entry.value.activeOrCompleted / entry.value.total;

            return _buildDepartmentProgressCard(
              label: entry.key,
              progress: progress,
              activeOrCompleted: entry.value.activeOrCompleted,
              total: entry.value.total,
              color: _progressColorForIndex(index),
            );
          }),
        );
      },
    );
  }

  Widget _buildDepartmentProgressCard({
    required String label,
    required double progress,
    required int activeOrCompleted,
    required int total,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                "${(progress * 100).toStringAsFixed(0)}%",
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 14,
              color: color,
              backgroundColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "$activeOrCompleted/$total Students Pursuing or Completed",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _normalizeDept(String? dept) {
    if (dept == null) {
      return 'Others';
    }

    final normalized = dept.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'Others';
    }

    return _departmentAliases[normalized] ?? 'Others';
  }

  bool _isCompletedStatus(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == 'completed' || normalized == 'complete';
  }

  bool _isPursuingOrCompletedStatus(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == 'completed' ||
        normalized == 'complete' ||
        normalized == 'ongoing' ||
        normalized == 'pursuing' ||
        normalized == 'active' ||
        normalized == 'in progress' ||
        normalized == 'inprogress';
  }

  Color _progressColorForIndex(int index) {
    const palette = <Color>[
      Color(0xFF60B5FF),
      Color(0xFFFFE588),
      Color(0xFFF79D65),
      Color(0xFFF35252),
      Color(0xFF5EF2D5),
      Color(0xFF7A9E9F),
      Color(0xFFB692FE),
      Color(0xFFFF9F9F),
      Color(0xFF8CC084),
      Color(0xFF9E9E9E),
    ];

    return palette[index % palette.length];
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

class _DepartmentProgress {
  final int total;
  final int activeOrCompleted;

  const _DepartmentProgress({
    required this.total,
    required this.activeOrCompleted,
  });
}
