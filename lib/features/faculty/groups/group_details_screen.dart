import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_2/features/faculty/groups/group_model.dart';
import 'package:flutter_application_2/features/faculty/groups/select_student_screen.dart';
import 'package:flutter_application_2/features/faculty/tasks/assign_tasks_screen.dart'; 
import 'package:intl/intl.dart';

class GroupDetailsScreen extends StatefulWidget {
  final GroupModel group;
  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ ROBUST DELETE: Clears Tasks, Student Profiles, and the Group
  Future<void> _deleteGroup() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Delete this group and all its tasks? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      WriteBatch batch = _firestore.batch();
      DocumentReference groupRef = _firestore.collection('groups').doc(widget.group.id);

      // 1. Fetch and Delete all associated Tasks
      QuerySnapshot taskDocs = await _firestore
          .collection('tasks')
          .where('assignedToGroupId', isEqualTo: widget.group.id)
          .get();

      for (var doc in taskDocs.docs) {
        batch.delete(doc.reference);
      }

      // 2. Unassign Students linked to this group
      DocumentSnapshot groupSnap = await groupRef.get();
      if (groupSnap.exists) {
        List memberIds = groupSnap.get('studentIds') ?? [];
        for (String uid in memberIds) {
          batch.update(_firestore.collection('user').doc(uid), {
            'assignedGroupId': FieldValue.delete(),
            'assignedGroupName': FieldValue.delete(),
          });
        }
      }

      // 3. Delete the Group itself
      batch.delete(groupRef);

      // 4. Commit all changes
      await batch.commit();

      // 5. Navigate back to the "My Groups" list screen immediately
      if (mounted) {
        Navigator.of(context).pop(); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Group successfully deleted")),
        );
      }
    } catch (e) {
      debugPrint("Delete error: $e");
      // Fallback: Force delete the group document if batch fails
      await _firestore.collection('groups').doc(widget.group.id).delete();
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _addStudent(Map<String, dynamic> studentData) async {
    final String studentUid = studentData['uid'];
    WriteBatch batch = _firestore.batch();
    batch.update(_firestore.collection('groups').doc(widget.group.id), {'studentIds': FieldValue.arrayUnion([studentUid])});
    batch.update(_firestore.collection('user').doc(studentUid), {'assignedGroupId': widget.group.id, 'assignedGroupName': widget.group.name});
    await batch.commit();
  }

  Future<void> _setLeader(String studentUid, String studentName) async {
    await _firestore.collection('groups').doc(widget.group.id).update({'leaderId': studentUid});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$studentName is now Leader")));
  }

  Future<void> _removeStudent(String studentUid) async {
    WriteBatch batch = _firestore.batch();
    batch.update(_firestore.collection('groups').doc(widget.group.id), {'studentIds': FieldValue.arrayRemove([studentUid])});
    batch.update(_firestore.collection('user').doc(studentUid), {'assignedGroupId': FieldValue.delete(), 'assignedGroupName': FieldValue.delete()});
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(widget.group.name),
          backgroundColor: const Color(0xFF6EA8DC),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.white), 
              onPressed: _deleteGroup,
              tooltip: "Delete Group",
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [Tab(icon: Icon(Icons.people), text: "Members"), Tab(icon: Icon(Icons.assignment), text: "Tasks")],
          ),
        ),
        body: TabBarView(
          children: [_buildMembersTab(), _buildTasksTab()],
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: const Text("Add Member"),
          icon: const Icon(Icons.person_add),
          backgroundColor: const Color(0xFF6EA8DC),
          onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectStudentScreen()));
            if (result != null) _addStudent(result as Map<String, dynamic>);
          },
        ),
      ),
    );
  }

  Widget _buildMembersTab() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('groups').doc(widget.group.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text("Processing..."));
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final List<String> memberIds = List<String>.from(data['studentIds'] ?? []);
        final String? leaderId = data['leaderId'];
        if (memberIds.isEmpty) return _emptyState("No members in this group", Icons.group_off);
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: memberIds.length,
          itemBuilder: (context, index) {
            final uid = memberIds[index];
            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('user').doc(uid).get(),
              builder: (context, userSnap) {
                if (!userSnap.hasData || !userSnap.data!.exists) return const SizedBox();
                final user = userSnap.data!.data() as Map<String, dynamic>;
                final imageUrl = (user['profileImageUrl'] ?? '').toString();
                bool isLeader = uid == leaderId;
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: isLeader ? const BorderSide(color: Colors.amber, width: 2) : BorderSide.none),
                  child: ListTile(
                    onLongPress: () => _setLeader(uid, user['fullName']),
                    leading: CircleAvatar(
                      backgroundColor: isLeader ? Colors.amber : Colors.blue.withOpacity(0.1),
                      backgroundImage: imageUrl.isNotEmpty
                          ? NetworkImage(imageUrl)
                          : null,
                      child: imageUrl.isEmpty
                          ? Icon(isLeader ? Icons.star : Icons.person, color: isLeader ? Colors.white : Colors.blue)
                          : null,
                    ),
                    title: Text(user['fullName'] ?? "Student", style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(user['enrollmentNo'] ?? ""),
                    trailing: IconButton(icon: const Icon(Icons.remove_circle, color: Colors.redAccent), onPressed: () => _removeStudent(uid)),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTasksTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('tasks').where('assignedToGroupId', isEqualTo: widget.group.id).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyState("No tasks assigned", Icons.assignment_late_outlined);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final task = doc.data() as Map<String, dynamic>;
            final progress = (task['progress'] ?? 0.0).toDouble();
            final status = task['status'] ?? 'todo';
            final deadline = (task['deadline'] as Timestamp).toDate();
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(task['title'] ?? "Untitled", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))), _statusBadge(status)]),
                    const SizedBox(height: 8),
                    Text(task['description'] ?? "", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const Divider(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [const Icon(Icons.calendar_month, size: 16, color: Colors.redAccent), const SizedBox(width: 4), Text(DateFormat('dd MMM').format(deadline), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]), Text("${(progress * 100).toInt()}% Done", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue))]),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], color: _getStatusColor(status), minHeight: 6),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    Color color = _getStatusColor(status);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)));
  }

  Color _getStatusColor(String status) {
    if (status == 'done') return Colors.green;
    if (status == 'progress') return Colors.blue;
    return Colors.orange;
  }

  Widget _emptyState(String msg, IconData icon) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 60, color: Colors.grey[200]), const SizedBox(height: 12), Text(msg, style: const TextStyle(color: Colors.grey, fontSize: 16))]));
  }
}
