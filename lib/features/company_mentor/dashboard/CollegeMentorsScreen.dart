import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bottom_bar/company_mentor_bottom_bar.dart';

class CollegeMentorsScreen extends StatefulWidget {
  const CollegeMentorsScreen({super.key});

  @override
  State<CollegeMentorsScreen> createState() => _CollegeMentorsScreenState();
}

class _CollegeMentorsScreenState extends State<CollegeMentorsScreen> {
  List<Map<String, dynamic>> allMentors = [];
  List<Map<String, dynamic>> displayedMentors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFacultyMentors();
  }

  /// FETCH FACULTY & DYNAMICALLY COUNT INTERNS
  Future<void> fetchFacultyMentors() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 1. Fetch all users where the role is 'faculty'
      var facultySnapshot = await FirebaseFirestore.instance
          .collection("user")
          .where("role", isEqualTo: "faculty")
          .get();

      List<Map<String, dynamic>> tempList = [];

      // 2. Loop through each faculty member
      for (var doc in facultySnapshot.docs) {
        var data = doc.data();
        String facultyName = data["fullName"] ?? data["name"] ?? "Unknown Faculty";

        // 3. DYNAMIC COUNT: Ask Firebase how many students have this mentor's name
        // Make sure "collegeMentor" matches your exact field name in the student document!
        AggregateQuerySnapshot countSnapshot = await FirebaseFirestore.instance
            .collection("user")
            .where("role", isEqualTo: "student")
            .where("collegeMentor", isEqualTo: facultyName) 
            .count()
            .get();

        int dynamicInternCount = countSnapshot.count ?? 0;

        tempList.add({
          "name": facultyName,
          "college": data["college"] ?? "Unknown College",
          "department": data["department"] ?? "General",
          "email": data["email"] ?? "",
          "phone": data["phone"] ?? "",
          "profileImageUrl": data["profileImageUrl"] ?? "",
          "interns": dynamicInternCount, // Assigning the real-time count here!
        });
      }

      setState(() {
        allMentors = tempList;
        displayedMentors = tempList;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching faculty data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// SEARCH FUNCTIONALITY
  void searchMentor(String query) {
    if (query.isEmpty) {
      setState(() {
        displayedMentors = allMentors;
      });
      return;
    }

    setState(() {
      displayedMentors = allMentors.where((mentor) {
        final nameLower = mentor["name"].toString().toLowerCase();
        final collegeLower = mentor["college"].toString().toLowerCase();
        final searchLower = query.toLowerCase();

        return nameLower.contains(searchLower) ||
               collegeLower.contains(searchLower);
      }).toList();
    });
  }

  /// LAUNCH NATIVE PHONE APP
  Future<void> _makePhoneCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      _showError("No phone number available for this mentor.");
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showError("Could not launch phone dialer.");
    }
  }

  /// LAUNCH NATIVE EMAIL APP
  Future<void> _sendEmail(String email) async {
    if (email.isEmpty) {
      _showError("No email available for this mentor.");
      return;
    }
    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showError("Could not launch email app.");
    }
  }

  /// HELPER TO SHOW ERRORS
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalMentors = displayedMentors.length;
    int totalInterns = displayedMentors.fold(0, (sum, item) => sum + (item["interns"] as int));
    int uniqueColleges = displayedMentors.map((e) => e["college"]).toSet().length;
    int uniqueDepartments = displayedMentors.map((e) => e["department"]).toSet().length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5F9ED6),
        title: const Text("College Mentors"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.school),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "College Mentor Directory",
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          title: "Total Mentors",
                          value: totalMentors.toString(),
                          icon: Icons.people,
                          color: const Color(0xFFBFD1E3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          title: "Colleges",
                          value: uniqueColleges.toString(),
                          icon: Icons.school,
                          color: const Color(0xFFE7D8AE),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          title: "Active Interns",
                          value: totalInterns.toString(),
                          icon: Icons.groups,
                          color: const Color(0xFFC2D6CC),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          title: "Departments",
                          value: uniqueDepartments.toString(),
                          icon: Icons.apartment,
                          color: const Color(0xFFE4CFC3),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  TextField(
                    onChanged: (value) => searchMentor(value),
                    decoration: InputDecoration(
                      hintText: "Search mentor or college...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Mentor List",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  if (displayedMentors.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("No mentors found."),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedMentors.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final mentor = displayedMentors[index];
                        String initial = mentor["name"].isNotEmpty 
                            ? mentor["name"][0].toUpperCase() 
                            : "?";
                        final String imageUrl =
                            (mentor["profileImageUrl"] ?? "").toString();

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue.shade100,
                                    backgroundImage: imageUrl.isNotEmpty
                                        ? NetworkImage(imageUrl)
                                        : null,
                                    child: imageUrl.isEmpty
                                        ? Text(
                                            initial,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          mentor["name"],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          mentor["college"],
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "${mentor["interns"]} interns",
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.email),
                                      label: const Text("Email"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      onPressed: () => _sendEmail(mentor["email"]),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.phone),
                                      label: const Text("Call"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                      onPressed: () => _makePhoneCall(mentor["phone"]),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    mentor["email"].isEmpty ? "No Email" : mentor["email"],
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  Text(
                                    mentor["phone"].isEmpty ? "No Phone" : mentor["phone"],
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text("Export Contacts"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text("Refresh"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            fetchFacultyMentors();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
      bottomNavigationBar: const CompanyMentorBottomBar(currentIndex: 0),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }
}
