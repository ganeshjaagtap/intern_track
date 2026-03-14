import 'package:flutter/material.dart';

class DepartmentModel {
  final String id;
  final String name;
  final int totalStudents;
  final int activeInterns;
  final int completionRate;
  final int pendingApprovals;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.totalStudents,
    required this.activeInterns,
    required this.completionRate,
    required this.pendingApprovals,
  });

  // 🎨 Dynamic Color Getter
  Color get progressColor {
    if (completionRate >= 80) {
      return Colors.green;
    } else if (completionRate >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
