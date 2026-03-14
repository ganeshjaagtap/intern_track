import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_application_2/features/interns/screens/InternshipbriefDetail.dart';
import 'package:flutter_application_2/features/student/models/company_details_screen.dart';
import 'package:flutter_application_2/features/student/notifications/student_event_notifications_screen.dart';
import 'package:flutter_application_2/features/student/profile/NotificationScreen.dart';
import 'package:flutter_application_2/features/student/task/company_task_screen.dart';
import 'package:flutter_application_2/features/student/task/student_task_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  DateTime? _parseInternshipDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value.trim());
    }
    return null;
  }

  Map<String, dynamic> _buildProgressData(Map<String, dynamic> userData) {
    final startDate = _parseInternshipDate(userData["startDate"]);
    final endDate = _parseInternshipDate(userData["endDate"]);

    if (startDate == null || endDate == null || endDate.isBefore(startDate)) {
      return {
        "label": "Dates not available",
        "progress": 0.0,
      };
    }

    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    final totalDays = normalizedEnd.difference(normalizedStart).inDays + 1;
    final rawCompletedDays = normalizedToday.difference(normalizedStart).inDays + 1;
    final completedDays = rawCompletedDays.clamp(0, totalDays);
    final progress = totalDays > 0 ? completedDays / totalDays : 0.0;

    return {
      "label": "$completedDays/$totalDays days completed",
      "progress": progress.toDouble(),
    };
  }

  String _formatEventDate(dynamic value) {
    if (value is Timestamp) {
      final dt = value.toDate();
      return "${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }
    return "";
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return "${parts[0][0]}${parts[1][0]}".toUpperCase();
  }

  String _getInternshipRole(Map<String, dynamic> userData) {
    // Try multiple field names in order
    const fallbackFields = ['internshipRole', 'roleTitle', 'internRole', 'designation'];
    for (String field in fallbackFields) {
      if (userData.containsKey(field) && userData[field] != null && userData[field].toString().isNotEmpty) {
        return userData[field].toString();
      }
    }
    // Fallback to company if no role field exists
    final company = userData["company_name"] ?? userData["company"];
    if (company != null && company.toString().isNotEmpty) {
      return "Intern at $company";
    }
    return "Intern";
  }

  void _showMentorDetailsModal(
    BuildContext context, {
    required String? facultyId,
    required String? companyMentorId,
    String? companyMentorName,
    String? companyName,
  }) {
    final hasFacultyMentor = facultyId != null && facultyId.isNotEmpty;
    final hasCompanyMentor =
        companyMentorId != null && companyMentorId.isNotEmpty;

    if (!hasFacultyMentor && !hasCompanyMentor) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No mentor assigned.")));
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => _buildMentorDetailsSheet(
          context,
          scrollController,
          facultyId: facultyId,
          companyMentorId: companyMentorId,
          companyMentorName: companyMentorName,
          companyName: companyName,
        ),
      ),
    );
  }

  Widget _buildMentorDetailsSheet(
    BuildContext context,
    ScrollController scrollController, {
    required String? facultyId,
    required String? companyMentorId,
    String? companyMentorName,
    String? companyName,
  }) {
    int selectedTab = 0;
    return StatefulBuilder(
      builder: (context, setModalState) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _mentorTabButton(
                          label: "Faculty mentor",
                          isSelected: selectedTab == 0,
                          onTap: () => setModalState(() => selectedTab = 0),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _mentorTabButton(
                          label: "Company mentor",
                          isSelected: selectedTab == 1,
                          onTap: () => setModalState(() => selectedTab = 1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (selectedTab == 0)
                  _buildFacultyMentorTab(facultyId)
                else
                  _buildCompanyMentorTab(
                    companyMentorId,
                    fallbackMentorName: companyMentorName,
                    fallbackCompanyName: companyName,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFacultyMentorTab(String? facultyId) {
    if (facultyId == null || facultyId.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text("Faculty mentor not assigned.")),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 'faculty')
          .where('facultyId', isEqualTo: facultyId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text("Mentor details not found.")),
          );
        }

        final mentorData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final String mName = mentorData['fullName'] ?? "Mentor Name";
        final String mPhone = mentorData['phoneNumber'] ?? "N/A";
        final String mEmail = mentorData['email'] ?? "N/A";
        final String mDept = mentorData['dept'] ?? mentorData['company_name'] ?? "IT Department";
        final String imageUrl = (mentorData['profileImageUrl'] ?? "").toString();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMentorHeader(
              name: mName,
              subtitle: mDept,
              imageUrl: imageUrl,
            ),
            const SizedBox(height: 24),
            _buildCallButton(
              context,
              mPhone,
              label: "CALL MENTOR",
            ),
            const SizedBox(height: 24),
            const Text("Details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            _mentorDetailRow(Icons.email, "Email", mEmail),
            const SizedBox(height: 16),
            _mentorDetailRow(Icons.phone, "Phone", mPhone),
            const SizedBox(height: 16),
            _mentorDetailRow(Icons.badge, "Mentor ID", facultyId),
            const SizedBox(height: 16),
            _mentorDetailRow(Icons.business, "Department", mDept),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .where('role', isEqualTo: 'student')
                  .where('facultyId', isEqualTo: facultyId)
                  .snapshots(),
              builder: (context, internSnap) {
                final count = internSnap.hasData ? internSnap.data!.docs.length : 0;
                return _mentorCountCard(
                  title: "Total Interns Under Mentor",
                  count: count,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildCompanyMentorTab(
    String? companyMentorId, {
    String? fallbackMentorName,
    String? fallbackCompanyName,
  }) {
    if (companyMentorId == null || companyMentorId.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text("Company mentor not assigned.")),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 'mentor')
          .where('mentorId', isEqualTo: companyMentorId)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        final mentorData = snapshot.hasData && snapshot.data!.docs.isNotEmpty
            ? snapshot.data!.docs.first.data() as Map<String, dynamic>
            : <String, dynamic>{};

        final String mName = (mentorData['fullName'] ?? fallbackMentorName ?? "Company Mentor").toString();
        final String mPhone = (mentorData['phoneNumber'] ?? mentorData['phone'] ?? "N/A").toString();
        final String mEmail = (mentorData['email'] ?? "N/A").toString();
        final String mCompany = (mentorData['company_name'] ?? fallbackCompanyName ?? "N/A").toString();
        final String mDesignation = (mentorData['designation'] ?? mentorData['dept'] ?? "").toString();
        final String mDepartment = (mentorData['dept'] ?? "").toString();
        final String imageUrl = (mentorData['profileImageUrl'] ?? "").toString();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMentorHeader(
              name: mName,
              subtitle: mDesignation.isNotEmpty ? mDesignation : mCompany,
              imageUrl: imageUrl,
            ),
            const SizedBox(height: 24),
            _buildCallButton(
              context,
              mPhone,
              label: "CALL MENTOR",
            ),
            const SizedBox(height: 24),
            const Text("Details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            _mentorDetailRow(Icons.business, "Company", mCompany),
            if (mDesignation.isNotEmpty) ...[
              const SizedBox(height: 16),
              _mentorDetailRow(Icons.work_outline, "Designation", mDesignation),
            ],
            if (mDepartment.isNotEmpty) ...[
              const SizedBox(height: 16),
              _mentorDetailRow(Icons.apartment, "Department", mDepartment),
            ],
            const SizedBox(height: 16),
            _mentorDetailRow(Icons.email, "Email", mEmail),
            const SizedBox(height: 16),
            _mentorDetailRow(Icons.phone, "Phone", mPhone),
            const SizedBox(height: 16),
            _mentorDetailRow(Icons.badge, "Mentor ID", companyMentorId),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .where('role', isEqualTo: 'student')
                  .where('companyMentorId', isEqualTo: companyMentorId)
                  .snapshots(),
              builder: (context, internSnap) {
                final count = internSnap.hasData ? internSnap.data!.docs.length : 0;
                return _mentorCountCard(
                  title: "Total Interns Under Mentor",
                  count: count,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _mentorTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6BB6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMentorHeader({
    required String name,
    required String subtitle,
    String imageUrl = '',
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: Colors.blue.withOpacity(0.1),
          backgroundImage: imageUrl.isNotEmpty
              ? NetworkImage(imageUrl)
              : null,
          child: imageUrl.isEmpty
              ? Text(_initials(name), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue))
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCallButton(
    BuildContext context,
    String phoneNumber, {
    required String label,
  }) {
    final normalizedPhone = phoneNumber.trim();
    final canCall = normalizedPhone.isNotEmpty && normalizedPhone != "N/A";

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
        ),
        onPressed: canCall ? () => _launchMentorCall(context, normalizedPhone) : null,
        icon: const Icon(Icons.call, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _launchMentorCall(BuildContext context, String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Could not launch phone dialer.")),
    );
  }

  Widget _mentorCountCard({
    required String title,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(Icons.groups, size: 24, color: Colors.blue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text("$count Students", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mentorDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
        title: const Text("INTERN TRACKER", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("user").doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String name = userData["fullName"] ?? "Student";
          final String internshipRole = _getInternshipRole(userData);
          final String? assignedGroupId = userData["assignedGroupId"];
          final String? facultyId = userData["facultyId"];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(internshipRole, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 20),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("notifications")
                      .where("recipientId", isEqualTo: uid)
                      .snapshots(),
                  builder: (context, eventSnapshot) {
                    if (!eventSnapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final docs = eventSnapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return (data["type"] ?? "").toString() == "event";
                    }).toList();

                    docs.sort((a, b) {
                      final aData = a.data() as Map<String, dynamic>;
                      final bData = b.data() as Map<String, dynamic>;
                      final aTs = aData["createdAt"];
                      final bTs = bData["createdAt"];

                      if (aTs is Timestamp && bTs is Timestamp) {
                        return bTs.compareTo(aTs);
                      }
                      return 0;
                    });

                    if (docs.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    final latest = docs.first.data() as Map<String, dynamic>;
                    final eventType =
                        (latest["eventType"] ?? "Event").toString();
                    final eventDate = _formatEventDate(latest["eventDateTime"]);
                    final eventSummary =
                        (latest["title"] ?? eventType).toString();

                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const StudentEventNotificationsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9ECFF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.event_available,
                                color: Colors.blue,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Upcoming Events",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      eventDate.isEmpty
                                          ? eventSummary
                                          : "$eventSummary • $eventDate",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "View",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Stat Cards Grid (2x2)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
                  children: [
                    // Active Card
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InternshipBriefDetailsScreen())),
                      child: _buildStatCard(
                        icon: Icons.bar_chart,
                        label: "Active",
                        bg: const Color(0xFFD9ECFF),
                        iconColor: Colors.blue,
                      ),
                    ),

                    // Tasks Card
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentTaskScreen())),
                      child: _buildStatCard(
                        icon: Icons.task_alt,
                        label: "Tasks",
                        bg: const Color(0xFFE8E4FF),
                        iconColor: Colors.deepPurple,
                      ),
                    ),

                    // Company Task Card
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CompanyTaskScreen())),
                      child: _buildStatCard(
                        icon: Icons.assignment_outlined,
                        label: "Company Task",
                        bg: const Color(0xFFFFE8CC),
                        iconColor: Colors.orange,
                      ),
                    ),

                    // Mentor Card
                    GestureDetector(
                      onTap: () => _showMentorDetailsModal(
                        context,
                        facultyId: facultyId,
                        companyMentorId:
                            (userData["companyMentorId"] ?? "").toString(),
                        companyMentorName:
                            (userData["companyMentor"] ?? "").toString(),
                        companyName: (userData["company"] ?? "").toString(),
                      ),
                      child: _buildStatCard(
                        icon: Icons.person_outline,
                        label: "My Mentor",
                        bg: const Color(0xFFD9F0E8),
                        iconColor: Colors.teal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Tabs Section
                DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const TabBar(
                        isScrollable: false,
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue,
                        tabs: [
                          Tab(text: "Companies"),
                          Tab(text: "My Progress"),
                          Tab(text: "My Group"),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 360,
                        child: TabBarView(
                          children: [
                            _buildCompaniesTab(),
                            _buildProgressTab(userData),
                            _buildDynamicGroupTab(assignedGroupId),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required Color bg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  /// Updated Companies Tab with Experience, Intern Count, and Tracks
  Widget _buildCompaniesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('company').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No companies available."));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          padding: const EdgeInsets.only(top: 8),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final String experience = data['experience'] ?? "N/A";
            final dynamic internCount = data['internCount'] ?? 0;
            final List courses = data['courses'] ?? [];
            final String logoUrl =
                (data['logoUrl'] ?? data['companyLogoUrl'] ?? '').toString();

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CompanyDetailScreen(
                        companyData: {...data, 'id': docs[index].id},
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              backgroundImage:
                                  logoUrl.isNotEmpty ? NetworkImage(logoUrl) : null,
                              child: logoUrl.isEmpty
                                  ? const Icon(Icons.business_rounded, color: Colors.blue, size: 24)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['name'] ?? 'Unknown',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    data['industry'] ?? 'Technology',
                                    style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.history, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text("$experience Exp", style: const TextStyle(fontSize: 11, color: Colors.black54)),
                                const SizedBox(width: 12),
                                const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text("$internCount Interns", style: const TextStyle(fontSize: 11, color: Colors.black54)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "${courses.length} Tracks",
                                style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Progress Tab
  Widget _buildProgressTab(Map<String, dynamic> userData) {
    final progressData = _buildProgressData(userData);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Internship Completion Rate", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressData["progress"] as double,
                minHeight: 8,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade300),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              progressData["label"] as String,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Group Members Tab
  Widget _buildDynamicGroupTab(String? groupId) {
    if (groupId == null || groupId.isEmpty) {
      return const Center(child: Text("No group assigned."));
    }
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('groups').doc(groupId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: CircularProgressIndicator());
        final groupData = snapshot.data!.data() as Map<String, dynamic>;
        final String groupName = groupData['groupName'] ?? "Unnamed Project";
        final List<String> studentIds = List<String>.from(groupData['studentIds'] ?? []);

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
              child: Text(groupName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: studentIds.isEmpty
                  ? const Center(child: Text("No group members."))
                  : ListView.builder(
                      itemCount: studentIds.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('user').doc(studentIds[index]).get(),
                          builder: (context, userSnap) {
                            if (!userSnap.hasData) return const SizedBox();
                            final member = userSnap.data!.data() as Map<String, dynamic>;
                            final imageUrl = (member['profileImageUrl'] ?? "").toString();
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.blue.withOpacity(0.2),
                                    backgroundImage: imageUrl.isNotEmpty
                                        ? NetworkImage(imageUrl)
                                        : null,
                                    child: imageUrl.isEmpty
                                        ? Text(_initials(member['fullName'] ?? "T"), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(member['fullName'] ?? "Teammate", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                        Text(member['enrollmentNo'] ?? "", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
