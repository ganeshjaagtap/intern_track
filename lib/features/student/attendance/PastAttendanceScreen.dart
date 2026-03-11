import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PastAttendanceScreen extends StatefulWidget {
  final String enrollmentNo;

  const PastAttendanceScreen({
    super.key,
    required this.enrollmentNo,
  });

  @override
  State<PastAttendanceScreen> createState() => _PastAttendanceScreenState();
}

class _PastAttendanceScreenState extends State<PastAttendanceScreen> {
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final List<String> months = const [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  final List<int> years = [2024, 2025, 2026, 2027];

  int _daysInMonth(int y, int m) => DateTime(y, m + 1, 0).day;
  int _startOffset(int y, int m) => DateTime(y, m, 1).weekday % 7;

  Color _statusColor(String status) {
    switch (status) {
      case "present":
        return Colors.green;
      case "absent":
        return Colors.red;
      case "leave":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int days = _daysInMonth(selectedYear, selectedMonth);
    final int offset = _startOffset(selectedYear, selectedMonth);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        title: const Text("PAST ATTENDANCE"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("attendance")
            .doc(widget.enrollmentNo)
            .collection("records")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          Map<String, String> attendanceData = {};
          int present = 0;
          int absent = 0;
          int leave = 0;

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data["status"];

            attendanceData[doc.id] = status;

            if (status == "present") present++;
            if (status == "absent") absent++;
            if (status == "leave") leave++;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// MONTH + YEAR
                Row(
                  children: [
                    Expanded(
                      child: _dropdown(
                        DropdownButton<int>(
                          value: selectedMonth,
                          isExpanded: true,
                          items: List.generate(
                            12,
                            (i) => DropdownMenuItem(
                              value: i + 1,
                              child: Text(months[i]),
                            ),
                          ),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                selectedMonth = v;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _dropdown(
                        DropdownButton<int>(
                          value: selectedYear,
                          isExpanded: true,
                          items: years
                              .map((y) => DropdownMenuItem(
                                    value: y,
                                    child: Text(y.toString()),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                selectedYear = v;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// SUMMARY
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Summary(present.toString(), "Present", Colors.green),
                      _Summary(absent.toString(), "Absent", Colors.red),
                      _Summary(leave.toString(), "Leave", Colors.blue),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// WEEKDAYS
                Row(
                  children: const ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                      .map(
                        (d) => Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 8),

                /// CALENDAR
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: offset + days,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                    if (index < offset) {
                      return const SizedBox();
                    }

                    final int day = index - offset + 1;

                    // FIX: Match the exact YYYY-MM-DD format with leading zeros
                    String dateKey =
                        "$selectedYear-${selectedMonth.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";

                    String status = attendanceData[dateKey] ?? "none";
                    Color color = _statusColor(status);

                    return Container(
                      decoration: BoxDecoration(
                        color: status == "none"
                            ? Colors.grey.shade200
                            : color.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$day",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: status == "none" ? Colors.grey : color,
                            ),
                          ),
                          if (status != "none") ...[
                            const SizedBox(height: 4),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dropdown(Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: child,
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final String count;
  final String label;
  final Color color;

  const _Summary(this.count, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: color),
        ),
      ],
    );
  }
}