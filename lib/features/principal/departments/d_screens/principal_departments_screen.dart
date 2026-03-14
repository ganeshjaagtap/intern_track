import 'package:flutter/material.dart';

class PrincipalDepartmentScreen extends StatelessWidget {
  // ✅ RED LINE FIX: Removed 'const' keyword from constructor
  PrincipalDepartmentScreen({super.key});

  // Colors from your specific palette
  final Color coolSky = const Color(0xFF60B5FF);
  final Color jasmine = const Color(0xFFFFE588);
  final Color tangerine = const Color(0xFFF79D65);
  final Color strawberry = const Color(0xFFF35252);
  final Color aquamarine = const Color(0xFF5EF2D5);

  @override
  Widget build(BuildContext context) {
    // ❌ NO Scaffold or AppBar here: Prevents the bulky double-header
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 10),
        // ✅ Page title moved into the body for a clean executive look
        const Text(
          "Departments",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Monitoring internship completion status across 9 departments.",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 24),

        // 📊 List of 9 Departments
        _buildDeptChartCard("Information Technology", 42, 60, coolSky),
        _buildDeptChartCard("Computer Engineering", 58, 60, aquamarine),
        _buildDeptChartCard("Artificial Intelligence & ML", 35, 40, jasmine),
        _buildDeptChartCard("Electronics & Telecommunication", 25, 45, coolSky),
        _buildDeptChartCard("Electrical Engineering", 30, 50, tangerine),
        _buildDeptChartCard("Mechanical Engineering", 40, 60, tangerine),
        _buildDeptChartCard("Civil Engineering", 15, 55, strawberry),
        _buildDeptChartCard("Automobile Engineering", 22, 40, tangerine),
        _buildDeptChartCard(
          "Dress Designing & Garments Mfg.",
          28,
          30,
          aquamarine,
        ),

        const SizedBox(height: 110), // Space for floating bar
      ],
    );
  }

  Widget _buildDeptChartCard(
    String name,
    int placed,
    int total,
    Color themeColor,
  ) {
    final double progress = placed / total;

    return Container(
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
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
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
              _buildBarColumn(placed, total, themeColor),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Branch Strength: $total",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Interns Placed: $placed",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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
                        "${total - placed} Remaining",
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
    );
  }

  Widget _buildBarColumn(int value, int total, Color color) {
    final double barHeight = (value / total) * 80;

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
            height: barHeight,
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
          "PLACED",
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
