import 'package:flutter/material.dart';

class AppConstants {
  // This is the one place you change numbers
  static const List<Map<String, dynamic>> deptData = [
    {
      "name": "Information Technology",
      "count": "50/50",
      "val": 50,
      "color": Color(0xFF60B5FF),
    },
    {
      "name": "Computer Engineering",
      "count": "75/75",
      "val": 75,
      "color": Color(0xFF6EE7B7),
    },
    {
      "name": "Mechanical Engineering",
      "count": "40/40",
      "val": 40,
      "color": Color(0xFFFFE588),
    },
    {
      "name": "Civil Engineering",
      "count": "30/30",
      "val": 30,
      "color": Color(0xFFFCA5A5),
    },
    {
      "name": "Electrical Engineering",
      "count": "25/25",
      "val": 25,
      "color": Color(0xFFD1D5DB),
    },
    {
      "name": "Electronics & TC",
      "count": "35/35",
      "val": 35,
      "color": Color(0xFFA78BFA),
    },
    {
      "name": "Automobile Engineering",
      "count": "10/10",
      "val": 10,
      "color": Color(0xFFFB923C),
    },
    {"name": "DDGM", "count": "12/12", "val": 12, "color": Color(0xFF2DD4BF)},
    {"name": "AIML", "count": "8/8", "val": 8, "color": Color(0xFFF472B6)},
  ];

  static double get totalStudents =>
      deptData.fold(0, (sum, item) => sum + item['val']);
}
