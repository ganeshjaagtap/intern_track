import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'principal_student_list_screen.dart';
// Import your new constants file here
import '../../../../core/constants/app_data.dart';

class PrincipalStudentSummaryScreen extends StatelessWidget {
  const PrincipalStudentSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We pull the data from the Constant file instead of defining it here
    final deptData = AppConstants.deptData;
    final totalStudents = AppConstants.totalStudents;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppConstants
            .deptData[0]['color'], // Using the first dept color for consistency
        elevation: 0,
        title: const Text(
          "Student Summary Analysis",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Department Enrollment Overview",              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Detailed breakdown of student distribution.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            // --- 1. UPDATED PIE CHART SECTION ---
            SizedBox(
              height: 350,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius:
                      20, // 👈 Reduced from 50 to 20 to shrink white space
                  sections: deptData.map<PieChartSectionData>((dept) {
                    double percentage = (dept['val'] / totalStudents) * 100;
                    return PieChartSectionData(
                      color: dept['color'],
                      value: dept['val'].toDouble(),
                      title: '${percentage.toStringAsFixed(0)}%',
                      radius: 110, // 👈 Increased radius to fill the space
                      titleStyle: const TextStyle(
                        // ✅ Correct parameter for fl_chart 1.1.1
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 20),

            // --- 2. THE LIST TILES ---
            ...deptData.map(
              (dept) => _buildDeptListTile(
                context,
                dept['name'],
                "${dept['count']} Students",
                dept['color'],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
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
