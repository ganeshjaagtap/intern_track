import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'faculty_details_screen.dart';
import 'company_approvals.dart';

class ReviewApprovalsScreen extends StatefulWidget {
  const ReviewApprovalsScreen({super.key});

  @override
  State<ReviewApprovalsScreen> createState() => _ReviewApprovalsScreenState();
}

class _ReviewApprovalsScreenState extends State<ReviewApprovalsScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  /// Company Requests (still static)
  final List<Map<String, String>> companyRequests = [
    {
      "company": "Infosys",
      "industry": "IT Services",
      "location": "Pune",
      "website": "www.infosys.com",
      "hrName": "Rajesh Kumar",
      "hrEmail": "hr@infosys.com",
      "hrPhone": "9876543212",
      "role": "Flutter Developer",
      "type": "Hybrid",
      "duration": "3 Months",
      "start": "01 June 2026",
      "end": "31 Aug 2026",
      "stipend": "₹10,000/month",
      "students": "5",
      "department": "IoT",
      "cgpa": "7.0",
      "skills": "Flutter, Dart"
    },
    {
      "company": "TCS",
      "industry": "IT Services",
      "location": "Mumbai",
      "website": "www.tcs.com",
      "hrName": "Anita Sharma",
      "hrEmail": "hr@tcs.com",
      "hrPhone": "9876543213",
      "role": "Web Developer",
      "type": "Online",
      "duration": "3 Months",
      "start": "10 June 2026",
      "end": "10 Sep 2026",
      "stipend": "₹8,000/month",
      "students": "4",
      "department": "Computer",
      "cgpa": "6.5",
      "skills": "HTML, CSS, JavaScript"
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void approve(String name) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("$name Approved")));
  }

  void reject(String name) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("$name Rejected")));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Review Approvals"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Faculty"),
            Tab(text: "Companies"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [

          /// ================= FACULTY TAB =================
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('mentor')
                .snapshots(),
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No faculty found"));
              }

              final mentors = snapshot.data!.docs;

              return ListView.builder(
                itemCount: mentors.length,
                itemBuilder: (context, index) {

                  final data =
                      mentors[index].data() as Map<String, dynamic>;

                  Map<String, String> faculty = {
                    "name": data["name"]?.toString() ?? "",
                    "empId": data["id"]?.toString() ?? "",
                    "department": data["dept"]?.toString() ?? "",
                    "designation": data["designation"]?.toString() ?? "",
                    "email": data["email"]?.toString() ?? "",
                    "phone": data["phone"]?.toString() ?? "",
                  };

                  return Card(
                    margin: const EdgeInsets.all(10),

                    child: ListTile(

                      leading: const Icon(Icons.person),

                      title: Text(faculty["name"]!),

                      subtitle: Text(
                          "${faculty["department"]} • ${faculty["email"]}"),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => approve(faculty["name"]!),
                          ),

                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => reject(faculty["name"]!),
                          ),
                        ],
                      ),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FacultyDetailsScreen(faculty: faculty),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),

          /// ================= COMPANY TAB =================
          ListView.builder(
            itemCount: companyRequests.length,
            itemBuilder: (context, index) {

              final company = companyRequests[index];

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(

                  leading: const Icon(Icons.business),

                  title: Text(company["company"]!),

                  subtitle:
                      Text("${company["role"]} • ${company["location"]}"),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => approve(company["company"]!),
                      ),

                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => reject(company["company"]!),
                      ),
                    ],
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CompanyApprovalsScreen(company: company),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}