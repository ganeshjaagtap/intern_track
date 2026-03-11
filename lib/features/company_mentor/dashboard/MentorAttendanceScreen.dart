import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../bottom_bar/company_mentor_bottom_bar.dart';

class CompanyMentorAttendanceScreen extends StatefulWidget {
  const CompanyMentorAttendanceScreen({super.key});

  @override
  State<CompanyMentorAttendanceScreen> createState() =>
      _CompanyMentorAttendanceScreenState();
}

class _CompanyMentorAttendanceScreenState
    extends State<CompanyMentorAttendanceScreen> {
  DateTime selectedDate = DateTime.now();

  // Stores all interns fetched from Firebase
  List<Map<String, dynamic>> allInterns = [];
  // Stores the interns currently visible (used for the search bar)
  List<Map<String, dynamic>> displayedInterns = [];
  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  /// FETCH DATA FROM FIREBASE
  Future<void> fetchAttendanceData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 1. Format date to match your Firebase YYYY-MM-DD structure
      String dateKey =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

      // 2. Fetch all users with role 'student'
      var userSnapshot = await FirebaseFirestore.instance
          .collection("user")
          .where("role", isEqualTo: "student")
          .get();

      List<Map<String, dynamic>> tempList = [];

      // 3. Loop through students and fetch their attendance for the selected date
      for (var doc in userSnapshot.docs) {
        var userData = doc.data();
        String enrollmentNo = userData['enrollmentNo']?.toString() ?? "";
        String name = userData['fullName'] ?? "Unknown Student";
        String college = userData['college'] ?? "Intern"; // Fallback if college field is missing

        String status = "Unmarked";

        if (enrollmentNo.isNotEmpty) {
          var attendanceDoc = await FirebaseFirestore.instance
              .collection("attendance")
              .doc(enrollmentNo)
              .collection("records")
              .doc(dateKey)
              .get();

          if (attendanceDoc.exists) {
            String rawStatus = attendanceDoc.data()?['status'] ?? "unmarked";
            // Capitalize first letter for UI consistency (e.g., "present" -> "Present")
            status = rawStatus[0].toUpperCase() + rawStatus.substring(1).toLowerCase();
          }
        }

        tempList.add({
          "name": name,
          "college": college,
          "status": status,
        });
      }

      setState(() {
        allInterns = tempList;
        displayedInterns = tempList; // Initially show all
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  /// SEARCH FUNCTIONALITY
  void searchIntern(String query) {
    if (query.isEmpty) {
      setState(() {
        displayedInterns = allInterns;
      });
      return;
    }

    setState(() {
      displayedInterns = allInterns.where((intern) {
        return intern["name"]
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    });
  }

  /// HELPER FOR STATUS COLORS
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "present":
        return Colors.green;
      case "absent":
        return Colors.red;
      case "leave":
        return Colors.blue;
      default:
        return Colors.grey; // For "Unmarked"
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate stats dynamically based on displayedInterns
    int presentCount =
        displayedInterns.where((e) => e["status"] == "Present").length;
    int absentCount =
        displayedInterns.where((e) => e["status"] == "Absent").length;
    
    // Prevent divide by zero error if no interns exist
    String attendancePercentage = displayedInterns.isEmpty
        ? "0%"
        : "${((presentCount / displayedInterns.length) * 100).round()}%";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5F9ED6),
        title: const Text("Attendance Overview"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none),
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
                  /// DATE SELECTOR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Attendance",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                          );

                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                            // Re-fetch data for the newly selected date
                            fetchAttendanceData();
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text("Change"),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// SUMMARY CARDS
                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          title: "Total Interns",
                          value: displayedInterns.length.toString(),
                          icon: Icons.people,
                          color: const Color(0xFFBFD1E3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          title: "Present",
                          value: presentCount.toString(),
                          icon: Icons.check_circle,
                          color: const Color(0xFFC2D6CC),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          title: "Absent",
                          value: absentCount.toString(),
                          icon: Icons.cancel,
                          color: const Color(0xFFE4CFC3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _summaryCard(
                          title: "Attendance %",
                          value: attendancePercentage,
                          icon: Icons.show_chart,
                          color: const Color(0xFFE7D8AE),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// SEARCH BAR
                  TextField(
                    onChanged: (value) => searchIntern(value),
                    decoration: InputDecoration(
                      hintText: "Search intern...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Intern Attendance",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  /// INTERN LIST
                  if (displayedInterns.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: Text("No interns found."),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedInterns.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final intern = displayedInterns[index];
                        final statusColor = _getStatusColor(intern["status"]);

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              intern["name"][0].toUpperCase(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(intern["name"]),
                          subtitle: Text(intern["college"]),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              intern["status"],
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 30),

                  /// ACTION BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text("Export Report"),
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14)),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text("Refresh"),
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14)),
                          onPressed: () {
                            fetchAttendanceData();
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
      bottomNavigationBar: const CompanyMentorBottomBar(currentIndex: 0),
    );
  }

  /// SUMMARY CARD
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