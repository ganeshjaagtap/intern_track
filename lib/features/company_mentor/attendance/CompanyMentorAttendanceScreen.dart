import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Add intl to pubspec.yaml

import '../bottom_bar/company_mentor_bottom_bar.dart';
import 'AttendanceDateSelectorScreen.dart';

class TodayAttendanceScreen extends StatefulWidget {
  const TodayAttendanceScreen({super.key});

  @override
  State<TodayAttendanceScreen> createState() => _TodayAttendanceScreenState();
}

class _TodayAttendanceScreenState extends State<TodayAttendanceScreen> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> interns = [];
  String mentorId = "";
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadMentor();
    loadStudents();
  }

  // Helper to check if the selected date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<void> loadMentor() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      mentorId = user.uid;
    }
  }

  Future<void> loadStudents() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("user")
          .where("role", isEqualTo: "student")
          .get();

      List<Map<String, dynamic>> temp = [];

      for (var doc in snapshot.docs) {
        var data = doc.data();
        temp.add({
          "name": data["fullName"] ?? "Student",
          "enrollmentNo": data["enrollmentNo"] ?? "",
          "status": "", 
        });
      }

      setState(() {
        interns = temp;
      });
    } catch (e) {
      debugPrint("Error loading students: $e");
    }
  }

  Future<void> changeDate() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceDateSelectorScreen(currentDate: selectedDate),
      ),
    );

    if (selected != null && selected is DateTime) {
      setState(() {
        selectedDate = selected;
      });
    }
  }

  void updateStatus(int index, String status) {
    // Prevent updating status if it's not today
    if (!_isToday(selectedDate)) return;

    setState(() {
      interns[index]["status"] = status;
    });
  }

  int presentCount() => interns.where((e) => e["status"] == "present").length;
  int absentCount() => interns.where((e) => e["status"] == "absent").length;
  int leaveCount() => interns.where((e) => e["status"] == "leave").length;

  Future<void> saveAttendance() async {
    // ✅ CHANGE: Added check to prevent saving if date is not today
    if (!_isToday(selectedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Past attendance records cannot be modified."), backgroundColor: Colors.red),
      );
      return;
    }

    bool allMarked = interns.every((e) => e["status"].isNotEmpty);
    if (!allMarked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please mark attendance for all interns before saving."), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      String dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);

      for (var intern in interns) {
        String enrollmentNo = intern["enrollmentNo"].toString();
        String status = intern["status"];

        if (enrollmentNo.isEmpty || enrollmentNo == "null") continue;

        DocumentReference docRef = FirebaseFirestore.instance
            .collection("attendance")
            .doc(enrollmentNo)
            .collection("records")
            .doc(dateKey);

        batch.set(docRef, {
          "status": status,
          "mentorId": mentorId,
          "timestamp": FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Attendance Saved Successfully!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Daily Attendance", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF5F9ED6),
        elevation: 0,
      ),
      body: interns.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildDateHeader(),
                _buildSummaryRow(),
                const Divider(height: 1),
                // ✅ CHANGE: Show warning if looking at past date
                if (!_isToday(selectedDate))
                  Container(
                    width: double.infinity,
                    color: Colors.amber.shade100,
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      "Viewing past record (Read-Only Mode)",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
                    ),
                  ),
                Expanded(child: _buildInternList()),
                // ✅ CHANGE: Hide save button if it's not today
                if (_isToday(selectedDate)) _buildSaveButton(),
              ],
            ),
      bottomNavigationBar: const CompanyMentorBottomBar(currentIndex: 0),
    );
  }

  Widget _buildDateHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            DateFormat('dd MMMM yyyy').format(selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton.icon(
            onPressed: changeDate,
            icon: const Icon(Icons.edit_calendar, color: Color(0xFF5F9ED6)),
            label: const Text("Change Date", style: TextStyle(color: Color(0xFF5F9ED6))),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryCard("Present", presentCount(), Colors.green),
          _summaryCard("Absent", absentCount(), Colors.red),
          _summaryCard("Leave", leaveCount(), Colors.orange),
        ],
      ),
    );
  }

  Widget _buildInternList() {
    return ListView.builder(
      itemCount: interns.length,
      padding: const EdgeInsets.only(bottom: 20),
      itemBuilder: (context, index) {
        final intern = interns[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(intern["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _statusButton(index, "present", "Present", Colors.green, intern["status"] == "present"),
                  const SizedBox(width: 8),
                  _statusButton(index, "absent", "Absent", Colors.red, intern["status"] == "absent"),
                  const SizedBox(width: 8),
                  _statusButton(index, "leave", "Leave", Colors.orange, intern["status"] == "leave"),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5F9ED6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: isSaving ? null : saveAttendance,
          child: isSaving 
              ? const CircularProgressIndicator(color: Colors.white) 
              : const Text("SAVE ATTENDANCE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, int count, Color color) {
    return Column(
      children: [
        Text("$count", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _statusButton(int index, String value, String text, Color color, bool active) {
    // ✅ CHANGE: Disable tap if it's not today
    bool isToday = _isToday(selectedDate);
    
    return Expanded(
      child: GestureDetector(
        onTap: isToday ? () => updateStatus(index, value) : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? color : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? Colors.white : (isToday ? Colors.black87 : Colors.grey), 
                fontWeight: active ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ),
        ),
      ),
    );
  }
}