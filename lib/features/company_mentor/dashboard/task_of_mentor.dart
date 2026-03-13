import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TaskOfMentorScreen extends StatefulWidget {
  const TaskOfMentorScreen({super.key});

  @override
  State<TaskOfMentorScreen> createState() => _TaskOfMentorScreenState();
}

class _TaskOfMentorScreenState extends State<TaskOfMentorScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedInternId;
  String? _selectedInternName;
  bool _isUploading = false;
  String? _mentorProfileId;

  @override
  void initState() {
    super.initState();
    _loadMentorId();
  }

  Future<void> _loadMentorId() async {
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('user').doc(uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _mentorProfileId = doc['mentorId']?.toString() ?? "";
        });
      }
    } catch (e) {
      if (mounted) setState(() => _mentorProfileId = "");
    }
  }

  Stream<QuerySnapshot> _getInternsStream() {
    if (_mentorProfileId == null || _mentorProfileId!.isEmpty) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('user')
        .where('role', isEqualTo: 'student')
        .where('companyMentorId', isEqualTo: _mentorProfileId)
        .snapshots();
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedInternId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final String currentMentorUid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('tasks').add({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'deadline': Timestamp.fromDate(_selectedDate!),
        'assignedToStudentId': _selectedInternId,
        'assignedByMentorId': currentMentorUid,
        'status': 'todo',
        'createdAt': FieldValue.serverTimestamp(),
        'studentName': _selectedInternName,
        'type': 'company_task'
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task assigned successfully!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_mentorProfileId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Modern light grey background
      appBar: AppBar(
        title: const Text("Create Task", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF5F9ED6),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Blue Header Curve
                  Container(
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5F9ED6),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Task Content"),
                          _buildCard([
                            _buildTextField(
                              controller: _titleController,
                              label: "Title",
                              hint: "e.g. Design Login UI",
                              icon: Icons.title,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _descController,
                              label: "Description",
                              hint: "Explain the task requirements...",
                              icon: Icons.description_outlined,
                              maxLines: 3,
                            ),
                          ]),
                          const SizedBox(height: 24),
                          _buildSectionTitle("Assign & Schedule"),
                          _buildCard([
                            _buildInternDropdown(),
                            const Divider(height: 32),
                            _buildDeadlinePicker(),
                          ]),
                          const SizedBox(height: 40),
                          _buildSubmitButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Helper Widgets for UI
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF5F9ED6), size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          validator: (v) => v!.isEmpty ? "This field is required" : null,
        ),
      ],
    );
  }

  Widget _buildInternDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getInternsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();
        var docs = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Intern", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text("Choose an intern"),
                icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Color(0xFF5F9ED6)),
                value: _selectedInternId,
                items: docs.map((d) {
                  return DropdownMenuItem(
                    value: d.id,
                    child: Text(d['fullName'] ?? "Unnamed"),
                    onTap: () => _selectedInternName = d['fullName'],
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedInternId = v),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeadlinePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Deadline", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            _selectedDate == null ? "Set due date" : DateFormat('EEEE, dd MMM').format(_selectedDate!),
            style: TextStyle(color: _selectedDate == null ? Colors.grey : Colors.black87),
          ),
          trailing: const Icon(Icons.calendar_month, color: Color(0xFF5F9ED6)),
          onTap: () async {
            DateTime? p = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 1)),
              firstDate: DateTime.now(),
              lastDate: DateTime(2027),
            );
            if (p != null) setState(() => _selectedDate = p);
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [Color(0xFF5F9ED6), Color(0xFF4A89C2)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5F9ED6).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _saveTask,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text(
          "ASSIGN TASK",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1),
        ),
      ),
    );
  }
}