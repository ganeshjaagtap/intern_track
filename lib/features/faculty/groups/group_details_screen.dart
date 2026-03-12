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
    DocumentReference groupRef = _firestore
        .collection('groups')
        .doc(widget.group.id);
    DocumentReference studentRef = _firestore
        .collection('user')
        .doc(studentUid);

    // 1. Add UID to Group
    batch.update(groupRef, {
      'studentIds': FieldValue.arrayUnion([studentUid]),
    });

    // 2. Link Group details to Student profile
    batch.update(studentRef, {
      'assignedGroupId': widget.group.id,
      'assignedGroupName': widget.group.name,
    });

    try {
      await batch.commit();
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$studentName added to group!")));
    } catch (e) {
      debugPrint("Add Error: $e");
    }
  }

  /// ✅ REMOVE STUDENT: Clears data from both locations
  Future<void> _removeStudent(String studentUid) async {
    WriteBatch batch = _firestore.batch();
    DocumentReference groupRef = _firestore
        .collection('groups')
        .doc(widget.group.id);
    DocumentReference studentRef = _firestore
        .collection('user')
        .doc(studentUid);

    batch.update(groupRef, {
      'studentIds': FieldValue.arrayRemove([studentUid]),
    });
    batch.update(studentRef, {
      'assignedGroupId': FieldValue.delete(),
      'assignedGroupName': FieldValue.delete(),
    });

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        backgroundColor: const Color(0xFF6EA8DC),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('groups')
            .doc(widget.group.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List<String> memberIds = List<String>.from(
            data['studentIds'] ?? [],
          );

          if (memberIds.isEmpty)
            return const Center(child: Text("No students in this group."));

          return ListView.builder(
            itemCount: memberIds.length,
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore
                    .collection('user')
                    .doc(memberIds[index])
                    .get(),
                builder: (context, userSnap) {
                  if (userSnap.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }

                  if (userSnap.hasError) {
                    return const SizedBox();
                  }

                  if (!userSnap.hasData || !userSnap.data!.exists) {
                    return const SizedBox();
                  }

                  final data = userSnap.data!.data();
                  if (data == null) {
                    return const SizedBox();
                  }

                  final userData = data as Map<String, dynamic>;

                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(userData['fullName'] ?? "Unknown"),
                    subtitle: Text(userData['enrollmentNo'] ?? ""),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeStudent(memberIds[index]),
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
          if (result != null) _addStudent(result);
        },
      ),
    );
  }
}
