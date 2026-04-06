import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MentorDetailScreen extends StatefulWidget {
  final Map<String, String> mentorData;

  const MentorDetailScreen({super.key, required this.mentorData});

  @override
  State<MentorDetailScreen> createState() => _MentorDetailScreenState();
}

class _MentorDetailScreenState extends State<MentorDetailScreen> {

  static const Color primaryBlue = Color(0xFF64A9F6);

  int totalStudents = 0;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    fetchStudentCount();
  }

  /// FETCH STUDENT COUNT
  Future<void> fetchStudentCount() async {

    final facultyId = widget.mentorData['id'] ?? "";

    if (facultyId.isEmpty) {
      if (!mounted) return;
      setState(() {
        totalStudents = 0;
      });
      return;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('role', isEqualTo: 'student')
        .where('facultyId', isEqualTo: facultyId)
        .get();

    if (!mounted) return;

    setState(() {
      totalStudents = snapshot.docs.length;
    });
  }

  Future<void> _confirmDeleteMentor() async {
    if (_isDeleting) return;

    final name = widget.mentorData['name'] ?? "this mentor";
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Mentor"),
          content: Text(
            "Are you sure you want to delete $name? This will remove the mentor from Firestore and clear linked student assignments.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteMentor();
    }
  }

  Future<void> _deleteMentor() async {
    final mentorDocId = (widget.mentorData['docId'] ?? "").trim();
    final facultyId = (widget.mentorData['id'] ?? "").trim();
    final mentorName = widget.mentorData['name'] ?? "Mentor";

    if (mentorDocId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to delete mentor: missing document ID."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;

      if (facultyId.isNotEmpty) {
        final linkedStudents = await firestore
            .collection('user')
            .where('role', isEqualTo: 'student')
            .where('facultyId', isEqualTo: facultyId)
            .get();

        for (final chunk in _chunkDocuments(linkedStudents.docs, 400)) {
          final batch = firestore.batch();

          for (final studentDoc in chunk) {
            batch.update(studentDoc.reference, {
              'facultyId': FieldValue.delete(),
              'collegeMentor': FieldValue.delete(),
              'facultyMentorName': FieldValue.delete(),
              'facultyName': FieldValue.delete(),
            });
          }

          await batch.commit();
        }
      }

      await firestore.collection('user').doc(mentorDocId).delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$mentorName deleted successfully."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete mentor: $e"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isDeleting = false;
      });
    }
  }

  List<List<QueryDocumentSnapshot>> _chunkDocuments(
    List<QueryDocumentSnapshot> docs,
    int chunkSize,
  ) {
    final chunks = <List<QueryDocumentSnapshot>>[];

    for (var i = 0; i < docs.length; i += chunkSize) {
      final end = (i + chunkSize > docs.length) ? docs.length : i + chunkSize;
      chunks.add(docs.sublist(i, end));
    }

    return chunks;
  }

  @override
  Widget build(BuildContext context) {

    final name = widget.mentorData['name'] ?? "Unknown Mentor";
    final designation = widget.mentorData['designation'] ?? "Faculty Member";
    final img = widget.mentorData['img'] ?? "";
    final email = widget.mentorData['email'] ?? "";
    final phone = widget.mentorData['phone'] ?? "Not Provided";
    final id = widget.mentorData['id'] ?? "Not Assigned";
    final dept = widget.mentorData['dept'] ?? "Not Specified";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      extendBodyBehindAppBar: true,

      /// APP BAR
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      /// BODY
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 90, bottom: 40),
              decoration: const BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [

                  /// PROFILE IMAGE
                  Hero(
                    tag: name,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 56,
                        backgroundImage: img.isNotEmpty
                            ? NetworkImage(img)
                            : null,
                        child: img.isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// NAME
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// DESIGNATION
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      designation,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            /// DETAILS
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// FACULTY INFO
                  _buildSectionTitle("Faculty Information"),
                  _buildDetailCard([
                    _buildRow(Icons.badge_outlined, "Faculty ID", id),
                    _buildRow(Icons.account_tree_outlined, "Department", dept),
                    _buildRow(Icons.workspace_premium_outlined, "Designation", designation),
                  ]),

                  const SizedBox(height: 20),

                  /// CONTACT INFO
                  _buildSectionTitle("Contact Details"),
                  _buildDetailCard([
                    _buildRow(Icons.email_outlined, "Email", email),
                    _buildRow(Icons.phone_android_outlined, "Phone", phone),
                  ]),

                  const SizedBox(height: 20),

                  /// STUDENT COUNT
                  _buildSectionTitle("Student Oversight"),
                  _buildDetailCard([
                    _buildRow(Icons.groups_outlined, "Total Students", totalStudents.toString()),
                  ]),

                  const SizedBox(height: 30),

                  /// EMAIL BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text(
                        "SEND EMAIL",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      onPressed: email.isEmpty ? null : () => _launchEmail(email),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: _isDeleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.delete_outline),
                      label: Text(
                        _isDeleting ? "DELETING..." : "DELETE MENTOR",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      onPressed: _isDeleting ? null : _confirmDeleteMentor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        disabledBackgroundColor: Colors.red.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// SECTION TITLE
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey.shade400,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  /// CARD
  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  /// ROW
  Widget _buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryBlue, size: 20),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// EMAIL FUNCTION
  Future<void> _launchEmail(String email) async {

    final Uri url = Uri(
      scheme: 'mailto',
      path: email,
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }
}
