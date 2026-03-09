import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/faculty/dashboard/screens/student_detail_screen.dart';

class StudentListScreen extends StatefulWidget {
  final String department;

  const StudentListScreen({super.key, this.department = "IoT"});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, String>> _allStudents = [
    {
 "name": "Aditya Verma",
 "roll": "237032",
 "dept": "IoT",
 "year": "3rd Year",
 "email": "aditya@gmail.com",
 "phone": "9876543210",
 "company": "Infosys",
 "role": "Flutter Developer",
 "type": "Online",
 "start": "01 Jan 2026",
 "end": "30 Mar 2026",
 "status": "Active",
 "attendance": "92%",
 "collegeMentor": "Dr. Kundlikar",
 "companyMentor": "Mr. Sharma"
},
    {
      "name": "Sanya Malhotra",
      "roll": "237033",
      "dept": "IoT",
      "year": "3rd Year",
      "email": "sanya@college.com",
      "phone": "9123456780",
      "company": "TCS",
      "role": "Web Developer",
      "type": "Internship",
      "start": "10 Jan 2026",
      "end": "10 Apr 2026",
      "status": "Ongoing",
      "collegeMentor": "Prof. Kulkarni",
      "companyMentor": "Mr. Singh"
    },
    {
      "name": "Rahul Deshmukh",
      "roll": "237034",
      "dept": "IoT",
      "year": "3rd Year",
      "email": "rahul@college.com",
      "phone": "9988776655",
      "company": "Wipro",
      "role": "Backend Developer",
      "type": "Internship",
      "start": "05 Feb 2026",
      "end": "05 May 2026",
      "status": "Ongoing",
      "collegeMentor": "Dr. Jadhav",
      "companyMentor": "Ms. Mehta"
    },
    {
      "name": "Neha Patil",
      "roll": "237035",
      "dept": "IoT",
      "year": "3rd Year",
      "email": "neha@college.com",
      "phone": "9090909090",
      "company": "Capgemini",
      "role": "UI Designer",
      "type": "Internship",
      "start": "15 Feb 2026",
      "end": "15 May 2026",
      "status": "Pending",
      "collegeMentor": "Prof. Joshi",
      "companyMentor": "Mr. Kumar"
    }
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _allStudents.where((student) {
      final name = student["name"]!.toLowerCase();
      final roll = student["roll"]!;
      return name.contains(_searchQuery.toLowerCase()) ||
          roll.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.department} Students"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          /// Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search student...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          /// Student List
          Expanded(
            child: ListView.builder(
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final student = filteredStudents[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(student["name"]![0]),
                    ),
                    title: Text(student["name"]!),
                    subtitle: Text("Roll No: ${student["roll"]}"),
                    trailing:
                        const Icon(Icons.arrow_forward_ios, size: 16),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StudentDetailsScreen(student: student),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}