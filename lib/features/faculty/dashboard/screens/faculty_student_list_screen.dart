import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'faculty_student_reports_screen.dart';

class FacultyStudentListScreen extends StatefulWidget {
  const FacultyStudentListScreen({super.key});

  @override
  State<FacultyStudentListScreen> createState() =>
      _FacultyStudentListScreenState();
}

class _FacultyStudentListScreenState extends State<FacultyStudentListScreen>
    with SingleTickerProviderStateMixin {
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";
  final TextEditingController _searchController = TextEditingController();

  TabController? _tabController;
  String? facultyId;
  bool _isLoading = true;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchFacultyId();
  }

  Future<void> _fetchFacultyId() async {
    final doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(currentUid)
        .get();

    if (!mounted) return;

    setState(() {
      facultyId = (doc.data()?['facultyId'] ?? "").toString().trim();
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Report Approvals"),
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Pending Approval"),
            Tab(text: "Reviewed"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : facultyId == null || facultyId!.isEmpty
              ? const Center(
                  child: Text("Faculty profile is missing a facultyId."),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search by student or report title...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildReportList(
                            statuses: const ["pending"],
                            emptyText: "No pending reports",
                          ),
                          _buildReportList(
                            statuses: const ["approved", "rejected"],
                            emptyText: "No reviewed reports",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildReportList({
    required List<String> statuses,
    required String emptyText,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("reports")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Unable to load reports",
              style: TextStyle(color: Colors.grey[600]),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyState(emptyText, Icons.assignment_outlined);
        }

        final reports = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final reportFacultyId = (data["facultyId"] ?? "").toString().trim();
          final status = (data["status"] ?? "pending").toString().toLowerCase();
          final studentName =
              (data["studentName"] ?? "").toString().toLowerCase();
          final title = (data["title"] ?? "").toString().toLowerCase();
          final week = (data["week"] ?? "").toString().toLowerCase();
          final matchesFaculty = reportFacultyId == facultyId || reportFacultyId == currentUid;
          final matchesStatus = statuses.contains(status);
          final matchesSearch = studentName.contains(_searchQuery) ||
              title.contains(_searchQuery) ||
              week.contains(_searchQuery);

          return matchesFaculty && matchesStatus && matchesSearch;
        }).toList();

        reports.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aTime = _extractTimestamp(aData["submittedAt"] ?? aData["createdAt"]);
          final bTime = _extractTimestamp(bData["submittedAt"] ?? bData["createdAt"]);
          return bTime.compareTo(aTime);
        });

        if (reports.isEmpty) {
          return _emptyState("No matching reports", Icons.search_off);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final doc = reports[index];
            final data = doc.data() as Map<String, dynamic>;
            final status = (data["status"] ?? "pending").toString();
            final submittedAt = _formatDate(data["submittedAt"] ?? data["createdAt"]);
            final studentName = (data["studentName"] ?? "Student").toString();
            final studentId = (data["studentId"] ?? "").toString();
            final avatarText =
                studentName.trim().isNotEmpty ? studentName[0].toUpperCase() : "S";

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FacultyStudentReportsScreen(
                      reportId: doc.id,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StreamBuilder<DocumentSnapshot>(
                            stream: studentId.isEmpty
                                ? null
                                : FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(studentId)
                                    .snapshots(),
                            builder: (context, studentSnapshot) {
                              final studentData = studentSnapshot.data?.data()
                                  as Map<String, dynamic>? ?? {};
                              final imageUrl =
                                  (studentData["profileImageUrl"] ?? "").toString();

                              return CircleAvatar(
                                backgroundColor:
                                    const Color(0xFF6BB6FF).withOpacity(0.1),
                                backgroundImage: imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : null,
                                child: imageUrl.isEmpty
                                    ? Text(
                                        avatarText,
                                        style: const TextStyle(
                                          color: Color(0xFF6BB6FF),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  studentName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data["title"] ?? "Untitled Report",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                if ((data["week"] ?? "").toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      data["week"],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6BB6FF),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _statusBadge(status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data["period"] ?? "",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Submitted: $submittedAt",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _emptyState(String text, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color textColor;
    switch (status.toLowerCase()) {
      case "approved":
        textColor = Colors.green;
        break;
      case "rejected":
        textColor = Colors.red;
        break;
      default:
        textColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: textColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      final dt = value.toDate();
      return "${dt.day}/${dt.month}/${dt.year}";
    }
    return "Unknown";
  }

  int _extractTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.millisecondsSinceEpoch;
    }
    return 0;
  }
}
