import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../bottom_bar/company_mentor_bottom_bar.dart';
import 'AttendanceDateSelectorScreen.dart';

class TodayAttendanceScreen extends StatefulWidget {
  const TodayAttendanceScreen({super.key});

  @override
  State<TodayAttendanceScreen> createState() =>
      _TodayAttendanceScreenState();
}

class _TodayAttendanceScreenState
    extends State<TodayAttendanceScreen> {

  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> interns = [];
  String mentorId = "";

  @override
  void initState() {
    super.initState();
    loadMentor();
    loadStudents();
  }

  /// GET LOGGED-IN MENTOR
  Future<void> loadMentor() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      mentorId = user.uid;
      print("Mentor ID: $mentorId");
    }
  }

  /// LOAD STUDENTS FROM FIREBASE
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
          "status": "present",
        });
      }

      setState(() {
        interns = temp;
      });
    } catch (e) {
      print("Error loading students: $e");
    }
  }

  /// CHANGE DATE
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

  /// UPDATE STATUS
  void updateStatus(int index, String status) {
    setState(() {
      interns[index]["status"] = status;
    });
  }

  int presentCount() => interns.where((e) => e["status"] == "present").length;
  int absentCount() => interns.where((e) => e["status"] == "absent").length;
  int leaveCount() => interns.where((e) => e["status"] == "leave").length;

  /// SAVE ATTENDANCE (UPDATED WITH WRITEBATCH & TOSTRING FIX)
  Future<void> saveAttendance() async {
    print("Save Attendance Clicked");

    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var intern in interns) {
        // FIX: Force conversion to String to prevent TypeError
        String enrollmentNo = intern["enrollmentNo"].toString();
        String status = intern["status"];

        if (enrollmentNo.isEmpty || enrollmentNo == "null") {
          print("Enrollment number missing for ${intern['name']}");
          continue;
        }

        String date =
            "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

        print("Saving $enrollmentNo → $status → $date");

        DocumentReference docRef = FirebaseFirestore.instance
            .collection("attendance")
            .doc(enrollmentNo)
            .collection("records")
            .doc(date);

        batch.set(docRef, {
          "status": status,
          "mentorId": mentorId,
          "timestamp": FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      print("Attendance batch saved successfully");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Attendance Saved Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error saving attendance: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error saving attendance: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Intern Attendance"),
        backgroundColor: const Color(0xFF5F9ED6),
      ),
      body: interns.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// DATE BAR
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xfff5f7fb),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: changeDate,
                        icon: const Icon(Icons.calendar_month),
                        label: const Text("Change Date"),
                      ),
                    ],
                  ),
                ),

                /// SUMMARY
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryCard("Present", presentCount(), Colors.green),
                      _summaryCard("Absent", absentCount(), Colors.red),
                      _summaryCard("Leave", leaveCount(), Colors.orange),
                    ],
                  ),
                ),

                const Divider(),

                /// STUDENT LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: interns.length,
                    itemBuilder: (context, index) {
                      final intern = interns[index];
                      String status = intern["status"];

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              intern["name"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _statusButton(
                                  index,
                                  "present",
                                  "Present",
                                  Colors.green,
                                  status == "present",
                                ),
                                const SizedBox(width: 8),
                                _statusButton(
                                  index,
                                  "absent",
                                  "Absent",
                                  Colors.red,
                                  status == "absent",
                                ),
                                const SizedBox(width: 8),
                                _statusButton(
                                  index,
                                  "leave",
                                  "Leave",
                                  Colors.orange,
                                  status == "leave",
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                /// SAVE BUTTON
                Container(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        print("SAVE BUTTON CLICKED");
                        saveAttendance();
                      },
                      child: const Text("SAVE ATTENDANCE"),
                    ),
                  ),
                ),
              ],
            ),
        

      bottomNavigationBar:
          const CompanyMentorBottomBar(currentIndex: 0),
    );
  }

  Widget _summaryCard(String title, int count, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            "$count",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title),
        ],
      ),
    );
  }

  Widget _statusButton(
    int index,
    String value,
    String text,
    Color color,
    bool active,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          updateStatus(index, value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? color : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: active ? Colors.white : Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}