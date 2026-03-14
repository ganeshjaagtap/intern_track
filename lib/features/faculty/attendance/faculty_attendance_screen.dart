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
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
  ];

  @override
  void initState() {
    super.initState();
    _loadFacultyAssignmentId();
  }

  // --- Helper to check if a date is today ---
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<void> _loadFacultyAssignmentId() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("Faculty not logged in");

      final doc = await _firestore.collection("user").doc(currentUser.uid).get();
      final data = doc.data() as Map<String, dynamic>? ?? {};

      if (!mounted) return;
      setState(() {
        _facultyAssignmentId = (data["facultyId"] ?? data["uid"] ?? currentUser.uid).toString();
        _isLoadingFaculty = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingFaculty = false);
    }
  }

  // --- Function to Update Attendance in Firestore ---
  Future<void> _updateAttendanceStatus(String enrollmentNo, String newStatus, DateTime date) async {
    if (!_isToday(date)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot modify past attendance."), backgroundColor: Colors.orange),
      );
      return;
    }

    final String recordDate = _formatDateKey(date);
    try {
      await _firestore
          .collection("attendance")
          .doc(enrollmentNo)
          .collection("records")
          .doc(recordDate)
          .set({
        "status": newStatus,
        "lastUpdated": FieldValue.serverTimestamp(),
        "markedBy": _facultyAssignmentId,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error updating: $e");
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAttendanceForDate(DateTime date) async {
    final facultyId = _facultyAssignmentId;
    if (facultyId == null || facultyId.isEmpty) return [];

    final studentSnapshot = await _firestore
        .collection("user")
        .where("role", isEqualTo: "student")
        .where("facultyId", isEqualTo: facultyId)
        .get();

    final students = studentSnapshot.docs;
    if (students.isEmpty) return [];

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
          status = (attendanceDoc.data()?["status"] ?? "not_marked").toString();
        }
      }

      results.add({
        "studentName": (data["fullName"] ?? "Student").toString(),
        "enrollmentNo": enrollmentNo,
        "status": status,
      });
    }
    results.sort((a, b) => (a["studentName"] as String).compareTo(b["studentName"] as String));
    return results;
  }

  String _formatDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _showAttendanceSheet(DateTime date) async {
    final bool canEdit = _isToday(date);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(builder: (context, setModalState) {
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
                    final rows = snapshot.data ?? [];
                    if (rows.isEmpty) return const Center(child: Text("No students found."));

                    return Column(
                      children: [
                        _buildSheetHeader(date, canEdit),
                        Expanded(
                          child: ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: rows.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final row = rows[index];
                              return _buildAttendanceListItem(row, date, canEdit, setModalState);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            });
          },
        );
      },
    );
  }

  Widget _buildSheetHeader(DateTime date, bool canEdit) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(canEdit ? "Update Attendance" : "View Attendance",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("${date.day} ${_monthNames[date.month - 1]} ${date.year}"),
            ],
          ),
          if (!canEdit)
            const Chip(
              label: Text("Read Only", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              backgroundColor: Color(0xFFFFF3E0),
            )
        ],
      ),
    );
  }

  Widget _buildAttendanceListItem(Map<String, dynamic> row, DateTime date, bool canEdit, StateSetter setModalState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row["studentName"], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("ID: ${row["enrollmentNo"]}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          if (canEdit)
            _buildEditableStatus(row, date, setModalState)
          else
            _statusChip(row["status"]),
        ],
      ),
    );
  }

  Widget _buildEditableStatus(Map<String, dynamic> row, DateTime date, StateSetter setModalState) {
    return PopupMenuButton<String>(
      initialValue: row["status"],
      onSelected: (String value) async {
        await _updateAttendanceStatus(row["enrollmentNo"], value, date);
        setModalState(() => row["status"] = value); // UI update inside modal
        setState(() {}); // UI update on calendar screen
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: "present", child: Text("Present", style: TextStyle(color: Colors.green))),
        const PopupMenuItem(value: "absent", child: Text("Absent", style: TextStyle(color: Colors.red))),
        const PopupMenuItem(value: "leave", child: Text("Leave", style: TextStyle(color: Colors.orange))),
      ],
      child: _statusChip(row["status"]),
    );
  }

  // --- Reusable Status Chip UI ---
  Widget _statusChip(String status) {
    Color color = Colors.grey;
    String label = "Not Marked";

    if (status == "present") { color = Colors.green; label = "Present"; }
    else if (status == "absent") { color = Colors.red; label = "Absent"; }
    else if (status == "leave") { color = Colors.orange; label = "Leave"; }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int daysInMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF6EA8DC),
        title: const Text("ATTENDANCE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7, crossAxisSpacing: 8, mainAxisSpacing: 8,
                    ),
                    itemCount: daysInMonth,
                    itemBuilder: (context, index) {
                      final int day = index + 1;
                      final DateTime currentDate = DateTime(_selectedDate.year, _selectedDate.month, day);
                      final bool isSelected = _isSameDate(currentDate, _selectedDate);
                      final bool isToday = _isToday(currentDate);

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedDate = currentDate);
                          _showAttendanceSheet(currentDate);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF6EA8DC) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: isToday ? Border.all(color: const Color(0xFF6EA8DC), width: 2) : null,
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: Center(
                            child: Text(day.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.black87,
                                )),
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

  // --- The rest of your dropdown and UI methods remain identical to maintain features ---
  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  String _initials(String name) => name.trim().isEmpty ? "?" : name.trim()[0].toUpperCase();

  Widget _monthDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: DropdownButton<int>(
        value: _selectedDate.month,
        isExpanded: true,
        underline: const SizedBox(),
        items: List.generate(12, (index) => DropdownMenuItem(value: index + 1, child: Text(_monthNames[index]))),
        onChanged: (value) {
          if (value != null) setState(() => _selectedDate = DateTime(_selectedDate.year, value, 1));
        },
      ),
    );
  }

  Widget _yearDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: DropdownButton<int>(
        value: _selectedDate.year,
        isExpanded: true,
        underline: const SizedBox(),
        items: List.generate(5, (index) {
          final year = DateTime.now().year - 2 + index;
          return DropdownMenuItem(value: year, child: Text(year.toString()));
        }),
        onChanged: (value) {
          if (value != null) setState(() => _selectedDate = DateTime(value, _selectedDate.month, 1));
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
        children: days.map((day) => SizedBox(width: 30, child: Text(day, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
      ),
    );
  }
}