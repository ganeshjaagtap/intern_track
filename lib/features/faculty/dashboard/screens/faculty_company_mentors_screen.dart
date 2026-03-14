import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FacultyCompanyMentorsScreen extends StatefulWidget {
  const FacultyCompanyMentorsScreen({super.key});

  @override
  State<FacultyCompanyMentorsScreen> createState() =>
      _FacultyCompanyMentorsScreenState();
}

class _FacultyCompanyMentorsScreenState
    extends State<FacultyCompanyMentorsScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  bool _hasError = false;
  String _searchQuery = "";

  List<Map<String, dynamic>> _allMentors = [];
  List<Map<String, dynamic>> _visibleMentors = [];

  @override
  void initState() {
    super.initState();
    _loadMentors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMentors() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid == null) {
        throw Exception("Faculty user not logged in");
      }

      final facultyDoc = await FirebaseFirestore.instance
          .collection("user")
          .doc(currentUid)
          .get();
      final facultyData = facultyDoc.data() ?? {};
      final facultyShortId =
          (facultyData["facultyId"] ?? facultyData["uid"] ?? "").toString().trim();

      if (facultyShortId.isEmpty) {
        setState(() {
          _allMentors = [];
          _visibleMentors = [];
          _isLoading = false;
        });
        return;
      }

      final studentSnapshot = await FirebaseFirestore.instance
          .collection("user")
          .where("role", isEqualTo: "student")
          .where("facultyId", isEqualTo: facultyShortId)
          .get();

      final Map<String, Map<String, dynamic>> mentorsByKey = {};

      for (final doc in studentSnapshot.docs) {
        final studentData = doc.data();
        final mentorId =
            (studentData["companyMentorId"] ?? "").toString().trim();
        final mentorName =
            (studentData["companyMentor"] ?? "").toString().trim();
        final companyName = (studentData["company"] ?? "").toString().trim();

        Map<String, dynamic>? mentorData;

        if (mentorId.isNotEmpty) {
          final mentorSnapshot = await FirebaseFirestore.instance
              .collection("user")
              .where("role", isEqualTo: "mentor")
              .where("mentorId", isEqualTo: mentorId)
              .limit(1)
              .get();

          if (mentorSnapshot.docs.isNotEmpty) {
            final mentorDoc = mentorSnapshot.docs.first;
            final raw = mentorDoc.data();
            mentorData = {
              "docId": mentorDoc.id,
              "mentorId": (raw["mentorId"] ?? mentorId).toString(),
              "name": (raw["fullName"] ?? mentorName).toString(),
              "companyName": (raw["company_name"] ?? companyName).toString(),
              "email": (raw["email"] ?? "").toString(),
              "phone":
                  (raw["phoneNumber"] ?? raw["phone"] ?? "").toString(),
              "profileImageUrl": (raw["profileImageUrl"] ?? "").toString(),
            };
          }
        }

        mentorData ??= {
          "docId": "",
          "mentorId": mentorId,
          "name": mentorName.isEmpty ? "Company Mentor" : mentorName,
          "companyName": companyName,
          "email": "",
          "phone": "",
          "profileImageUrl": "",
        };

        final dedupeKey = _mentorKey(mentorData);
        if (dedupeKey.isEmpty) continue;

        mentorsByKey.putIfAbsent(dedupeKey, () => mentorData!);
      }

      final mentors = mentorsByKey.values.toList()
        ..sort((a, b) => (a["name"] ?? "")
            .toString()
            .toLowerCase()
            .compareTo((b["name"] ?? "").toString().toLowerCase()));

      if (!mounted) return;

      setState(() {
        _allMentors = mentors;
        _visibleMentors = mentors;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  String _mentorKey(Map<String, dynamic> mentor) {
    final mentorId = (mentor["mentorId"] ?? "").toString().trim();
    final email = (mentor["email"] ?? "").toString().trim().toLowerCase();
    final phone = (mentor["phone"] ?? "").toString().trim();
    final name = (mentor["name"] ?? "").toString().trim().toLowerCase();

    if (mentorId.isNotEmpty) return "id:$mentorId";
    if (email.isNotEmpty) return "email:$email";
    if (phone.isNotEmpty) return "phone:$phone";
    if (name.isNotEmpty) return "name:$name";
    return "";
  }

  void _applySearch(String query) {
    final lower = query.toLowerCase();
    setState(() {
      _searchQuery = lower;
      _visibleMentors = _allMentors.where((mentor) {
        final name = (mentor["name"] ?? "").toString().toLowerCase();
        final company =
            (mentor["companyName"] ?? "").toString().toLowerCase();
        final email = (mentor["email"] ?? "").toString().toLowerCase();
        final phone = (mentor["phone"] ?? "").toString().toLowerCase();
        return name.contains(lower) ||
            company.contains(lower) ||
            email.contains(lower) ||
            phone.contains(lower);
      }).toList();
    });
  }

  Future<void> _showMentorDetails(Map<String, dynamic> mentor) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final name = (mentor["name"] ?? "Company Mentor").toString();
        final company = (mentor["companyName"] ?? "").toString().trim();
        final email = (mentor["email"] ?? "").toString().trim();
        final phone = (mentor["phone"] ?? "").toString().trim();
        final imageUrl = (mentor["profileImageUrl"] ?? "").toString().trim();

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF6BB6FF).withOpacity(0.12),
                    backgroundImage: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : null,
                    child: imageUrl.isEmpty
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "M",
                            style: const TextStyle(
                              color: Color(0xFF6BB6FF),
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _detailRow("Company", company.isEmpty ? "Not available" : company),
              _detailRow("Email", email.isEmpty ? "Not available" : email),
              _detailRow("Phone", phone.isEmpty ? "Not available" : phone),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BB6FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  onPressed: phone.isEmpty
                      ? null
                      : () {
                          Navigator.pop(context);
                          _launchCall(phone);
                        },
                  icon: const Icon(Icons.call),
                  label: const Text("Call"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchCall(String phoneNumber) async {
    final cleaned = phoneNumber.trim();
    if (cleaned.isEmpty) {
      _showMessage("Phone number not available.");
      return;
    }

    final uri = Uri(scheme: "tel", path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }

    _showMessage("Could not launch phone dialer.");
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        title: const Text(
          "Company Mentors",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : _hasError
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        const Text(
                          "Unable to load mentors",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _loadMentors,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _applySearch,
                        decoration: InputDecoration(
                          hintText: "Search mentor by name, company or contact",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _visibleMentors.isEmpty
                          ? Center(
                              child: Text(
                                _searchQuery.isEmpty
                                    ? "No company mentors found for your students."
                                    : "No mentors match your search.",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              itemCount: _visibleMentors.length,
                              itemBuilder: (context, index) {
                                final mentor = _visibleMentors[index];
                                final name =
                                    (mentor["name"] ?? "Company Mentor").toString();
                                final company =
                                    (mentor["companyName"] ?? "").toString().trim();
                                final email =
                                    (mentor["email"] ?? "").toString().trim();
                                final phone =
                                    (mentor["phone"] ?? "").toString().trim();
                                final imageUrl =
                                    (mentor["profileImageUrl"] ?? "").toString().trim();
                                final subtitle = company.isNotEmpty
                                    ? company
                                    : (email.isNotEmpty
                                        ? email
                                        : (phone.isNotEmpty
                                            ? phone
                                            : "Details not available"));

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    onTap: () => _showMentorDetails(mentor),
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          const Color(0xFF6BB6FF).withOpacity(0.12),
                                      backgroundImage: imageUrl.isNotEmpty
                                          ? NetworkImage(imageUrl)
                                          : null,
                                      child: imageUrl.isEmpty
                                          ? Text(
                                              name.isNotEmpty
                                                  ? name[0].toUpperCase()
                                                  : "M",
                                              style: const TextStyle(
                                                color: Color(0xFF6BB6FF),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          : null,
                                    ),
                                    title: Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(subtitle),
                                    trailing: const Icon(Icons.chevron_right),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
