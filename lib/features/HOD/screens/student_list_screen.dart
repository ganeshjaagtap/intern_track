import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_details_screen.dart';

class StudentListScreen extends StatefulWidget {
  final String department;

  const StudentListScreen({super.key, this.department = "IT"});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.department} Students"),
      ),

      body: Column(
        children: [

          const SizedBox(height: 10),

          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search student...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              onChanged: (value){
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          /// STUDENT LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(

              stream: FirebaseFirestore.instance
                  .collection("user")
                  .where("role", isEqualTo: "student")
                  //.where("dept", isEqualTo: widget.department)
                  .snapshots(),

              builder: (context, snapshot){

                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }

                if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
                  return const Center(child: Text("No students found"));
                }

                final students = snapshot.data!.docs;

                /// SEARCH FILTER
                final filteredStudents = students.where((doc){

                  final data = doc.data() as Map<String,dynamic>;

                  final name = (data["fullName"] ?? "")
                      .toString()
                      .toLowerCase();

                  final enrollment = (data["enrollmentNo"] ?? "")
                      .toString()
                      .toLowerCase();

                  return name.contains(searchQuery) ||
                      enrollment.contains(searchQuery);

                }).toList();

                if(filteredStudents.isEmpty){
                  return const Center(child: Text("No matching student"));
                }

                return ListView.builder(

                  itemCount: filteredStudents.length,

                  itemBuilder: (context,index){

                    final data = filteredStudents[index].data()
                        as Map<String,dynamic>;

                    final name = data["fullName"] ?? "Student";
                    final imageUrl = (data["profileImageUrl"] ?? "").toString();

                    return Card(

                      margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6
                      ),

                      child: ListTile(

                        leading: CircleAvatar(
                          backgroundImage: imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null,
                          child: Text(
                            imageUrl.isEmpty && name.toString().isNotEmpty
                                ? name.toString()[0].toUpperCase()
                                : imageUrl.isEmpty
                                    ? "S"
                                    : "",
                          ),
                        ),

                        title: Text(name),

                        subtitle: Text(
                          "Enrollment No: ${data["enrollmentNo"] ?? "-"}",
                        ),

                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                        ),

                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_)=>StudentDetailsScreen(
                                student: data,
                              ),
                            ),
                          );
                        },
                      ),
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
