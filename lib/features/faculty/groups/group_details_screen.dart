import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/features/faculty/groups/group_model.dart';
import 'package:flutter_application_2/features/faculty/groups/select_student_screen.dart';

class GroupDetailsScreen extends StatefulWidget {
  final GroupModel group;
  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ ADD STUDENT: Updates Group doc AND Student doc
  Future<void> _addStudent(Map<String, dynamic> studentData) async {
    final String studentUid = studentData['uid'];
    final String studentName = studentData['name'];

    WriteBatch batch = _firestore.batch();
    DocumentReference groupRef = _firestore.collection('groups').doc(widget.group.id);
    DocumentReference studentRef = _firestore.collection('user').doc(studentUid);

    batch.update(groupRef, {
      'studentIds': FieldValue.arrayUnion([studentUid]),
    });

    batch.update(studentRef, {
      'assignedGroupId': widget.group.id,
      'assignedGroupName': widget.group.name,
    });

    try {
      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$studentName added to group!")),
        );
      }
    } catch (e) {
      debugPrint("Add Error: $e");
    }
  }

  /// ✅ REMOVE STUDENT: Clears data from both locations
  Future<void> _removeStudent(String studentUid) async {
    WriteBatch batch = _firestore.batch();
    DocumentReference groupRef = _firestore.collection('groups').doc(widget.group.id);
    DocumentReference studentRef = _firestore.collection('user').doc(studentUid);

    batch.update(groupRef, {
      'studentIds': FieldValue.arrayRemove([studentUid])
    });
    
    batch.update(studentRef, {
      'assignedGroupId': FieldValue.delete(),
      'assignedGroupName': FieldValue.delete(),
    });

    try {
      await batch.commit();
    } catch (e) {
      debugPrint("Remove Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.group.name),
        backgroundColor: const Color(0xFF6EA8DC),
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('groups').doc(widget.group.id).snapshots(),
        builder: (context, snapshot) {
          // 1. Check for connection errors
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          // 2. Handle Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 3. ✅ CRITICAL NULL CHECK: Fixes "null is not a subtype of Map"
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Group no longer exists."));
          }

          // 4. Safe Data Extraction
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) return const Center(child: Text("No data found"));

          final List<String> memberIds = List<String>.from(data['studentIds'] ?? []);

          if (memberIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_add_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    "This group is empty",
                    style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const Text("Click 'Add Member' to start building your team."),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: memberIds.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('user').doc(memberIds[index]).get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const Card(child: ListTile(title: Text("Loading member...")));
                  }
                  
                  if (!userSnap.data!.exists) return const SizedBox();

                  final userData = userSnap.data!.data() as Map<String, dynamic>?;
                  if (userData == null) return const SizedBox();

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF6EA8DC).withOpacity(0.2),
                        child: const Icon(Icons.person, color: Color(0xFF6EA8DC)),
                      ),
                      title: Text(
                        userData['fullName'] ?? "Unnamed Student",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Enrollment: ${userData['enrollmentNo'] ?? 'N/A'}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                        onPressed: () => _removeStudent(memberIds[index]),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Add Member"),
        icon: const Icon(Icons.person_add),
        backgroundColor: const Color(0xFF6EA8DC),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SelectStudentScreen()),
          );
          if (result != null) _addStudent(result as Map<String, dynamic>);
        },
      ),
    );
  }
}