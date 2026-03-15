import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'principal_student_list_screen.dart';

class PrincipalStudentSummaryScreen extends StatefulWidget {
  const PrincipalStudentSummaryScreen({super.key});

  @override
  State<PrincipalStudentSummaryScreen> createState() =>
      _PrincipalStudentSummaryScreenState();
}

class _PrincipalStudentSummaryScreenState
    extends State<PrincipalStudentSummaryScreen> {
  int? _selectedSectionIndex;

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
    'electronics & tc': 'Electronics Engineering',
    'electronics and tc': 'Electronics Engineering',
    'entc': 'Electronics Engineering',
    'e&tc': 'Electronics Engineering',
    'extc': 'Electronics Engineering',
    'automobile': 'Automobile Engineering',
    'automobile engineering': 'Automobile Engineering',
    'chemical': 'Chemical Engineering',
    'chemical engineering': 'Chemical Engineering',
    'instrumentation': 'Instrumentation Engineering',
    'instrumentation engineering': 'Instrumentation Engineering',
    'aiml': 'AI & ML',
    'ai/ml': 'AI & ML',
    'artificial intelligence': 'AI & ML',
    'artificial intelligence and machine learning': 'AI & ML',
    'ddgm': 'DDGM',
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
    'AI & ML',
    'DDGM',
    'Others',
  ];

  static const List<Color> _chartColors = [
    Color(0xFF60B5FF),
    Color(0xFF6EE7B7),
    Color(0xFFFFE588),
    Color(0xFFFCA5A5),
    Color(0xFFD1D5DB),
    Color(0xFFA78BFA),
    Color(0xFFFB923C),
    Color(0xFF2DD4BF),
    Color(0xFFF472B6),
    Color(0xFF8CC084),
    Color(0xFFB692FE),
    Color(0xFF9E9E9E),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 'student')
          .snapshots(),
      builder: (context, snapshot) {
        final summary = _buildSummary(snapshot.data?.docs ?? const []);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: _chartColors.first,
            elevation: 0,
            title: const Text(
              "Student Summary Analysis",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: _buildBody(context, snapshot, summary),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
    _StudentSummary summary,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "Unable to load student summary right now.",
            style: TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (summary.totalStudents == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "No student data available yet.",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_selectedSectionIndex != null &&
        _selectedSectionIndex! >= summary.departments.length) {
      _selectedSectionIndex = null;
    }

    final selectedDepartment = _selectedSectionIndex == null
        ? null
        : summary.departments[_selectedSectionIndex!];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Department Enrollment Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            "Live breakdown of ${summary.totalStudents} students across departments.",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (selectedDepartment != null)
            _buildSelectedInfoCard(selectedDepartment, summary.totalStudents),
          SizedBox(
            height: 350,
            child: PieChart(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 20,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    final touchedIndex =
                        response?.touchedSection?.touchedSectionIndex;

                    if (!event.isInterestedForInteractions ||
                        touchedIndex == null ||
                        touchedIndex < 0 ||
                        touchedIndex >= summary.departments.length) {
                      return;
                    }

                    if (_selectedSectionIndex != touchedIndex) {
                      setState(() {
                        _selectedSectionIndex = touchedIndex;
                      });
                    }
                  },
                ),
                sections: List.generate(summary.departments.length, (index) {
                  final department = summary.departments[index];
                  final percentage = summary.totalStudents == 0
                      ? 0.0
                      : (department.count / summary.totalStudents) * 100;
                  final isSelected = _selectedSectionIndex == index;

                  return PieChartSectionData(
                    color: department.color,
                    value: department.count.toDouble(),
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: isSelected ? 118 : 110,
                    titleStyle: TextStyle(
                      fontSize: isSelected ? 14 : 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    badgeWidget: isSelected
                        ? _buildSectionBadge(
                            "${percentage.toStringAsFixed(0)}%",
                            department.color,
                          )
                        : null,
                    badgePositionPercentageOffset: 1.2,
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _selectedSectionIndex == null
                  ? null
                  : () => setState(() => _selectedSectionIndex = null),
              child: const Text("Clear selection"),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 20),
          ...summary.departments.map(
            (department) => _buildDeptListTile(
              context,
              department.name,
              "${department.count} Students",
              department.color,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSelectedInfoCard(
    _StudentDepartmentSummary department,
    int totalStudents,
  ) {
    final percentage = totalStudents == 0
        ? 0.0
        : (department.count / totalStudents) * 100;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: department.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: department.color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: department.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  department.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${department.count} of $totalStudents students belong to this department",
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "${percentage.toStringAsFixed(1)}%",
            style: TextStyle(
              color: department.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionBadge(String text, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  _StudentSummary _buildSummary(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final counts = <String, int>{};

    for (final doc in docs) {
      final data = doc.data();
      final department = _normalizeDept(data['dept']?.toString());
      counts[department] = (counts[department] ?? 0) + 1;
    }

    final sortedNames = counts.keys.toList()
      ..sort((a, b) {
        final indexA = _departmentOrder.indexOf(a);
        final indexB = _departmentOrder.indexOf(b);
        final safeA = indexA == -1 ? _departmentOrder.length : indexA;
        final safeB = indexB == -1 ? _departmentOrder.length : indexB;
        return safeA.compareTo(safeB);
      });

    final departments = List.generate(sortedNames.length, (index) {
      final name = sortedNames[index];
      return _StudentDepartmentSummary(
        name: name,
        count: counts[name] ?? 0,
        color: _chartColors[index % _chartColors.length],
      );
    });

    return _StudentSummary(
      totalStudents: docs.length,
      departments: departments,
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

  Widget _buildDeptListTile(
    BuildContext context,
    String title,
    String subtitle,
    Color indicatorColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PrincipalStudentListScreen(department: title, year: "2026"),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.black45,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 10,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentSummary {
  final int totalStudents;
  final List<_StudentDepartmentSummary> departments;

  const _StudentSummary({
    required this.totalStudents,
    required this.departments,
  });
}

class _StudentDepartmentSummary {
  final String name;
  final int count;
  final Color color;

  const _StudentDepartmentSummary({
    required this.name,
    required this.count,
    required this.color,
  });
}
