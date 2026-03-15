import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PrincipalStudentProfileScreen extends StatelessWidget {
  final Map<String, dynamic> studentData;

  const PrincipalStudentProfileScreen({super.key, required this.studentData});

  static const Color coolSky = Color(0xFF60B5FF);

  @override
  Widget build(BuildContext context) {
    final studentId = (studentData['uid'] ?? studentData['studentId'] ?? '')
        .toString()
        .trim();
    final enrollmentNo = (studentData['enrollmentNo'] ?? studentData['id'] ?? '')
        .toString()
        .trim();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: _buildStudentBody(studentId: studentId, enrollmentNo: enrollmentNo),
    );
  }

  Widget _buildStudentBody({
    required String studentId,
    required String enrollmentNo,
  }) {
    if (studentId.isNotEmpty) {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('user').doc(studentId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildFallbackContent();
          }

          final data = snapshot.data?.data();
          if (data == null) {
            return _buildFallbackContent();
          }

          return _buildContent(context, data, studentId: snapshot.data!.id);
        },
      );
    }

    if (enrollmentNo.isNotEmpty) {
      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('user')
            .where('role', isEqualTo: 'student')
            .where('enrollmentNo', isEqualTo: enrollmentNo)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildFallbackContent();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildFallbackContent();
          }

          final doc = snapshot.data!.docs.first;
          return _buildContent(context, doc.data(), studentId: doc.id);
        },
      );
    }

    return _buildFallbackContent();
  }

  Widget _buildContent(
    BuildContext context,
    Map<String, dynamic> data, {
    required String studentId,
  }) {
    final displayData = <String, dynamic>{...studentData, ...data};
    final imageUrl = (displayData['profileImageUrl'] ?? '').toString().trim();
    final fullName = _firstNonEmpty([
      displayData['fullName'],
      displayData['name'],
    ], fallback: 'Student');
    final enrollmentNo = _firstNonEmpty([
      displayData['enrollmentNo'],
      displayData['id'],
    ], fallback: 'N/A');
    final dept = _firstNonEmpty([
      displayData['dept'],
      displayData['department'],
    ], fallback: 'Not Assigned');
    final internshipStatus = _firstNonEmpty([
      displayData['internshipStatus'],
      displayData['status'],
    ], fallback: 'Pending');
    final company = _firstNonEmpty([
      displayData['company_name'],
      displayData['company'],
    ], fallback: 'Not Assigned');
    final collegeMentor = _firstNonEmpty([
      displayData['collegeMentor'],
      displayData['facultyMentor'],
      displayData['mentorName'],
    ], fallback: 'Not Assigned');
    final phone = _firstNonEmpty([
      displayData['phoneNumber'],
      displayData['phone'],
      displayData['mobile'],
    ], fallback: 'Not Available');
    final email = _firstNonEmpty([
      displayData['email'],
    ], fallback: 'Not Available');
    final internshipRole = _firstNonEmpty([
      displayData['internshipRole'],
      displayData['roleAtCompany'],
    ], fallback: 'Not Assigned');
    final internshipType = _firstNonEmpty([
      displayData['internshipType'],
    ], fallback: 'Not Assigned');
    final startDate = _stringifyDate(displayData['startDate']);
    final endDate = _stringifyDate(displayData['endDate']);
    final companyMentorId = _firstNonEmpty([
      displayData['companyMentorId'],
    ]);
    final companyMentorName = _firstNonEmpty([
      displayData['companyMentor'],
      displayData['companyMentorName'],
    ], fallback: 'Not Assigned');

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 80, bottom: 30),
          decoration: BoxDecoration(
            color: coolSky.withOpacity(0.12),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: coolSky,
                backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                child: imageUrl.isEmpty
                    ? Text(
                        fullName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 15),
              Text(
                fullName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Enrollment: $enrollmentNo | $dept",
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildInfoSection("Internship Status", [
                _infoTile(Icons.assignment_turned_in, "Current Status", internshipStatus),
                _infoTile(Icons.business, "Company", company),
                _infoTile(Icons.badge_outlined, "Internship Role", internshipRole),
                _infoTile(Icons.category_outlined, "Internship Type", internshipType),
                _infoTile(Icons.event_outlined, "Start Date", startDate),
                _infoTile(Icons.event_available_outlined, "End Date", endDate),
              ]),
              const SizedBox(height: 24),
              _buildInfoSection("Mentor Details", [
                _infoTile(Icons.school_outlined, "College Mentor", collegeMentor),
                _buildCompanyMentorTile(
                  companyMentorId: companyMentorId,
                  fallbackName: companyMentorName,
                ),
              ]),
              const SizedBox(height: 24),
              _buildInfoSection("Contact Details", [
                _infoTile(Icons.phone_android, "Student Phone", phone),
                _infoTile(Icons.email_outlined, "Official Email", email),
                _infoTile(Icons.apartment_outlined, "Department", dept),
              ]),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: phone == 'Not Available'
                      ? null
                      : () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Student phone: $phone")),
                          ),
                  icon: const Icon(Icons.call, size: 20),
                  label: const Text("Call Student"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showDownloadProgress(context),
                  icon: const Icon(Icons.picture_as_pdf, color: coolSky),
                  label: const Text(
                    "Download Report PDF",
                    style: TextStyle(color: coolSky),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: coolSky),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackContent() {
    final fallbackData = <String, dynamic>{...studentData};
    final name = _firstNonEmpty([
      fallbackData['fullName'],
      fallbackData['name'],
    ], fallback: 'Student');
    final enrollmentNo = _firstNonEmpty([
      fallbackData['enrollmentNo'],
      fallbackData['id'],
    ], fallback: 'N/A');
    final dept = _firstNonEmpty([
      fallbackData['dept'],
    ], fallback: 'Not Assigned');
    final imageUrl = (fallbackData['profileImageUrl'] ?? '').toString().trim();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 80, bottom: 30),
          decoration: BoxDecoration(
            color: coolSky.withOpacity(0.12),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: coolSky,
                backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                child: imageUrl.isEmpty
                    ? Text(
                        name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 15),
              Text(
                name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                "Enrollment: $enrollmentNo | $dept",
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        ),
        const Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Live student details are not available for this entry.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyMentorTile({
    required String companyMentorId,
    required String fallbackName,
  }) {
    if (companyMentorId.isEmpty) {
      return _infoTile(Icons.person_pin_circle_outlined, "Company Mentor", fallbackName);
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: 'mentor')
          .where('mentorId', isEqualTo: companyMentorId)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        String mentorName = fallbackName;

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final mentorData = snapshot.data!.docs.first.data();
          mentorName = _firstNonEmpty([
            mentorData['fullName'],
            mentorData['name'],
          ], fallback: fallbackName);
        }

        return _infoTile(Icons.person_pin_circle_outlined, "Company Mentor", mentorName);
      },
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: coolSky.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: coolSky),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.black38, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _firstNonEmpty(List<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      final text = (value ?? '').toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return fallback;
  }

  String _stringifyDate(dynamic value) {
    if (value == null) {
      return 'Not Available';
    }
    if (value is Timestamp) {
      final date = value.toDate();
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    }

    final text = value.toString().trim();
    return text.isEmpty ? 'Not Available' : text;
  }

  void _showDownloadProgress(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Generating Student Report PDF..."),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
