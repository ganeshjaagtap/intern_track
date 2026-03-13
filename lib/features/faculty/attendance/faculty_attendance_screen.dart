import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FacultyAttendanceScreen extends StatefulWidget {
  const FacultyAttendanceScreen({super.key});

  @override
  State<FacultyAttendanceScreen> createState() => _FacultyAttendanceScreenState();
}

class _FacultyAttendanceScreenState extends State<FacultyAttendanceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime _selectedDate = DateTime.now();
  String? _facultyAssignmentId;
  bool _isLoadingFaculty = true;

  final List<String> _monthNames = const [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  @override
  void initState() {
    super.initState();
    _loadFacultyAssignmentId();
  }

  Future<void> _loadFacultyAssignmentId() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("Faculty not logged in");
      }

      final doc = await _firestore.collection("user").doc(currentUser.uid).get();
      final data = doc.data() as Map<String, dynamic>? ?? {};

      if (!mounted) return;
      setState(() {
        _facultyAssignmentId =
            (data["facultyId"] ?? data["uid"] ?? currentUser.uid).toString();
        _isLoadingFaculty = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingFaculty = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load faculty data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAttendanceForDate(DateTime date) async {
    final facultyId = _facultyAssignmentId;
    if (facultyId == null || facultyId.isEmpty) {
      return [];
    }

    final studentSnapshot = await _firestore
        .collection("user")
        .where("role", isEqualTo: "student")
        .where("facultyId", isEqualTo: facultyId)
        .get();

    final students = studentSnapshot.docs;
    if (students.isEmpty) {
      return [];
    }

    final String recordDate = _formatDateKey(date);
    final List<Map<String, dynamic>> results = [];

    for (final studentDoc in students) {
      final data = studentDoc.data();
      final String enrollmentNo = (data["enrollmentNo"] ?? "").toString();
      String status = "not_marked";

      if (enrollmentNo.isNotEmpty) {
        final attendanceDoc = await _firestore
            .collection("attendance")
            .doc(enrollmentNo)
            .collection("records")
            .doc(recordDate)
            .get();

        if (attendanceDoc.exists) {
          final attendanceData = attendanceDoc.data() as Map<String, dynamic>? ?? {};
          status = (attendanceData["status"] ?? "not_marked").toString();
        }
      }

      results.add({
        "studentName": (data["fullName"] ?? "Student").toString(),
        "enrollmentNo": enrollmentNo,
        "status": status,
      });
    }

    results.sort(
      (a, b) => (a["studentName"] as String).compareTo(b["studentName"] as String),
    );

    return results;
  }

  String _formatDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _showAttendanceSheet(DateTime date) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.45,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchAttendanceForDate(date),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _sheetMessage(
                      scrollController: scrollController,
                      title: "Unable to load attendance",
                      subtitle: "Please try again for this date.",
                    );
                  }

                  final rows = snapshot.data ?? [];
                  if (rows.isEmpty) {
                    return _sheetMessage(
                      scrollController: scrollController,
                      title: "No students assigned",
                      subtitle: "There are no students linked to your faculty ID.",
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12),
                          width: 48,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Daily Attendance",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${date.day} ${_monthNames[date.month - 1]} ${date.year}",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: rows.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final row = rows[index];
                            final status = (row["status"] ?? "not_marked").toString();

                            return Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F9FC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        const Color(0xFF6BB6FF).withOpacity(0.15),
                                    child: Text(
                                      _initials((row["studentName"] ?? "S").toString()),
                                      style: const TextStyle(
                                        color: Color(0xFF1976D2),
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
                                          (row["studentName"] ?? "Student").toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          (row["enrollmentNo"] ?? "").toString().isEmpty
                                              ? "Enrollment not available"
                                              : "Enrollment: ${row["enrollmentNo"]}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _statusChip(status),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetMessage({
    required ScrollController scrollController,
    required String title,
    required String subtitle,
  }) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        Icon(Icons.event_busy, size: 56, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return "?";
    return trimmed[0].toUpperCase();
  }

  Widget _statusChip(String status) {
    late final String label;
    late final Color textColor;
    late final Color bgColor;

    switch (status.toLowerCase()) {
      case "present":
        label = "Present";
        textColor = Colors.green.shade700;
        bgColor = Colors.green.shade50;
        break;
      case "absent":
        label = "Absent";
        textColor = Colors.red.shade700;
        bgColor = Colors.red.shade50;
        break;
      case "leave":
        label = "Leave";
        textColor = Colors.orange.shade800;
        bgColor = Colors.orange.shade50;
        break;
      default:
        label = "Not Marked";
        textColor = Colors.grey.shade700;
        bgColor = Colors.grey.shade200;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF6EA8DC),
        title: const Text(
          "ATTENDANCE",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoadingFaculty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: _monthDropdown()),
                      const SizedBox(width: 10),
                      Expanded(child: _yearDropdown()),
                    ],
                  ),
                ),
                _weekdayRow(),
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: daysInMonth,
                    itemBuilder: (context, index) {
                      final int day = index + 1;
                      final DateTime currentDate = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        day,
                      );

                      final bool isSelected = _isSameDate(currentDate, _selectedDate);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = currentDate;
                          });
                          _showAttendanceSheet(currentDate);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF6EA8DC) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              day.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _monthDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<int>(
        value: _selectedDate.month,
        isExpanded: true,
        underline: const SizedBox(),
        items: List.generate(12, (index) {
          return DropdownMenuItem(
            value: index + 1,
            child: Text(_monthNames[index]),
          );
        }),
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            _selectedDate = DateTime(_selectedDate.year, value, 1);
          });
        },
      ),
    );
  }

  Widget _yearDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<int>(
        value: _selectedDate.year,
        isExpanded: true,
        underline: const SizedBox(),
        items: List.generate(5, (index) {
          final year = DateTime.now().year - 2 + index;
          return DropdownMenuItem(
            value: year,
            child: Text(year.toString()),
          );
        }),
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            _selectedDate = DateTime(value, _selectedDate.month, 1);
          });
        },
      ),
    );
  }

  Widget _weekdayRow() {
    const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: days
            .map(
              (day) => SizedBox(
                width: 30,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
