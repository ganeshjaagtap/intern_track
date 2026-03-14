import 'package:flutter/material.dart';
import 'principal_intern_detail_screen.dart'; // Ensure this file exists in the same folder

class PrincipalActiveInternSummaryScreen extends StatefulWidget {
  const PrincipalActiveInternSummaryScreen({super.key});

  @override
  State<PrincipalActiveInternSummaryScreen> createState() =>
      _PrincipalActiveInternSummaryScreenState();
}

class _PrincipalActiveInternSummaryScreenState
    extends State<PrincipalActiveInternSummaryScreen> {
  final Color jasmine = const Color(0xFFFFE588);
  String selectedDept = "All";

  final List<String> companies = [
    "TCS",
    "Google",
    "Infosys",
    "Wipro",
    "Amazon",
    "Tesla",
    "Meta",
    "Microsoft",
    "Apple",
    "Netflix",
  ];

  // ✅ FIXED 16-WEEK DATASET: 30 Live Internship Records
  final List<Map<String, dynamic>> activeInterns = [
    {
      "name": "Ganesh Rathod",
      "company": "TCS",
      "dept": "IT",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Siddhika D",
      "company": "Infosys",
      "dept": "Computer",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Amit Sharma",
      "company": "Google",
      "dept": "IT",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Sneha Patil",
      "company": "Wipro",
      "dept": "Mech",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Rahul Mehta",
      "company": "Amazon",
      "dept": "Computer",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Priya Singh",
      "company": "Tesla",
      "dept": "Mech",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Vikram Joshi",
      "company": "Meta",
      "dept": "IT",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Ananya Iyer",
      "company": "Microsoft",
      "dept": "Computer",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Rohan Das",
      "company": "Apple",
      "dept": "Civil",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Neha Kulkarni",
      "company": "Netflix",
      "dept": "IT",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Arjun Malhotra",
      "company": "TCS",
      "dept": "Electrical",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Suresh Raina",
      "company": "Infosys",
      "dept": "Mech",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Kavita Reddy",
      "company": "Wipro",
      "dept": "Civil",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Manoj Tiwari",
      "company": "Google",
      "dept": "IT",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Deepika P",
      "company": "Amazon",
      "dept": "Computer",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Sahil Khan",
      "company": "Tesla",
      "dept": "Mech",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Pooja Hegde",
      "company": "Meta",
      "dept": "IT",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Abhishek B",
      "company": "Microsoft",
      "dept": "Civil",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Saira Banu",
      "company": "Apple",
      "dept": "Electrical",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Varun Dhawan",
      "company": "Netflix",
      "dept": "IT",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Kiara Advani",
      "company": "TCS",
      "dept": "Computer",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Siddharth Ray",
      "company": "Infosys",
      "dept": "Mech",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Tripti Dimri",
      "company": "Wipro",
      "dept": "Civil",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Kartik Aaryan",
      "company": "Google",
      "dept": "IT",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Rashmika M",
      "company": "Amazon",
      "dept": "Computer",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Ranbir Kapoor",
      "company": "Tesla",
      "dept": "Mech",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Alia Bhatt",
      "company": "Meta",
      "dept": "Electrical",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Rajkumar Rao",
      "company": "Microsoft",
      "dept": "IT",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Ayushmann K",
      "company": "Apple",
      "dept": "Computer",
      "week": 14,
      "total": 16,
    },
    {
      "name": "Kriti Sanon",
      "company": "Netflix",
      "dept": "Civil",
      "week": 14,
      "total": 16,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredInterns = activeInterns.where((intern) {
      if (selectedDept == "All") return true;
      return intern['dept'] == selectedDept;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: jasmine,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Active Internships",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text(
              "Hiring Partners (Tap to view)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          _buildCompanyTicker(),
          const SizedBox(height: 20),
          _buildDeptChips(),
          const SizedBox(height: 10),

          Expanded(
            child: filteredInterns.isEmpty
                ? const Center(
                    child: Text("No active interns in this department"),
                  )
                : ListView.builder(
                    itemCount: filteredInterns.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) =>
                        _buildProgressCard(filteredInterns[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyTicker() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: companies.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final companyName = companies[index];
          return GestureDetector(
            onTap: () => _showCompanyQuickView(context, companyName),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: jasmine.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: jasmine.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  companyName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCompanyQuickView(BuildContext context, String company) {
    final companyStudents = activeInterns
        .where((i) => i['company'] == company)
        .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$company Students",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${companyStudents.length} Active",
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            if (companyStudents.isEmpty)
              const Center(child: Text("No students assigned here yet."))
            else
              ...companyStudents
                  .take(4)
                  .map(
                    (s) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: jasmine.withOpacity(0.3),
                        child: const Icon(
                          Icons.person,
                          size: 18,
                          color: Colors.black,
                        ),
                      ),
                      title: Text(
                        s['name'],
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(s['dept']),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                      onTap: () {
                        Navigator.pop(context); // Close bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PrincipalInternDetailScreen(internData: s),
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDeptChips() {
    List<String> depts = [
      "All",
      "IT",
      "Computer",
      "Mech",
      "Civil",
      "Electrical",
      "Electronics",
      "AIML",
      "Automoblie",
      "DDGM",
    ];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: depts.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          bool isSelected = selectedDept == depts[index];
          return GestureDetector(
            onTap: () => setState(() => selectedDept = depts[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : jasmine.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  depts[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(Map<String, dynamic> intern) {
    // Logic: current week divided by total fixed weeks (16)
    double progressValue = intern['week'] / intern['total'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PrincipalInternDetailScreen(internData: intern),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: jasmine.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: jasmine,
                  child: Text(
                    intern['name'][0],
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        intern['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "at ${intern['company']} (${intern['dept']})",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Week ${intern['week']}/16",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.grey[200],
                color: Colors.orange,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
