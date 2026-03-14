import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bottom_bar/company_mentor_bottom_bar.dart';

class CompanyMentorPerformanceScreen extends StatefulWidget {
  const CompanyMentorPerformanceScreen({super.key});

  @override
  State<CompanyMentorPerformanceScreen> createState() => _CompanyMentorPerformanceScreenState();
}

class _CompanyMentorPerformanceScreenState extends State<CompanyMentorPerformanceScreen> {
  final String currentMentorUid = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  Widget build(BuildContext context) {
    if (currentMentorUid.isEmpty) {
      return const Scaffold(body: Center(child: Text("User session not found. Please log in.")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5F9ED6),
        title: const Text("Intern Performance", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        // ✅ FIX 1: Use FutureBuilder for the one-time .get() call
        future: FirebaseFirestore.instance.collection('user').doc(currentMentorUid).get(),
        builder: (context, mentorSnap) {
          if (mentorSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!mentorSnap.hasData || !mentorSnap.data!.exists) {
            return const Center(child: Text("Mentor profile not found."));
          }

          final mentorData = mentorSnap.data!.data() as Map<String, dynamic>?;
          final String mentorShortId = mentorData?['mentorId']?.toString() ?? "";

          return StreamBuilder<QuerySnapshot>(
            // ✅ Step 2: Stream interns assigned to this mentor
            stream: FirebaseFirestore.instance
                .collection('user')
                .where('role', isEqualTo: 'student')
                .where('companyMentorId', isEqualTo: mentorShortId)
                .snapshots(),
            builder: (context, studentSnapshot) {
              if (studentSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final students = studentSnapshot.data?.docs ?? [];

              return StreamBuilder<QuerySnapshot>(
                // ✅ Step 3: Stream all tasks assigned by this mentor
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .where('assignedByMentorId', isEqualTo: currentMentorUid)
                    .snapshots(),
                builder: (context, taskSnapshot) {
                  if (taskSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allTasks = taskSnapshot.data?.docs ?? [];
                  
                  // Processing Logic
                  List<Map<String, dynamic>> performanceList = [];
                  double totalProgressSum = 0;

                  for (var studentDoc in students) {
                    try {
                      final sData = studentDoc.data() as Map<String, dynamic>;
                      String studentId = studentDoc.id;

                      // Filter tasks for this specific student
                      var studentTasks = allTasks.where((t) {
                        final tData = t.data() as Map<String, dynamic>;
                        return tData['assignedToStudentId'] == studentId;
                      }).toList();

                      var verifiedTasks = studentTasks.where((t) {
                        final tData = t.data() as Map<String, dynamic>;
                        return tData['status'] == 'verified';
                      }).toList();

                      // ✅ FIX 2: Zero-division guard
                      double progress = studentTasks.isEmpty 
                          ? 0.0 
                          : verifiedTasks.length / studentTasks.length;
                      
                      totalProgressSum += progress;

                      performanceList.add({
                        "name": sData['fullName'] ?? "Unnamed Intern",
                        "college": sData['college_name'] ?? "N/A",
                        "profileImageUrl": sData['profileImageUrl'] ?? "",
                        "progress": progress,
                        "tasks": verifiedTasks.length,
                        "total": studentTasks.length,
                      });
                    } catch (e) {
                      debugPrint("Error processing student row: $e");
                    }
                  }

                  double averageProgress = performanceList.isEmpty ? 0.0 : totalProgressSum / performanceList.length;

                  return _buildMainUI(averageProgress, performanceList);
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CompanyMentorBottomBar(currentIndex: 0),
    );
  }

  // --- UI CONSTRUCTION ---

  Widget _buildMainUI(double avg, List<Map<String, dynamic>> list) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(avg, list.length),
          const SizedBox(height: 25),
          const Text("Intern Progress List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3243))),
          const SizedBox(height: 12),
          if (list.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: Text("No interns found for your ID.")))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) => _buildInternCard(list[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(double avg, int total) {
    return Row(
      children: [
        Expanded(child: _summaryCard("Avg. Success", "${(avg * 100).round()}%", Icons.auto_graph, const Color(0xFFD6E9FF))),
        const SizedBox(width: 12),
        Expanded(child: _summaryCard("My Students", "$total", Icons.face, const Color(0xFFDFF5EA))),
      ],
    );
  }

  Widget _buildInternCard(Map<String, dynamic> intern) {
    double prog = intern['progress'];
    Color progColor = prog < 0.4 ? Colors.red : (prog < 0.7 ? Colors.orange : Colors.green);
    final imageUrl = (intern['profileImageUrl'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: progColor.withOpacity(0.1),
                backgroundImage: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl.isEmpty
                    ? Text(intern['name'][0], style: TextStyle(color: progColor, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(intern['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(intern['college'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ),
              Text("${(prog * 100).round()}%", style: TextStyle(fontWeight: FontWeight.bold, color: progColor, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: prog,
            minHeight: 6,
            backgroundColor: Colors.grey.shade100,
            color: progColor,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${intern['tasks']} / ${intern['total']} Tasks Verified", style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
              if (prog >= 0.8) const Icon(Icons.stars, color: Colors.orange, size: 16),
            ],
          )
        ],
      ),
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.black45),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}
