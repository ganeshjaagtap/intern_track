import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:intl/intl.dart'; // ✅ Corrected Import
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
  List<Map<String, dynamic>> allInterns = [];
  List<Map<String, dynamic>> displayedInterns = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAttendanceData();
  }

  /// FETCH DATA FROM FIREBASE
  Future<void> fetchAttendanceData() async {
    setState(() => isLoading = true);
    try {
      // ✅ Corrected date formatting using intl
      String dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);

      var userSnapshot = await FirebaseFirestore.instance
          .collection("user")
          .where("role", isEqualTo: "student")
          .get();

      List<Map<String, dynamic>> tempList = [];

      for (var doc in userSnapshot.docs) {
        var userData = doc.data();
        String enrollmentNo = userData['enrollmentNo']?.toString() ?? "";
        String name = userData['fullName'] ?? "Unknown Student";
        String college = userData['college_name'] ?? "Government Polytechnic College Aurangabad";

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
            status = rawStatus[0].toUpperCase() + rawStatus.substring(1).toLowerCase();
          }
        }
        tempList.add({"name": name, "college": college, "status": status});
      }
      setState(() {
        allInterns = tempList;
        displayedInterns = tempList;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  void searchIntern(String query) {
    if (query.isEmpty) {
      setState(() => displayedInterns = allInterns);
      return;
    }
    setState(() {
      displayedInterns = allInterns.where((intern) {
        return intern["name"].toString().toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "present": return const Color(0xFF10B981); 
      case "absent": return const Color(0xFFEF4444); 
      case "leave": return const Color(0xFF3B82F6); 
      default: return const Color(0xFF94A3B8); 
    }
  }

  @override
  Widget build(BuildContext context) {
    int presentCount = displayedInterns.where((e) => e["status"] == "Present").length;
    int absentCount = displayedInterns.where((e) => e["status"] == "Absent").length;
    String attendancePercentage = displayedInterns.isEmpty
        ? "0%"
        : "${((presentCount / displayedInterns.length) * 100).round()}%";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF5F9ED6),
        title: Text(
          "ATTENDANCE",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, 
            letterSpacing: 1.2, 
            color: Colors.white, 
            fontSize: 18
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF5F9ED6)))
          : RefreshIndicator(
              onRefresh: fetchAttendanceData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateHeader(),
                    const SizedBox(height: 25),
                    _buildStatsGrid(presentCount, absentCount, attendancePercentage),
                    const SizedBox(height: 30),
                    _buildSearchField(),
                    const SizedBox(height: 25),
                    _buildSectionTitle("Intern Roster"),
                    const SizedBox(height: 12),
                    _buildInternList(),
                    const SizedBox(height: 100), 
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const CompanyMentorBottomBar(currentIndex: 2),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildDateHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date Overview", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
            Text(
              DateFormat('MMMM dd, yyyy').format(selectedDate),
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF2D3243)),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(12), 
            border: Border.all(color: Colors.grey.shade200)
          ),
          child: IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: Color(0xFF5F9ED6)),
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
                builder: (context, child) => Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: const ColorScheme.light(primary: Color(0xFF5F9ED6))
                  ), 
                  child: child!
                ),
              );
              if (picked != null) {
                setState(() => selectedDate = picked);
                fetchAttendanceData();
              }
            },
          ),
        )
      ],
    );
  }

  Widget _buildStatsGrid(int present, int absent, String percent) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statCard("Total", allInterns.length.toString(), Icons.groups_rounded, const Color(0xFF6366F1))),
            const SizedBox(width: 15),
            Expanded(child: _statCard("Present", present.toString(), Icons.check_circle_rounded, const Color(0xFF10B981))),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _statCard("Absent", absent.toString(), Icons.cancel_rounded, const Color(0xFFEF4444))),
            const SizedBox(width: 15),
            Expanded(child: _statCard("Success", percent, Icons.insights_rounded, const Color(0xFFF59E0B))),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: TextField(
        onChanged: searchIntern,
        decoration: InputDecoration(
          hintText: "Search by intern name...",
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF5F9ED6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2D3243)));
  }

  Widget _buildInternList() {
    if (displayedInterns.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40), 
          child: Text("No interns found.", style: TextStyle(color: Colors.grey.shade400))
        )
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: displayedInterns.length,
      itemBuilder: (context, index) {
        final intern = displayedInterns[index];
        final statusColor = _getStatusColor(intern["status"]);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: statusColor.withOpacity(0.1),
              child: Text(
                intern["name"][0].toUpperCase(), 
                style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)
              ),
            ),
            title: Text(intern["name"], style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
            subtitle: Text(
              intern["college"], 
              style: const TextStyle(fontSize: 11, color: Colors.grey), 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Text(
                intern["status"],
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }
}