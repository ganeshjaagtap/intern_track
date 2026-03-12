import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({super.key});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final Color coolSky = const Color(0xFF60B5FF);
  final Color aquamarine = const Color(0xFF5EF2D5);
  final Color jasmine = const Color(0xFFFFE588);

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // We store selected Group IDs here
  List<String> selectedGroupIds = [];
  DateTime? deadline;
  bool isSubmitting = false;

  /// 🔹 FIREBASE: Assign Task Logic
  Future<void> assignTask() async {
    if (titleController.text.isEmpty || selectedGroupIds.isEmpty || deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and select at least one group")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final String facultyUid = FirebaseAuth.instance.currentUser!.uid;
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      for (String groupId in selectedGroupIds) {
        DocumentReference taskRef = FirebaseFirestore.instance.collection('tasks').doc();
        batch.set(taskRef, {
          'title': titleController.text.trim(),
          'description': descriptionController.text.trim(),
          'deadline': Timestamp.fromDate(deadline!),
          'assignedToGroupId': groupId,
          'createdBy': facultyUid,
          'status': 'todo',
          'progress': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error assigning task: $e");
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Future<void> pickDeadline() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => deadline = picked);
  }

  /// 🔹 DYNAMIC GROUP CARD
  Widget groupCard(String groupId, String groupName) {
    bool isSelected = selectedGroupIds.contains(groupId);

    return GestureDetector(
      onTap: () {
        setState(() {
          isSelected ? selectedGroupIds.remove(groupId) : selectedGroupIds.add(groupId);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? aquamarine.withOpacity(.25) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? aquamarine : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: coolSky,
              child: const Icon(Icons.group, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                groupName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? aquamarine : Colors.grey,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: coolSky,
        title: const Text("Assign Task"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField("Task Title", titleController),
            const SizedBox(height: 16),
            _inputField("Description", descriptionController, maxLines: 3),
            const SizedBox(height: 16),
            
            const Text("Select Groups", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            /// 🔹 FETCH GROUPS FROM FIREBASE
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .where('createdBy', isEqualTo: currentUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.docs.isEmpty) return const Text("No groups found. Create a group first.");

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var group = snapshot.data!.docs[index];
                    return groupCard(group.id, group['groupName']);
                  },
                );
              },
            ),

            const SizedBox(height: 16),
            const Text("Deadline", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _deadlinePicker(),
            const SizedBox(height: 24),
            
            isSubmitting 
              ? const Center(child: CircularProgressIndicator()) 
              : _assignButton(),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: jasmine.withOpacity(.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _deadlinePicker() {
    return GestureDetector(
      onTap: pickDeadline,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: coolSky.withOpacity(.15), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: coolSky),
            const SizedBox(width: 10),
            Text(deadline == null ? "Select Deadline" : DateFormat("dd MMM yyyy").format(deadline!)),
          ],
        ),
      ),
    );
  }

  Widget _assignButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: coolSky,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: assignTask,
        child: const Text("Assign Task", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}