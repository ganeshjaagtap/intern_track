import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectStudentScreen extends StatefulWidget {
  const SelectStudentScreen({super.key});

  @override
  State<SelectStudentScreen> createState() => _SelectStudentScreenState();
}

class _SelectStudentScreenState extends State<SelectStudentScreen> {
  String searchQuery = "";
  final String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";
  String? facultyShortId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFacultyId();
  }

  Future<void> _fetchFacultyId() async {
    final doc = await FirebaseFirestore.instance.collection('user').doc(currentUid).get();
    if (doc.exists) {
      setState(() {
        facultyShortId = doc.data()?['facultyId'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assign Student"), backgroundColor: const Color(0xFF6EA8DC)),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  decoration: InputDecoration(hintText: "Search Name/Enrollment", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('user')
                      .where('role', isEqualTo: 'student')
                      .where('facultyId', isEqualTo: facultyShortId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    
                    final students = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return (data['fullName'] ?? "").toString().toLowerCase().contains(searchQuery) ||
                             (data['enrollmentNo'] ?? "").toString().contains(searchQuery);
                    }).toList();

                    return ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final doc = students[index];
                        final data = doc.data() as Map<String, dynamic>;
                        
                        // Check if student is already in a group via their own profile
                        final bool isTaken = data.containsKey('assignedGroupId');

                        return ListTile(
                          title: Text(data['fullName'] ?? ""),
                          subtitle: Text("Enrollment: ${data['enrollmentNo']}"),
                          trailing: isTaken 
                              ? const Text("Occupied", style: TextStyle(color: Colors.red)) 
                              : const Icon(Icons.add_circle, color: Colors.green),
                          onTap: isTaken ? null : () => Navigator.pop(context, {'uid': doc.id, 'name': data['fullName']}),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
    );
  }
}