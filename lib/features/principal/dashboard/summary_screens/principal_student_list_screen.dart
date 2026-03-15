import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'principal_student_profile_screen.dart';

class PrincipalStudentListScreen extends StatefulWidget {
  final String department;
  final String year;

  const PrincipalStudentListScreen({
    super.key,
    required this.department,
    required this.year,
  });

  @override
  State<PrincipalStudentListScreen> createState() =>
      _PrincipalStudentListScreenState();
}

class _PrincipalStudentListScreenState
    extends State<PrincipalStudentListScreen> {
  final Color coolSky = const Color(0xFF60B5FF);
  String searchQuery = '';

  static const Map<String, String> _departmentAliases = {
    'it': 'IT Department',
    'information technology': 'IT Department',
    'information tech': 'IT Department',
    'information tech.': 'IT Department',
    'cse': 'Computer Science',
    'computer science': 'Computer Science',
    'computer engineering': 'Computer Science',
    'computer': 'Computer Science',
    'cs': 'Computer Science',
    'me': 'Mechanical Engineering',
    'mechanical': 'Mechanical Engineering',
    'mechanical engineering': 'Mechanical Engineering',
    'civil': 'Civil Engineering',
    'ce': 'Civil Engineering',
    'civil engineering': 'Civil Engineering',
    'ee': 'Electrical Engineering',
    'electrical': 'Electrical Engineering',
    'electrical engineering': 'Electrical Engineering',
    'eee': 'Electrical Engineering',
    'electronics': 'Electronics Engineering',
    'electronics engineering': 'Electronics Engineering',
    'electronics & tc': 'Electronics Engineering',
    'electronics and tc': 'Electronics Engineering',
    'entc': 'Electronics Engineering',
    'e&tc': 'Electronics Engineering',
    'extc': 'Electronics Engineering',
    'automobile': 'Automobile Engineering',
    'automobile engineering': 'Automobile Engineering',
    'chemical': 'Chemical Engineering',
    'chemical engineering': 'Chemical Engineering',
    'instrumentation': 'Instrumentation Engineering',
    'instrumentation engineering': 'Instrumentation Engineering',
    'aiml': 'AI & ML',
    'ai/ml': 'AI & ML',
    'artificial intelligence': 'AI & ML',
    'artificial intelligence and machine learning': 'AI & ML',
    'ddgm': 'DDGM',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.department} Students',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value.trim()),
              decoration: InputDecoration(
                hintText: 'Search by name or enrollment...',
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: const Color(0xFFF6F8FC),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: coolSky.withOpacity(0.5)),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .where('role', isEqualTo: 'student')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Unable to load students right now.',
                        style: TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final students = _filterStudents(snapshot.data?.docs ?? const []);
                if (students.isEmpty) {
                  return const Center(
                    child: Text(
                      'No students found for this department.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    return _buildStudentCard(students[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterStudents(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final selectedDepartment = widget.department.trim();
    final selectedYear = widget.year.trim().toLowerCase();
    final query = searchQuery.toLowerCase();

    final students = docs.where((doc) {
      final data = doc.data();
      final normalizedDept = _normalizeDept((data['dept'] ?? '').toString());
      if (normalizedDept != selectedDepartment) {
        return false;
      }

      final rawYear = (data['year'] ?? data['academicYear'] ?? '').toString();
      if (selectedYear.isNotEmpty &&
          selectedYear != '2026' &&
          rawYear.trim().isNotEmpty &&
          rawYear.trim().toLowerCase() != selectedYear) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final name =
          (data['fullName'] ?? data['name'] ?? '').toString().toLowerCase();
      final enrollment =
          (data['enrollmentNo'] ?? '').toString().toLowerCase();
      final company =
          (data['company_name'] ?? data['company'] ?? '').toString().toLowerCase();

      return name.contains(query) ||
          enrollment.contains(query) ||
          company.contains(query);
    }).map((doc) {
      final data = doc.data();
      return {
        'uid': doc.id,
        'name': (data['fullName'] ?? data['name'] ?? 'Student').toString(),
        'enrollmentNo': (data['enrollmentNo'] ?? 'N/A').toString(),
        'dept': _normalizeDept((data['dept'] ?? '').toString()),
        'status': _formatStatus((data['internshipStatus'] ?? '').toString()),
        'profileImageUrl': (data['profileImageUrl'] ?? '').toString(),
        'company': (data['company_name'] ?? data['company'] ?? '').toString(),
      };
    }).toList();

    students.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
    return students;
  }

  String _normalizeDept(String? dept) {
    if (dept == null) {
      return 'Others';
    }

    final normalized = dept.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'Others';
    }

    return _departmentAliases[normalized] ?? 'Others';
  }

  String _formatStatus(String rawStatus) {
    final normalized = rawStatus.trim().toLowerCase();
    if (normalized == 'completed' || normalized == 'complete') {
      return 'Completed';
    }
    if (normalized == 'ongoing' ||
        normalized == 'pursuing' ||
        normalized == 'active' ||
        normalized == 'in progress' ||
        normalized == 'inprogress') {
      return 'Active';
    }
    if (normalized.isEmpty) {
      return 'Pending';
    }
    return rawStatus.trim();
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    final imageUrl = (student['profileImageUrl'] ?? '').toString();
    final name = (student['name'] ?? 'Student').toString();
    final enrollmentNo = (student['enrollmentNo'] ?? 'N/A').toString();
    final dept = (student['dept'] ?? 'Others').toString();
    final status = (student['status'] ?? 'Pending').toString();
    final company = (student['company'] ?? '').toString().trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color(0xFFDCE8FF),
          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
          child: imageUrl.isEmpty
              ? Text(
                  name.isEmpty ? '?' : name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF4A80FF),
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enrollment No: $enrollmentNo',
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                company.isEmpty ? dept : '$dept • $company',
                style: const TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusTag(status),
            const SizedBox(height: 10),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.black38,
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PrincipalStudentProfileScreen(studentData: student),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color color;
    switch (status) {
      case 'Completed':
        color = Colors.green;
        break;
      case 'Active':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
