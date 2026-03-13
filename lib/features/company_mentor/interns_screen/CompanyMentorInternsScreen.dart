import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bottom_bar/company_mentor_bottom_bar.dart';
import 'InternDetailsScreen.dart';

class CompanyMentorInternsScreen extends StatefulWidget {
  const CompanyMentorInternsScreen({super.key});

  @override
  State<CompanyMentorInternsScreen> createState() => _CompanyMentorInternsScreenState();
}

class _CompanyMentorInternsScreenState extends State<CompanyMentorInternsScreen> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final String currentAuthUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5F9ED6),
        title: const Text("My Interns", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        // 1. Get the current Mentor's document to find their "mentorId" (e.g., "003")
        future: FirebaseFirestore.instance.collection('user').doc(currentAuthUid).get(),
        builder: (context, mentorSnapshot) {
          if (mentorSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!mentorSnapshot.hasData || !mentorSnapshot.data!.exists) {
            return const Center(child: Text("Mentor profile not found."));
          }

          final mentorData = mentorSnapshot.data!.data() as Map<String, dynamic>;
          
          // ✅ This is the value "003" from your mentor profile
          final String mentorProfileId = mentorData['mentorId']?.toString() ?? "";

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Intern Directory", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                TextField(
                  onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "Search intern...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    // ✅ COMPARISON: student.companyMentorId == mentor.mentorId
                    stream: FirebaseFirestore.instance
                        .collection('user')
                        .where('role', isEqualTo: 'student')
                        .where('companyMentorId', isEqualTo: mentorProfileId) 
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // DEBUG: Open your console to see if the IDs match
                      print("DEBUG: Searching students with companyMentorId: '$mentorProfileId'");
                      if (snapshot.hasData) {
                        print("DEBUG: Found ${snapshot.data!.docs.length} students");
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text("No interns found assigned to Mentor ID: $mentorProfileId"),
                        );
                      }

                      final docs = snapshot.data!.docs.where((doc) {
                        final name = (doc['fullName'] ?? '').toString().toLowerCase();
                        return name.contains(searchQuery);
                      }).toList();

                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          return ListTile(
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => InternDetailsScreen(studentData: data),
                            )),
                            leading: CircleAvatar(child: Text(data['fullName']?[0] ?? "?")),
                            title: Text(data['fullName'] ?? "Unnamed"),
                            subtitle: Text(data['college_name'] ?? "N/A"),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CompanyMentorBottomBar(currentIndex: 1),
    );
  }
}