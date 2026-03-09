import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  /// 🔹 SUBMIT REPORT → SAVE TO FIRESTORE
  Future<void> _submitReport() async {

    if (!_formKey.currentState!.validate()) return;

    if (fromDate == null || toDate == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date range")),
      );

      return;
    }

    try {

      await FirebaseFirestore.instance.collection("reports").add({

        "title": "$selectedWeek Progress Report",

        "reportType": reportType,
        "week": selectedWeek,

        "period":
            "${fromDate!.day}/${fromDate!.month}/${fromDate!.year} - "
            "${toDate!.day}/${toDate!.month}/${toDate!.year}",

        "studentName": "Abhijeet Apare",
        "department": "Computer Science",
        "mentor": "Dr. Sharma",

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
  }

  void _saveDraft() {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Draft saved")),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF4F6F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        title: const Text("SUBMIT REPORT"),
      ),

      body: SingleChildScrollView(
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
                  children: const [
                    _infoRow("Name", "Abhijeet Apare"),
                    _infoRow("Department", "Computer Science"),
                    _infoRow("Role", "Flutter Developer Intern"),
                    _infoRow("Mentor", "Dr. Sharma"),
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

                        DropdownMenuItem(
                          value: "Weekly",
                          child: Text("Weekly Report"),
                        ),

                        DropdownMenuItem(
                          value: "Monthly",
                          child: Text("Monthly Report"),
                        ),
                      ],

                      onChanged: (v){
                        setState(() {
                          reportType = v!;
                        });
                      },

                      decoration: const InputDecoration(
                        labelText: "Report Type",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height:12),

                    if(reportType=="Weekly")

                      DropdownButtonFormField(
                        value: selectedWeek,

                        items: weeks.map((w){

                          return DropdownMenuItem(
                            value: w,
                            child: Text(w),
                          );

                        }).toList(),

                        onChanged:(v){
                          setState(() {
                            selectedWeek=v!;
                          });
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
                      child: _dateField(
                        label: "From Date",
                        value: fromDate,
                        onTap: () => _pickDate(true),
                      ),
                    ),

                    const SizedBox(width:12),

                    Expanded(
                      child: _dateField(
                        label: "To Date",
                        value: toDate,
                        onTap: () => _pickDate(false),
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

                      child: Container(
                        width:double.infinity,
                        padding: const EdgeInsets.symmetric(vertical:25),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue),
                        ),

                        child: const Column(
                          children: [

                            Icon(Icons.upload_file,
                                color: Colors.blue,
                                size: 40),

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

              Row(
                children: [

                  Expanded(
                    child: OutlinedButton(
                      onPressed:_saveDraft,
                      child: const Text("Save Draft"),
                    ),
                  ),

                  const SizedBox(width:12),

                  Expanded(
                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6BB6FF),
                        foregroundColor: Colors.white,
                      ),

                      onPressed:_submitReport,

                      child: const Text("Submit Report"),
                    ),
                  ),
                ],
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

      onTap: onTap,

      child: InputDecorator(

        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),

        child: Text(
          value == null
              ? "Select date"
              : "${value.day}/${value.month}/${value.year}",
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

      controller: controller,

      maxLines: maxLines,

      validator:(v)=> v==null || v.isEmpty ? "Required field" : null,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
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