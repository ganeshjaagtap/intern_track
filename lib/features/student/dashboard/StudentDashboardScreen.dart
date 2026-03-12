import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_application_2/features/interns/screens/InternshipbriefDetail.dart';
import 'package:flutter_application_2/features/student/models/company_details_screen.dart';
import 'package:flutter_application_2/features/student/notifications/student_event_notifications_screen.dart';
import 'package:flutter_application_2/features/student/profile/NotificationScreen.dart';
import 'package:flutter_application_2/features/student/reports/SubmitReportScreen.dart';
import 'package:flutter_application_2/features/student/task/student_task_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

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

  void _showMentorDetailsModal(BuildContext context, String? facultyId) {
    if (facultyId == null || facultyId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No mentor assigned.")));
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => _buildMentorDetailsSheet(scrollController, facultyId),
      ),
    );
  }

  Widget _buildMentorDetailsSheet(ScrollController scrollController, String facultyId) {
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

        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Text(_initials(mName), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(mDept, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Call Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      if (mPhone != "N/A") {
                        final Uri launchUri = Uri(scheme: 'tel', path: mPhone);
                        if (await canLaunchUrl(launchUri)) {
                          await launchUrl(launchUri);
                        }
                      }
                    },
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text("CALL MENTOR", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),

                // Details Section
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

                // Interns Count
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('user')
                      .where('role', isEqualTo: 'student')
                      .where('facultyId', isEqualTo: facultyId)
                      .snapshots(),
                  builder: (context, internSnap) {
                    int count = internSnap.hasData ? internSnap.data!.docs.length : 0;
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
                              const Text("Total Interns Under Mentor", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text("$count Students", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
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

                // Alert Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD6D6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.red, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Week report submission pending",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitReportScreen())),
                        child: const Text("Submit", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

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
                        value: "1",
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
                        value: "7",
                        label: "Tasks",
                        bg: const Color(0xFFE8E4FF),
                        iconColor: Colors.deepPurple,
                      ),
                    ),

                    // Days Completed Card
                    _buildStatCard(
                      icon: Icons.schedule,
                      value: "45/120",
                      label: "Days Completed",
                      bg: const Color(0xFFFFE8CC),
                      iconColor: Colors.orange,
                    ),

                    // Mentor Card
                    GestureDetector(
                      onTap: () => _showMentorDetailsModal(context, facultyId),
                      child: _buildStatCard(
                        icon: Icons.person_outline,
                        value: "1",
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
    required String value,
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
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  /// Companies Tab
  Widget _buildCompaniesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('company').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text("No companies available."));
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.business, color: Colors.blue.shade300),
                title: Text(data['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(data['industry'] ?? 'Industry', style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CompanyDetailScreen(companyData: {...data, 'id': docs[index].id})),
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.withOpacity(0.2))),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Internship Progress", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.65,
                minHeight: 8,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade300),
              ),
            ),
            const SizedBox(height: 14),
            const Text("65% Completed", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
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
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.blue.withOpacity(0.2),
                                    child: Text(_initials(member['fullName'] ?? "T"), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
