import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({Key? key}) : super(key: key);

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {

  final _formKey = GlobalKey<FormState>();

  String reportType = "Weekly";
  String selectedWeek = "Week 1";

  DateTime? fromDate;
  DateTime? toDate;

  PlatformFile? selectedFile;

  bool isSubmitting = false;

  Map<String,dynamic>? studentData;
  String? companyMentorName;
  String? facultyMentorName;

  final TextEditingController summaryCtrl = TextEditingController();
  final TextEditingController workDoneCtrl = TextEditingController();
  final TextEditingController learningCtrl = TextEditingController();
  final TextEditingController issuesCtrl = TextEditingController();
  final TextEditingController nextPlanCtrl = TextEditingController();

  final List<String> weeks = [
    "Week 1","Week 2","Week 3","Week 4","Week 5","Week 6",
    "Week 7","Week 8","Week 9","Week 10","Week 11","Week 12",
    "Week 13","Week 14","Week 15","Week 16"
  ];

  @override
  void initState() {
    super.initState();
    loadStudentData();
  }

  @override
  void dispose() {
    summaryCtrl.dispose();
    workDoneCtrl.dispose();
    learningCtrl.dispose();
    issuesCtrl.dispose();
    nextPlanCtrl.dispose();
    super.dispose();
  }

  /// 🔹 Load student info and mentor data from Firestore
  Future<void> loadStudentData() async {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("user")
        .doc(uid)
        .get();

    setState(() {
      studentData = doc.data() ?? {};
      
      // Get mentor names from Firestore using correct field names
      companyMentorName = studentData?["companyMentor"] ?? "Not assigned";
      facultyMentorName = studentData?["collegeMentor"] ?? "Not assigned";
    });
  }

  Future<void> _pickDate(bool isFrom) async {

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  Future<void> _pickFile() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf','doc','docx','jpg','png'],
    );

    if (result != null) {

      setState(() {
        selectedFile = result.files.first;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selected: ${selectedFile!.name}")),
      );
    }
  }

  /// 🔹 Submit report to Firestore
  Future<void> _submitReport() async {

    if (!_formKey.currentState!.validate()) return;

    if (fromDate == null || toDate == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date range")),
      );

      return;
    }

    setState(() => isSubmitting = true);

    try {

      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection("reports").add({

        "studentId": uid,
        "studentName": studentData?["fullName"] ?? "",
        "enrollmentNo": studentData?["enrollmentNo"] ?? "",
        "department": studentData?["dept"] ?? "",
        "role": studentData?["internshipRole"] ?? "",

        "companyMentorName": companyMentorName,
        "facultyMentorName": facultyMentorName,

        "title": "$selectedWeek Progress Report",
        "reportType": reportType,
        "week": selectedWeek,

        "period":
            "${fromDate!.day}/${fromDate!.month}/${fromDate!.year} - "
            "${toDate!.day}/${toDate!.month}/${toDate!.year}",

        "summary": summaryCtrl.text,
        "workDone": workDoneCtrl.text,
        "learning": learningCtrl.text,
        "issues": issuesCtrl.text,
        "nextPlan": nextPlanCtrl.text,

        "fileName": selectedFile?.name ?? "",

        "status": "pending",

        "createdAt": Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report submitted successfully")),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF4F6F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        title: const Text("SUBMIT REPORT"),
      ),

      body: studentData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              /// STUDENT INFO
              _sectionTitle("Student Information"),

              _card(
                Column(
                  children: [

                    _infoRow("Name", studentData!["fullName"] ?? "-"),
                    _infoRow("Department", studentData!["dept"] ?? "-"),
                    _infoRow("Role", studentData!["internshipRole"] ?? "-"),
                    _infoRow("Enrollment No", studentData!["enrollmentNo"] ?? "-"),

                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// MENTOR INFORMATION
              _sectionTitle("Mentor Information"),

              _card(
                Column(
                  children: [

                    _infoRow("Faculty Mentor", facultyMentorName ?? "Not assigned"),

                    const SizedBox(height: 8),

                    _infoRow("Company Mentor", companyMentorName ?? "Not assigned"),

                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// REPORT DETAILS
              _sectionTitle("Report Details"),

              _card(
                Column(
                  children: [

                    DropdownButtonFormField(
                      value: reportType,
                      items: const [
                        DropdownMenuItem(value: "Weekly", child: Text("Weekly Report")),
                        DropdownMenuItem(value: "Monthly", child: Text("Monthly Report")),
                      ],
                      onChanged:(v){
                        setState(() => reportType = v!);
                      },
                      decoration: const InputDecoration(
                        labelText:"Report Type",
                        border:OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height:12),

                    if(reportType=="Weekly")

                      DropdownButtonFormField(
                        value:selectedWeek,
                        items:weeks.map((w){
                          return DropdownMenuItem(
                            value:w,
                            child:Text(w),
                          );
                        }).toList(),
                        onChanged:(v){
                          setState(()=>selectedWeek=v!);
                        },
                        decoration: const InputDecoration(
                          labelText:"Week",
                          border:OutlineInputBorder(),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height:20),

              /// DATE RANGE
              _sectionTitle("Date Range"),

              _card(
                Row(
                  children: [

                    Expanded(
                      child:_dateField(
                        label:"From Date",
                        value:fromDate,
                        onTap:()=>_pickDate(true),
                      ),
                    ),

                    const SizedBox(width:12),

                    Expanded(
                      child:_dateField(
                        label:"To Date",
                        value:toDate,
                        onTap:()=>_pickDate(false),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height:20),

              /// REPORT CONTENT
              _sectionTitle("Report Content"),

              _card(
                Column(
                  children: [

                    _textField(summaryCtrl,"Summary","Brief summary"),

                    const SizedBox(height:10),

                    _textField(workDoneCtrl,"Work Done","Tasks completed",4),

                    const SizedBox(height:10),

                    _textField(learningCtrl,"Learning Outcomes","What you learned",3),

                    const SizedBox(height:10),

                    _textField(issuesCtrl,"Issues","Problems faced",3),

                    const SizedBox(height:10),

                    _textField(nextPlanCtrl,"Next Week Plan","Next tasks",3),

                  ],
                ),
              ),

              const SizedBox(height:20),

              /// ATTACHMENT
              _sectionTitle("Attachment"),

              _card(
                Column(
                  children: [

                    InkWell(
                      onTap:_pickFile,
                      child:Container(
                        width:double.infinity,
                        padding: const EdgeInsets.symmetric(vertical:25),
                        decoration:BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border:Border.all(color: Colors.blue),
                        ),
                        child: const Column(
                          children:[
                            Icon(Icons.upload_file,color:Colors.blue,size:40),
                            SizedBox(height:5),
                            Text("Tap to upload file"),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height:10),

                    if(selectedFile!=null)
                      Text(selectedFile!.name),

                  ],
                ),
              ),

              const SizedBox(height:25),

              SizedBox(
                width:double.infinity,
                child:ElevatedButton(
                  style:ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BB6FF),
                    foregroundColor: Colors.white,
                  ),
                  onPressed:isSubmitting ? null : _submitReport,
                  child:isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit Report"),
                ),
              ),

              const SizedBox(height:30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text){
    return Padding(
      padding: const EdgeInsets.only(bottom:8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _card(Widget child){
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

  Widget _dateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }){
    return InkWell(
      onTap:onTap,
      child:InputDecorator(
        decoration:InputDecoration(
          labelText:label,
          border:const OutlineInputBorder(),
        ),
        child:Text(
          value==null
              ?"Select date"
              :"${value.day}/${value.month}/${value.year}",
        ),
      ),
    );
  }

  Widget _textField(
      TextEditingController controller,
      String label,
      String hint,
      [int maxLines = 2]){

    return TextFormField(
      controller:controller,
      maxLines:maxLines,
      validator:(v)=> v==null || v.isEmpty ? "Required field" : null,
      decoration:InputDecoration(
        labelText:label,
        hintText:hint,
        border:const OutlineInputBorder(),
      ),
    );
  }
}

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
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF424242)),
            ),
          ),
        ],
      ),
    );
  }
}