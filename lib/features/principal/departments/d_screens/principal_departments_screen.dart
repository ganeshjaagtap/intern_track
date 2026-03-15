import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'principal_years_screen.dart';

class PrincipalDepartmentScreen extends StatelessWidget {
  PrincipalDepartmentScreen({super.key});

  final Color coolSky = const Color(0xFF60B5FF);
  final Color jasmine = const Color(0xFFFFE588);
  final Color tangerine = const Color(0xFFF79D65);
  final Color strawberry = const Color(0xFFF35252);
  final Color aquamarine = const Color(0xFF5EF2D5);

  static const Map<String, String> _departmentAliases = {
    'it': 'Information Technology',
    'information technology': 'Information Technology',
    'information tech': 'Information Technology',
    'cse': 'Computer Engineering',
    'computer science': 'Computer Engineering',
    'computer engineering': 'Computer Engineering',
    'computer': 'Computer Engineering',
    'cs': 'Computer Engineering',
    'aiml': 'Artificial Intelligence & ML',
    'ai & ml': 'Artificial Intelligence & ML',
    'artificial intelligence and machine learning':
        'Artificial Intelligence & ML',
    'artificial intelligence & machine learning':
        'Artificial Intelligence & ML',
    'entc': 'Electronics & Telecommunication',
    'e&tc': 'Electronics & Telecommunication',
    'electronics & telecommunication': 'Electronics & Telecommunication',
    'electronics and telecommunication': 'Electronics & Telecommunication',
    'electronics': 'Electronics & Telecommunication',
    'electrical': 'Electrical Engineering',
    'electrical engineering': 'Electrical Engineering',
    'me': 'Mechanical Engineering',
    'mechanical': 'Mechanical Engineering',
    'mechanical engineering': 'Mechanical Engineering',
    'civil': 'Civil Engineering',
    'civil engineering': 'Civil Engineering',
    'automobile': 'Automobile Engineering',
    'automobile engineering': 'Automobile Engineering',
    'ddgm': 'Dress Designing & Garments Mfg.',
    'dress designing & garments mfg.': 'Dress Designing & Garments Mfg.',
    'dress designing and garments mfg.': 'Dress Designing & Garments Mfg.',
    'dress designing': 'Dress Designing & Garments Mfg.',
  };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 'student')
          .snapshots(),
      builder: (context, snapshot) {
        final departmentSummaries = _buildDepartmentSummaries(
          snapshot.data?.docs ?? const [],
        );

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 10),
            const Text(
              'Departments',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              snapshot.connectionState == ConnectionState.waiting
                  ? 'Loading department internship status...'
                  : 'Monitoring internship completion status across ${departmentSummaries.length} departments.',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (snapshot.hasError)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'Unable to load departments right now.',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              )
            else if (departmentSummaries.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'No student department data found.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...departmentSummaries.asMap().entries.map((entry) {
                final index = entry.key;
                final summary = entry.value;
                return _buildDeptChartCard(context, summary, _colorForIndex(index));
              }),
            const SizedBox(height: 110),
          ],
        );
      },
    );
  }

  List<_DepartmentSummary> _buildDepartmentSummaries(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final summaryByDepartment = <String, _DepartmentSummary>{};

    for (final doc in docs) {
      final data = doc.data();
      final department = _normalizeDepartment((data['dept'] ?? '').toString());
      final status = (data['internshipStatus'] ?? '').toString();
      final current = summaryByDepartment[department] ??
          const _DepartmentSummary(
            name: '',
            totalStudents: 0,
            activeOrCompleted: 0,
            completedStudents: 0,
          );

      summaryByDepartment[department] = _DepartmentSummary(
        name: department,
        totalStudents: current.totalStudents + 1,
        activeOrCompleted:
            current.activeOrCompleted + (_isPursuingOrCompleted(status) ? 1 : 0),
        completedStudents:
            current.completedStudents + (_isCompletedStatus(status) ? 1 : 0),
      );
    }

    final summaries = summaryByDepartment.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return summaries;
  }

  String _normalizeDepartment(String rawDept) {
    final normalized = rawDept.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'Others';
    }
    return _departmentAliases[normalized] ?? rawDept.trim();
  }

  bool _isCompletedStatus(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == 'completed' || normalized == 'complete';
  }

  bool _isPursuingOrCompleted(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == 'completed' ||
        normalized == 'complete' ||
        normalized == 'ongoing' ||
        normalized == 'pursuing' ||
        normalized == 'active' ||
        normalized == 'in progress' ||
        normalized == 'inprogress';
  }

  Color _colorForIndex(int index) {
    const palette = <Color>[
      Color(0xFF60B5FF),
      Color(0xFF5EF2D5),
      Color(0xFFFFE588),
      Color(0xFFF79D65),
      Color(0xFFF35252),
    ];
    return palette[index % palette.length];
  }

  Widget _buildDeptChartCard(
    BuildContext context,
    _DepartmentSummary summary,
    Color themeColor,
  ) {
    final total = summary.totalStudents;
    final activeOrCompleted = summary.activeOrCompleted;
    final completed = summary.completedStudents;
    final progress = total == 0 ? 0.0 : activeOrCompleted / total;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PrincipalYearScreen(
              departmentName: summary.name,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    summary.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    color: themeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBarColumn(activeOrCompleted, total, themeColor),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Branch Strength: $total',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pursuing/Completed: $activeOrCompleted',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Completed: $completed',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${total - activeOrCompleted} Remaining',
                          style: TextStyle(
                            fontSize: 11,
                            color: themeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarColumn(int value, int total, Color color) {
    final safeTotal = total <= 0 ? 1 : total;
    final barHeight = (value / safeTotal) * 80;

    return Column(
      children: [
        Container(
          height: 80,
          width: 45,
          alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            height: barHeight.clamp(0, 80).toDouble(),
            width: 45,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color, color.withOpacity(0.8)],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'ACTIVE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _DepartmentSummary {
  final String name;
  final int totalStudents;
  final int activeOrCompleted;
  final int completedStudents;

  const _DepartmentSummary({
    required this.name,
    required this.totalStudents,
    required this.activeOrCompleted,
    required this.completedStudents,
  });
}
