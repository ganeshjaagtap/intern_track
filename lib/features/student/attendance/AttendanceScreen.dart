import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'PastAttendanceScreen.dart';

class AttendanceScreen extends StatelessWidget {
  final String enrollmentNo;

  const AttendanceScreen({
    super.key,
    required this.enrollmentNo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
        title: const Text(
          "ATTENDANCE",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("attendance")
            .doc(enrollmentNo)
            .collection("records")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data!.docs;

          int present = 0;
          int absent = 0;
          int leave = 0;

          for (var doc in records) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data["status"];

            if (status == "present") present++;
            if (status == "absent") absent++;
            if (status == "leave") leave++;
          }

          // FIX: Exclude leaves from the total required days
          int validDays = present + absent;
          double percentage = validDays == 0 ? 0 : (present / validDays) * 100;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ATTENDANCE CIRCLE
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                value: percentage / 100,
                                strokeWidth: 10,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.green,
                                ),
                              ),
                            ),
                            Text(
                              "${percentage.toStringAsFixed(0)}%",
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Overall Attendance",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              percentage >= 75
                                  ? "You are in good standing"
                                  : "Attendance below required",
                              style: TextStyle(
                                color: percentage >= 75
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "Attendance Summary",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: CountCard(
                        title: "Present",
                        count: present.toString(),
                        color: Colors.green,
                        icon: Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CountCard(
                        title: "Absent",
                        count: absent.toString(),
                        color: Colors.red,
                        icon: Icons.cancel,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: CountCard(
                        title: "Leave",
                        count: leave.toString(),
                        color: Colors.blue,
                        icon: Icons.event_busy,
                      ),
                    ),
                    Expanded(child: Container()),
                  ],
                ),

                const SizedBox(height: 28),

                /// VIEW PAST ATTENDANCE
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PastAttendanceScreen(
                          enrollmentNo: enrollmentNo,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_month),
                  label: const Text(
                    "View Past Attendance",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF6BB6FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ============================
/// COUNT CARD
/// ============================
class CountCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;
  final IconData icon;

  const CountCard({
    super.key,
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: color),
          ),
        ],
      ),
    );
  }
}