import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_details_screen.dart';

class StudentListScreen extends StatefulWidget {
  final String department;

  const StudentListScreen({super.key, this.department = "IoT"});

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

          /// Search Bar
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

          /// Firebase Student List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("students")
                  .snapshots(),
              builder: (context, snapshot){

                if(snapshot.connectionState == ConnectionState.waiting){
                  return const Center(child: CircularProgressIndicator());
                }

                if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
                  return const Center(child: Text("No students found"));
                }

                final students = snapshot.data!.docs;

                final filteredStudents = students.where((doc){

                  final data = doc.data() as Map<String,dynamic>;

                  final name = (data['name'] ?? "").toString().toLowerCase();
                  final roll = (data['rollNumber'] ?? "").toString();

                  return name.contains(searchQuery) ||
                         roll.contains(searchQuery);

                }).toList();

                return ListView.builder(
                  itemCount: filteredStudents.length,
                  itemBuilder: (context,index){

                    final data = filteredStudents[index].data() as Map<String,dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal:12,vertical:6),
                      child: ListTile(

                        leading: CircleAvatar(
  child: Text(
    (data['name'] ?? "S").toString().isNotEmpty
        ? data['name'].toString()[0]
        : "S",
  ),
),
                        title: Text(data['name'] ?? "Student"),

                        subtitle: Text("Roll No: ${data['rollNumber'] ?? "-"}"),

                        trailing: const Icon(Icons.arrow_forward_ios,size:16),

                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentDetailsScreen(student: data),
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