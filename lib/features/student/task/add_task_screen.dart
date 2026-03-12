import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final Color coolSky = const Color(0xFF60B5FF);
  final Color jasmine = const Color(0xFFFFE588);
  final Color aquamarine = const Color(0xFF5EF2D5);
  final Color tangerine = const Color(0xFFF79D65);

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime? selectedDeadline;
  double progress = 0;
  String? selectedGroupId;
  bool isSubmitting = false;

  Future<void> pickDeadline() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => selectedDeadline = picked);
  }

  Future<void> saveTaskToFirebase() async {
    if (titleController.text.isEmpty || selectedGroupId == null || selectedDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and select a group")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final String facultyUid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('tasks').add({
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'deadline': Timestamp.fromDate(selectedDeadline!),
        'progress': progress / 100, // Store as 0.0 to 1.0
        'assignedToGroupId': selectedGroupId,
        'createdBy': facultyUid,
        'status': 'todo', // Default status
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text("Assign Group Task"), backgroundColor: coolSky),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              /// 🔹 GROUP SELECTOR (Only groups created by this mentor)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .where('createdBy', isEqualTo: currentUid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  var groups = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Select Project Group",
                      filled: true,
                      fillColor: jasmine.withOpacity(0.2),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    value: selectedGroupId,
                    items: groups.map((g) {
                      return DropdownMenuItem(value: g.id, child: Text(g['groupName']));
                    }).toList(),
                    onChanged: (val) => setState(() => selectedGroupId = val),
                  );
                },
              ),
              const SizedBox(height: 18),
              _inputField("Task Title", titleController),
              const SizedBox(height: 18),
              _inputField("Description", descriptionController, maxLines: 3),
              const SizedBox(height: 18),
              _deadlinePicker(),
              const SizedBox(height: 18),
              _progressSelector(),
              const SizedBox(height: 30),
              isSubmitting 
                  ? const CircularProgressIndicator() 
                  : _saveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: coolSky)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: jasmine.withOpacity(0.1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _deadlinePicker() {
    return InkWell(
      onTap: pickDeadline,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: tangerine.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: tangerine),
            const SizedBox(width: 10),
            Text(selectedDeadline == null ? "Select Deadline" : DateFormat('dd MMM yyyy').format(selectedDeadline!)),
          ],
        ),
      ),
    );
  }

  Widget _progressSelector() {
    return Column(
      children: [
        Text("Initial Progress: ${progress.toInt()}%", style: TextStyle(color: aquamarine, fontWeight: FontWeight.bold)),
        Slider(
          value: progress,
          min: 0, max: 100, divisions: 10,
          onChanged: (v) => setState(() => progress = v),
          activeColor: aquamarine,
        ),
      ],
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: coolSky, padding: const EdgeInsets.all(16)),
        onPressed: saveTaskToFirebase,
        child: const Text("Assign Task", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }
}