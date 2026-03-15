import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'principal_intern_detail_screen.dart';

class PrincipalActiveInternSummaryScreen extends StatefulWidget {
  const PrincipalActiveInternSummaryScreen({super.key});

  @override
  State<PrincipalActiveInternSummaryScreen> createState() =>
      _PrincipalActiveInternSummaryScreenState();
}

class _PrincipalActiveInternSummaryScreenState
    extends State<PrincipalActiveInternSummaryScreen> {
  final Color jasmine = const Color(0xFFFFE588);
  String selectedDept = "All";

  static const Map<String, String> _departmentAliases = {
    'it': 'IT',
    'information technology': 'IT',
    'information tech': 'IT',
    'cse': 'Computer',
    'computer science': 'Computer',
    'computer engineering': 'Computer',
    'computer': 'Computer',
    'cs': 'Computer',
    'me': 'Mechanical',
    'mechanical': 'Mechanical',
    'mechanical engineering': 'Mechanical',
    'civil': 'Civil',
    'civil engineering': 'Civil',
    'ee': 'Electrical',
    'electrical': 'Electrical',
    'electrical engineering': 'Electrical',
    'electronics': 'Electronics',
    'electronics engineering': 'Electronics',
    'entc': 'Electronics',
    'e&tc': 'Electronics',
    'aiml': 'AIML',
    'ai & ml': 'AIML',
    'artificial intelligence and machine learning': 'AIML',
    'automobile': 'Automobile',
    'automobile engineering': 'Automobile',
    'ddgm': 'DDGM',
  };

  static const Map<String, String> _companyAliases = {
    'tata consultancy services': 'TCS',
    'tcs': 'TCS',
    't.c.s.': 'TCS',
    'infosys ltd': 'Infosys',
    'infosys limited': 'Infosys',
    'infosys': 'Infosys',
    'wipro ltd': 'Wipro',
    'wipro limited': 'Wipro',
    'wipro': 'Wipro',
    'google llc': 'Google',
    'google': 'Google',
    'amazon inc': 'Amazon',
    'amazon': 'Amazon',
    'amazon web services': 'Amazon',
    'meta platforms': 'Meta',
    'meta': 'Meta',
    'facebook': 'Meta',
    'microsoft corporation': 'Microsoft',
    'microsoft': 'Microsoft',
    'apple inc': 'Apple',
    'apple': 'Apple',
    'tesla motors': 'Tesla',
    'tesla': 'Tesla',
    'netflix india': 'Netflix',
    'netflix': 'Netflix',
  };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .snapshots(),
      builder: (context, snapshot) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collectionGroup('records').snapshots(),
          builder: (context, attendanceSnapshot) {
            final attendanceByEnrollment =
                _buildAttendanceSummary(attendanceSnapshot.data?.docs ?? const []);
            final interns = _buildActiveInterns(
              snapshot.data?.docs ?? const [],
              attendanceByEnrollment,
            );
            final departments = _buildDepartments(interns);
            final companies = _buildCompanies(interns);

            if (selectedDept != "All" && !departments.contains(selectedDept)) {
              selectedDept = "All";
            }

            final filteredInterns = interns.where((intern) {
              if (selectedDept == "All") {
                return true;
              }
              return intern['dept'] == selectedDept;
            }).toList();

            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: jasmine,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  "Active Internships",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: _buildBody(
                context: context,
                userSnapshot: snapshot,
                attendanceSnapshot: attendanceSnapshot,
                companies: companies,
                departments: departments,
                filteredInterns: filteredInterns,
                allInterns: interns,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> userSnapshot,
    required AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> attendanceSnapshot,
    required List<String> companies,
    required List<String> departments,
    required List<Map<String, dynamic>> filteredInterns,
    required List<Map<String, dynamic>> allInterns,
  }) {
    if (userSnapshot.connectionState == ConnectionState.waiting ||
        attendanceSnapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userSnapshot.hasError || attendanceSnapshot.hasError) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "Unable to load active internship data right now.",
            style: TextStyle(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (allInterns.isEmpty) {
      return const Center(
        child: Text(
          "No active interns found.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(
            "Hiring Partners (Tap to view)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        _buildCompanyTicker(companies, allInterns),
        const SizedBox(height: 20),
        _buildDeptChips(departments),
        const SizedBox(height: 10),
        Expanded(
          child: filteredInterns.isEmpty
              ? const Center(
                  child: Text("No active interns in this department"),
                )
              : ListView.builder(
                  itemCount: filteredInterns.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) =>
                      _buildProgressCard(filteredInterns[index]),
                ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _buildActiveInterns(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    Map<String, _AttendanceSummary> attendanceByEnrollment,
  ) {
    final interns = <Map<String, dynamic>>[];
    final mentorsByKey = <String, Map<String, dynamic>>{};

    for (final doc in docs) {
      final data = doc.data();
      final role = (data['role'] ?? '').toString().trim().toLowerCase();
      if (role != 'mentor') {
        continue;
      }

      final mentorId = (data['mentorId'] ?? '').toString().trim();
      if (mentorId.isNotEmpty) {
        mentorsByKey[mentorId] = data;
      }
      mentorsByKey[doc.id] = data;
    }

    for (final doc in docs) {
      final data = doc.data();
      final role = (data['role'] ?? '').toString().trim().toLowerCase();
      if (role != 'student') {
        continue;
      }

      if (!_isActiveStatus(data['internshipStatus']?.toString())) {
        continue;
      }

      final company = _normalizeCompany(
        _resolveCompanyName(data, mentorsByKey),
      );
      if (company.isEmpty) {
        continue;
      }

      final name =
          (data['fullName'] ?? data['name'] ?? 'Student').toString().trim();
      final dept = _normalizeDept((data['dept'] ?? '').toString());
      final enrollmentNo = (data['enrollmentNo'] ?? '').toString().trim();
      final attendance =
          attendanceByEnrollment[enrollmentNo] ?? const _AttendanceSummary();
      final progress = _deriveAttendanceProgress(attendance);

      interns.add({
        'id': doc.id,
        'name': name.isEmpty ? 'Student' : name,
        'company': company,
        'dept': dept,
        'week': progress.completedUnits,
        'total': progress.totalUnits,
        'presentCount': attendance.presentCount,
        'attendanceTotal': attendance.totalCount,
        'enrollmentNo': enrollmentNo,
        'profileImageUrl': (data['profileImageUrl'] ?? '').toString(),
        'internshipRole': (data['internshipRole'] ?? 'Intern').toString(),
        'internshipStatus': (data['internshipStatus'] ?? '').toString(),
      });
    }

    interns.sort((a, b) {
      final companyCompare =
          a['company'].toString().compareTo(b['company'].toString());
      if (companyCompare != 0) {
        return companyCompare;
      }
      return a['name'].toString().compareTo(b['name'].toString());
    });

    return interns;
  }

  Map<String, _AttendanceSummary> _buildAttendanceSummary(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final summaryByEnrollment = <String, _AttendanceSummary>{};

    for (final doc in docs) {
      final enrollmentNo = doc.reference.parent.parent?.id ?? '';
      if (enrollmentNo.isEmpty) {
        continue;
      }

      final status = (doc.data()['status'] ?? '').toString().trim().toLowerCase();
      final current =
          summaryByEnrollment[enrollmentNo] ?? const _AttendanceSummary();

      summaryByEnrollment[enrollmentNo] = _AttendanceSummary(
        presentCount: current.presentCount + (status == 'present' ? 1 : 0),
        totalCount: current.totalCount +
            ((status == 'present' || status == 'absent' || status == 'leave')
                ? 1
                : 0),
      );
    }

    return summaryByEnrollment;
  }

  String _resolveCompanyName(
    Map<String, dynamic> studentData,
    Map<String, Map<String, dynamic>> mentorsByKey,
  ) {
    final rawCompany =
        (studentData['company'] ?? studentData['company_name'] ?? '')
            .toString()
            .trim();
    final mentorRef =
        (studentData['companyMentorId'] ?? studentData['mentorId'] ?? '')
            .toString()
            .trim();
    final mentorData =
        mentorRef.isEmpty ? null : mentorsByKey[mentorRef];

    final mentorName = (
      mentorData?['fullName'] ??
      mentorData?['name'] ??
      studentData['companyMentor'] ??
      ''
    ).toString().trim();

    final mentorCompany =
        (mentorData?['company_name'] ?? mentorData?['company'] ?? '')
            .toString()
            .trim();

    if (rawCompany.isEmpty) {
      return mentorCompany;
    }

    final rawNormalized = rawCompany.toLowerCase();
    final mentorNameNormalized = mentorName.toLowerCase();

    if (mentorCompany.isNotEmpty &&
        mentorNameNormalized.isNotEmpty &&
        rawNormalized == mentorNameNormalized) {
      return mentorCompany;
    }

    return rawCompany;
  }

  List<String> _buildDepartments(List<Map<String, dynamic>> interns) {
    final departments = interns
        .map((intern) => intern['dept'].toString())
        .where((dept) => dept.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return ['All', ...departments];
  }

  List<String> _buildCompanies(List<Map<String, dynamic>> interns) {
    final companies = interns
        .map((intern) => intern['company'].toString())
        .where((company) => company.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return companies;
  }

  Widget _buildCompanyTicker(
    List<String> companies,
    List<Map<String, dynamic>> allInterns,
  ) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: companies.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final companyName = companies[index];
          return GestureDetector(
            onTap: () => _showCompanyQuickView(context, companyName, allInterns),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: jasmine.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: jasmine.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  companyName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCompanyQuickView(
    BuildContext context,
    String company,
    List<Map<String, dynamic>> allInterns,
  ) {
    final companyStudents = allInterns
        .where((intern) => intern['company'] == company)
        .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$company Students",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${companyStudents.length} Active",
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            if (companyStudents.isEmpty)
              const Center(child: Text("No students assigned here yet."))
            else
              ...companyStudents.take(4).map((student) {
                final imageUrl = (student['profileImageUrl'] ?? '').toString();
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: jasmine.withOpacity(0.3),
                    backgroundImage:
                        imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                    child: imageUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 18,
                            color: Colors.black,
                          )
                        : null,
                  ),
                  title: Text(
                    student['name'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(student['dept'].toString()),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PrincipalInternDetailScreen(internData: student),
                      ),
                    );
                  },
                );
              }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDeptChips(List<String> departments) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: departments.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final dept = departments[index];
          final isSelected = selectedDept == dept;
          return GestureDetector(
            onTap: () => setState(() => selectedDept = dept),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : jasmine.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  dept,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(Map<String, dynamic> intern) {
    final total = (intern['total'] as int?) ?? 16;
    final week = (intern['week'] as int?) ?? 0;
    final progressValue = total <= 0 ? 0.0 : week / total;
    final imageUrl = (intern['profileImageUrl'] ?? '').toString();
    final name = intern['name'].toString();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PrincipalInternDetailScreen(internData: intern),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: jasmine.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: jasmine,
                  backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty
                      ? Text(
                          name.isEmpty ? '?' : name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "at ${intern['company']} (${intern['dept']})",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "Week $week/$total",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressValue.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                color: Colors.orange,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isActiveStatus(String? status) {
    final normalized = (status ?? '').trim().toLowerCase();
    return normalized == 'ongoing' ||
        normalized == 'pursuing' ||
        normalized == 'active' ||
        normalized == 'in progress' ||
        normalized == 'inprogress';
  }

  String _normalizeDept(String dept) {
    final normalized = dept.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'Others';
    }
    return _departmentAliases[normalized] ?? dept.trim();
  }

  String _normalizeCompany(String company) {
    final normalized = company.trim().toLowerCase();
    if (normalized.isEmpty) {
      return '';
    }
    if (_companyAliases.containsKey(normalized)) {
      return _companyAliases[normalized]!;
    }
    return company.trim().split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) {
        return word;
      }
      return "${word[0].toUpperCase()}${word.substring(1).toLowerCase()}";
    }).join(' ');
  }

  _InternshipProgress _deriveAttendanceProgress(_AttendanceSummary attendance) {
    final totalUnits = attendance.totalCount <= 0 ? 16 : attendance.totalCount;
    final completedUnits = attendance.presentCount.clamp(0, totalUnits);

    return _InternshipProgress(
      completedUnits: completedUnits,
      totalUnits: totalUnits,
    );
  }
}

class _InternshipProgress {
  final int completedUnits;
  final int totalUnits;

  const _InternshipProgress({
    required this.completedUnits,
    required this.totalUnits,
  });
}

class _AttendanceSummary {
  final int presentCount;
  final int totalCount;

  const _AttendanceSummary({
    this.presentCount = 0,
    this.totalCount = 0,
  });
}
