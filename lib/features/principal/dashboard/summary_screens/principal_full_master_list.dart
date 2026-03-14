import 'package:flutter/material.dart';
import 'principal_student_profile_screen.dart';

class PrincipalFullMasterList extends StatefulWidget {
  const PrincipalFullMasterList({super.key});

  @override
  State<PrincipalFullMasterList> createState() =>
      _PrincipalFullMasterListState();
}

class _PrincipalFullMasterListState extends State<PrincipalFullMasterList> {
  final Color coolSky = const Color(0xFF60B5FF);
  String searchQuery = "";

  // ✅ 30 Detailed Student Entries for the Master List
  final List<Map<String, String>> allStudents = [
    {"name": "ganesh", "id": "237032", "dept": "IT", "status": "Placed"},
    {
      "name": "Siddhika Deshmukh",
      "id": "237057",
      "dept": "Computer",
      "status": "Applied",
    },
    {
      "name": "Amit Rane",
      "id": "237088",
      "dept": "Mechanical",
      "status": "Not Started",
    },
    {"name": "shiv", "id": "237033", "dept": "Civil", "status": "Placed"},
    {"name": "Sneha Patil", "id": "237045", "dept": "IT", "status": "Applied"},
    {
      "name": "Rahul Mehta",
      "id": "237011",
      "dept": "Electrical",
      "status": "Placed",
    },
    {
      "name": "Priya Singh",
      "id": "237092",
      "dept": "Electronics",
      "status": "Not Started",
    },
    {
      "name": "Vikram Joshi",
      "id": "237105",
      "dept": "Automobile",
      "status": "Applied",
    },
    {
      "name": "Ananya Iyer",
      "id": "237015",
      "dept": "Chemical",
      "status": "Placed",
    },
    {
      "name": "Rohan Das",
      "id": "237044",
      "dept": "Instrumentation",
      "status": "Not Started",
    },
    {"name": "Neha Kulkarni", "id": "237081", "dept": "IT", "status": "Placed"},
    {
      "name": "Arjun Malhotra",
      "id": "237099",
      "dept": "Computer",
      "status": "Applied",
    },
    {
      "name": "Suresh Raina",
      "id": "237022",
      "dept": "Mechanical",
      "status": "Placed",
    },
    {
      "name": "Kavita Reddy",
      "id": "237067",
      "dept": "Civil",
      "status": "Not Started",
    },
    {
      "name": "Manoj Tiwari",
      "id": "237038",
      "dept": "Electrical",
      "status": "Applied",
    },
    {
      "name": "Deepika Padne",
      "id": "237019",
      "dept": "Electronics",
      "status": "Placed",
    },
    {"name": "Sahil Khan", "id": "237112", "dept": "IT", "status": "Applied"},
    {
      "name": "Pooja Hegde",
      "id": "237055",
      "dept": "Computer",
      "status": "Not Started",
    },
    {
      "name": "Abhishek B",
      "id": "237029",
      "dept": "Mechanical",
      "status": "Placed",
    },
    {
      "name": "Saira Banu",
      "id": "237084",
      "dept": "Civil",
      "status": "Applied",
    },
    {
      "name": "Varun Dhawan",
      "id": "237073",
      "dept": "Electrical",
      "status": "Placed",
    },
    {
      "name": "Kiara Advani",
      "id": "237091",
      "dept": "Electronics",
      "status": "Not Started",
    },
    {
      "name": "Siddharth Ray",
      "id": "237041",
      "dept": "Automobile",
      "status": "Applied",
    },
    {
      "name": "Tripti Dimri",
      "id": "237120",
      "dept": "Chemical",
      "status": "Placed",
    },
    {
      "name": "Kartik Aaryan",
      "id": "237030",
      "dept": "Instrumentation",
      "status": "Applied",
    },
    {
      "name": "Rashmika M",
      "id": "237064",
      "dept": "IT",
      "status": "Not Started",
    },
    {
      "name": "Ranbir Kapoor",
      "id": "237077",
      "dept": "Computer",
      "status": "Placed",
    },
    {
      "name": "Alia Bhatt",
      "id": "237098",
      "dept": "Mechanical",
      "status": "Applied",
    },
    {
      "name": "Rajkumar Rao",
      "id": "237102",
      "dept": "Civil",
      "status": "Placed",
    },
    {
      "name": "Ayushmann K",
      "id": "237115",
      "dept": "Electrical",
      "status": "Not Started",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Enhanced search logic across name, id, and department
    final filteredList = allStudents.where((student) {
      final query = searchQuery.toLowerCase();
      return student['name']!.toLowerCase().contains(query) ||
          student['id']!.toLowerCase().contains(query) ||
          student['dept']!.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: coolSky,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "All Registered Students",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: "Search by Name, ID or Dept...",
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: const Color(0xFFF1F4FF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- MASTER LIST ---
          Expanded(
            child: filteredList.isEmpty
                ? const Center(child: Text("No student found in records"))
                : ListView.builder(
                    itemCount: filteredList.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final student = filteredList[index];
                      return _buildMasterStudentCard(student);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterStudentCard(Map<String, String> student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFD0E0FF),
          child: Text(
            student['name']![0].toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF4A80FF),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          student['name']!,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enrollment No: ${student['id']}",
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              "Dept: ${student['dept']}",
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
          ],
        ),
        trailing: _buildStatusTag(student['status']!),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PrincipalStudentProfileScreen(studentData: student),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color color = status == "Placed"
        ? Colors.green
        : (status == "Applied" ? Colors.orange : Colors.grey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
