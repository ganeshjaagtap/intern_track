import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Ensure these imports match your actual file structure
import 'faculty_details_screen.dart';
import 'company_approvals.dart';

class ReviewApprovalsScreen extends StatefulWidget {
  const ReviewApprovalsScreen({super.key});

  @override
  State<ReviewApprovalsScreen> createState() => _ReviewApprovalsScreenState();
}

class _ReviewApprovalsScreenState extends State<ReviewApprovalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); 
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// ---------------- APPROVE USER ----------------
  Future<void> approveUser(
    String uid,
    String name,
    String role,
    Map<String, dynamic> userData,
  ) async {
    String? facultyMentorId;

    if (role == 'student') {
      final studentDept = (userData['dept'] ?? '').toString().trim();
      facultyMentorId = await _showFacultyMentorSelectionDialog(
        name: name,
        dept: studentDept,
      );
      if (facultyMentorId == null) {
        return;
      }
    }

    try {
      final updateData = <String, dynamic>{
        'isApproved': true,
      };

      if (role == 'student') {
        if (facultyMentorId == null || facultyMentorId.trim().isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Faculty Mentor ID is required."),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        updateData['facultyId'] = facultyMentorId.trim();
        updateData['internshipStatus'] = 'Ongoing';
      }

      await FirebaseFirestore.instance.collection('user').doc(uid).update(updateData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$name Approved!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print("Error approving user: $e");
    }
  }

  Future<String?> _showFacultyMentorSelectionDialog({
    required String name,
    required String dept,
  }) async {
    if (dept.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Student department is missing."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }

    final mentorsSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('role', isEqualTo: 'faculty')
        .where('dept', isEqualTo: dept)
        .where('isApproved', isEqualTo: true)
        .get();

    final mentors = mentorsSnapshot.docs
        .where((doc) {
          final data = doc.data();
          final facultyId = (data['facultyId'] ?? '').toString().trim();
          return facultyId.isNotEmpty;
        })
        .map((doc) {
          final data = doc.data();
          return {
            'facultyId': (data['facultyId'] ?? '').toString().trim(),
            'name': (data['fullName'] ?? data['name'] ?? 'Faculty').toString(),
          };
        })
        .toList();

    if (mentors.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No mentors found for $dept department."),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        String? selectedFacultyId = mentors.first['facultyId'];

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Assign Faculty Mentor"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select faculty mentor for $name"),
                  const SizedBox(height: 6),
                  Text(
                    "Department: $dept",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedFacultyId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Faculty Mentor",
                      border: OutlineInputBorder(),
                    ),
                    items: mentors.map((mentor) {
                      final facultyId = mentor['facultyId'] ?? '';
                      final mentorName = mentor['name'] ?? 'Faculty';
                      return DropdownMenuItem<String>(
                        value: facultyId,
                        child: Text("$mentorName ($facultyId)"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedFacultyId = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final value = selectedFacultyId?.trim() ?? '';
                    if (value.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a faculty mentor."),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(dialogContext, value);
                  },
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        );
      },
    );

    return result;
  }

  /// ---------------- REJECT USER ----------------
  Future<void> rejectUser(String uid, String name) async {
    try {
      await FirebaseFirestore.instance.collection('user').doc(uid).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$name Rejected."), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("Error rejecting user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HOD Dashboard"),
        backgroundColor: const Color(0xFF5F9ED6),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Pending Students"),
            Tab(text: "Pending Faculty"),
            Tab(text: "Pending Mentors"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserList('student', false),
          _buildUserList('faculty', false),
          _buildUserList('mentor', false),
        ],
      ),
    );
  }

  /// ---------------- DYNAMIC LIST BUILDER ----------------
  Widget _buildUserList(String targetRole, bool targetApprovalStatus) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user')
          .where('role', isEqualTo: targetRole)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyStateMessage(targetRole, targetApprovalStatus);
        }

        final filteredUsers = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          dynamic rawValue = data['isApproved'];

          bool isApprovedBool;
          if (rawValue == null) {
            isApprovedBool = false; 
          } else if (rawValue is bool) {
            isApprovedBool = rawValue;
          } else {
            isApprovedBool = rawValue.toString().toLowerCase() == 'true';
          }
          
          return isApprovedBool == targetApprovalStatus;
        }).toList();

        if (filteredUsers.isEmpty) {
          return _emptyStateMessage(targetRole, targetApprovalStatus);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final doc = filteredUsers[index];
            final data = doc.data() as Map<String, dynamic>;
            
            final uid = doc.id;
            final name = data['fullName'] ?? data['name'] ?? "Unknown Name";
            final email = data['email'] ?? "No Email";
            final imageUrl = (data['profileImageUrl'] ?? '').toString();
            final logoUrl =
                (data['logoUrl'] ?? data['companyLogoUrl'] ?? '').toString();
            final avatarUrl = imageUrl.isNotEmpty ? imageUrl : logoUrl;

            String subtitleText = email;
            if (targetRole == 'student') {
              subtitleText = "College: ${data['college'] ?? 'Not Provided'}";
            } else if (targetRole == 'faculty') {
              subtitleText = "Dept: ${data['dept'] ?? 'Not Provided'}";
            } else if (targetRole == 'mentor') {
              subtitleText = "Company: ${data['company_name'] ?? 'Not Provided'}";
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF5F9ED6).withOpacity(0.2),
                  backgroundImage: avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl.isEmpty
                      ? Icon(
                          targetRole == 'student' ? Icons.school :
                          targetRole == 'faculty' ? Icons.person : Icons.business,
                          color: const Color(0xFF5F9ED6),
                        )
                      : null,
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(subtitleText, style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
                
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                      onPressed: () => approveUser(uid, name, targetRole, data),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red, size: 28),
                      onPressed: () => rejectUser(uid, name),
                    ),
                  ],
                ),
                onTap: () {
                  // ✅ Navigate to detailed view on tap
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserDetailView(
                        userData: data,
                        uid: uid,
                        role: targetRole,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _emptyStateMessage(String role, bool isApproved) {
    return Center(
      child: Text(
        "No pending $role requests.",
        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
      ),
    );
  }
}

/// ---------------- DETAILED USER VIEW ----------------
class UserDetailView extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String uid;
  final String role;

  const UserDetailView({
    super.key, 
    required this.userData, 
    required this.uid, 
    required this.role
  });

  @override
  Widget build(BuildContext context) {
    final name = userData['fullName'] ?? userData['name'] ?? "N/A";
    final email = userData['email'] ?? "N/A";
    final phone = userData['phone'] ?? "Not Provided";
    final imageUrl = (userData['profileImageUrl'] ?? '').toString();
    final logoUrl =
        (userData['logoUrl'] ?? userData['companyLogoUrl'] ?? '').toString();
    final avatarUrl = imageUrl.isNotEmpty ? imageUrl : logoUrl;
    final Color primaryBlue = const Color(0xFF5F9ED6);

    return Scaffold(
      appBar: AppBar(
        title: Text("${role[0].toUpperCase()}${role.substring(1)} Details"),
        backgroundColor: primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: primaryBlue.withOpacity(0.1),
              backgroundImage: avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl.isEmpty
                  ? Icon(Icons.person, size: 60, color: primaryBlue)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "PENDING APPROVAL",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
              ),
            ),
            const SizedBox(height: 32),
            
            _buildInfoCard([
              _infoRow(Icons.email, "Email Address", email),
              _infoRow(Icons.phone, "Phone Number", phone),
              
              if (role == 'student') ...[
                _infoRow(Icons.school, "College Name", userData['college'] ?? "N/A"),
                _infoRow(Icons.numbers, "Enrollment Number", userData['enrollmentNo'] ?? "N/A"),
              ],
              if (role == 'faculty') ...[
                _infoRow(Icons.account_tree, "Department", userData['dept'] ?? "N/A"),
              ],
              if (role == 'mentor') ...[
                _infoRow(Icons.business, "Company Name", userData['company_name'] ?? "N/A"),
                _infoRow(Icons.work, "Designation", userData['designation'] ?? "N/A"),
              ],
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF5F9ED6), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value != "" ? value : "Not Provided", 
                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
