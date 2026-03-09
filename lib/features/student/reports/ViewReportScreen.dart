import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewReportScreen extends StatelessWidget {

  final String reportId;

  const ViewReportScreen({
    Key? key,
    required this.reportId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF4F6F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        title: const Text("VIEW REPORT"),
      ),

      body: FutureBuilder<DocumentSnapshot>(

        future: FirebaseFirestore.instance
            .collection("reports")
            .doc(reportId)
            .get(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Report not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                /// HEADER
                _sectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        data["title"] ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height:6),

                      Text(
                        data["period"] ?? "",
                        style: const TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height:6),

                      Row(
                        children: [

                          const Icon(Icons.person,size:16,color:Colors.grey),

                          const SizedBox(width:6),

                          Text(
                            "Mentor: ${data["mentor"] ?? ""}",
                            style: const TextStyle(color: Colors.grey),
                          ),

                          const Spacer(),

                          _statusChip(
                            data["status"] ?? "pending",
                            _statusColor(data["status"]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height:16),

                /// STUDENT INFO
                _sectionTitle("Student Information"),

                _sectionCard(
                  child: Column(
                    children: [
                      _infoRow("Name", data["studentName"] ?? ""),
                      _infoRow("Department", data["department"] ?? ""),
                    ],
                  ),
                ),

                const SizedBox(height:20),

                /// SUMMARY
                _sectionTitle("Summary"),

                _sectionCard(
                  child: Text(data["summary"] ?? ""),
                ),

                const SizedBox(height:20),

                /// WORK DONE
                _sectionTitle("Work Done"),

                _sectionCard(
                  child: Text(data["workDone"] ?? ""),
                ),

                const SizedBox(height:20),

                /// LEARNING
                _sectionTitle("Learning Outcomes"),

                _sectionCard(
                  child: Text(data["learning"] ?? ""),
                ),

                const SizedBox(height:20),

                /// ISSUES
                _sectionTitle("Issues / Challenges"),

                _sectionCard(
                  child: Text(data["issues"] ?? ""),
                ),

                const SizedBox(height:20),

                /// NEXT PLAN
                _sectionTitle("Next Week Plan"),

                _sectionCard(
                  child: Text(data["nextPlan"] ?? ""),
                ),

                const SizedBox(height:20),

                /// DOWNLOAD FILE
                if (data["fileUrl"] != null)

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6BB6FF),
                        foregroundColor: Colors.white,
                      ),

                      onPressed: () {

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Open file using browser"),
                          ),
                        );
                      },

                      icon: const Icon(Icons.download),
                      label: const Text("Download Report"),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(String status){

    if(status=="approved") return Colors.green;
    if(status=="pending") return Colors.orange;

    return Colors.blue;
  }

  Widget _sectionTitle(String text){
    return Padding(
      padding: const EdgeInsets.only(bottom:8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize:15,
          fontWeight:FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}){
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _statusChip(String text, Color color){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal:10,vertical:4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize:12,
          color:color,
          fontWeight:FontWeight.bold,
        ),
      ),
    );
  }
}

/// INFO ROW
class _infoRow extends StatelessWidget {

  final String label;
  final String value;

  const _infoRow(this.label,this.value);

  @override
  Widget build(BuildContext context){

    return Padding(
      padding: const EdgeInsets.symmetric(vertical:6),

      child: Row(
        children: [

          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}