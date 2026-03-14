import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'MentorDetailScreen.dart';

class MentorScreen extends StatefulWidget {
  const MentorScreen({super.key});

  @override
  State<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends State<MentorScreen> {

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {

    const primaryBlue = Color(0xFF64A9F6);
    const bgLight = Color(0xFFF5F7F9);

    return Scaffold(
      backgroundColor: bgLight,

      body: Column(
        children: [

          /// SEARCH BAR
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            decoration: const BoxDecoration(color: primaryBlue),

            child: SafeArea(
              bottom: false,

              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),

                child: TextField(
                  controller: _searchController,

                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },

                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: primaryBlue),
                    hintText: "Search mentor...",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),

          /// TITLE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),

            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),

            child: const Text(
              "Allocated Mentors",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          /// FACULTY LIST
          Expanded(
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseAuth.instance.currentUser == null
                  ? null
                  : FirebaseFirestore.instance
                      .collection('user')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get(),
              builder: (context, hodSnapshot) {
                if (hodSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final hodData = hodSnapshot.data?.data() as Map<String, dynamic>?;
                final hodDept =
                    (hodData?['dept'] ?? "").toString().trim().toLowerCase();

                if (hodDept.isEmpty) {
                  return const Center(child: Text("No mentors found"));
                }

                return StreamBuilder<QuerySnapshot>(

                  stream: FirebaseFirestore.instance
                      .collection('user')
                      .where('role', isEqualTo: 'faculty')
                      .snapshots(),

                  builder: (context, snapshot) {

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No mentors found"));
                    }

                    final mentors = snapshot.data!.docs;

                    final filteredMentors = mentors.where((doc) {

                      final data = doc.data() as Map<String, dynamic>;

                      final name =
                          (data['fullName'] ?? "").toString().toLowerCase();

                      final dept =
                          (data['dept'] ?? "").toString().trim().toLowerCase();

                      return dept == hodDept && name.contains(searchQuery);

                    }).toList();

                    if (filteredMentors.isEmpty) {
                      return const Center(
                        child: Text("No mentors found"),
                      );
                    }

                    return ListView.builder(

                      padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15),

                      itemCount: filteredMentors.length,

                      itemBuilder: (context, index) {

                        final data =
                            filteredMentors[index].data() as Map<String, dynamic>;

                        Map<String, String> mentor = {

                          "name": data['fullName']?.toString() ?? "",
                          "id": data['facultyId']?.toString() ?? "",
                          "dept": data['dept']?.toString() ?? "",
                          "designation": data['designation']?.toString() ?? "",
                          "email": data['email']?.toString() ?? "",
                          "phone": data['phoneNumber']?.toString() ?? "",
                          "totalStudents": "",
                          "companies": "",
                          "img": data['profileImageUrl']?.toString() ?? "",

                        };

                        return _buildMentorCard(mentor, primaryBlue);
                      },
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

  /// MENTOR CARD
  Widget _buildMentorCard(Map<String, String> mentor, Color themeColor) {

    final name = mentor['name'] ?? "";
    final email = mentor['email'] ?? "";
    final img = mentor['img'] ?? "";

    return Container(

      margin: const EdgeInsets.only(bottom: 16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(25),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MentorDetailScreen(mentorData: mentor),
              ),
            );
          },

          child: Padding(
            padding: const EdgeInsets.all(12),

            child: Row(
              children: [

                CircleAvatar(
                  radius: 28,
                  backgroundImage: img.isNotEmpty
                      ? NetworkImage(img)
                      : null,
                  child: img.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
