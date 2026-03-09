import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

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
    "Week 1",
    "Week 2",
    "Week 3",
    "Week 4",
    "Week 5",
    "Week 6",
    "Week 7",
    "Week 8",
    "Week 9",
    "Week 10",
    "Week 11",
    "Week 12",
    "Week 13",
    "Week 14",
    "Week 15",
    "Week 16"
  ];

  Future<void> _pickDate(bool isFrom) async {
    final DateTime? picked = await showDatePicker(
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
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
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

  void _submitReport() {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Report submitted successfully"),
      ),
    );

    Navigator.pop(context);
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Draft saved"),
      ),
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

              /// REPORT TYPE
              _sectionTitle("Report Details"),
              _card(
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: reportType,
                      decoration: const InputDecoration(
                        labelText: "Report Type",
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: "Weekly", child: Text("Weekly Report")),
                        DropdownMenuItem(
                            value: "Monthly", child: Text("Monthly Report")),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => reportType = v);
                      },
                    ),

                    const SizedBox(height: 12),

                    if (reportType == "Weekly")
                      DropdownButtonFormField<String>(
                        value: selectedWeek,
                        decoration: const InputDecoration(
                          labelText: "Week",
                          border: OutlineInputBorder(),
                        ),
                        items: weeks
                            .map((w) => DropdownMenuItem(
                                  value: w,
                                  child: Text(w),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => selectedWeek = v);
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

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
                    const SizedBox(width: 12),
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

              const SizedBox(height: 20),

              /// REPORT CONTENT
              _sectionTitle("Report Content"),
              _card(
                Column(
                  children: [
                    _textField(
                      controller: summaryCtrl,
                      label: "Summary",
                      hint: "Brief summary of the week",
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      controller: workDoneCtrl,
                      label: "Work Done",
                      hint: "Tasks completed during this period",
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      controller: learningCtrl,
                      label: "Learning Outcomes",
                      hint: "What you learned",
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      controller: issuesCtrl,
                      label: "Issues / Challenges",
                      hint: "Problems faced (if any)",
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      controller: nextPlanCtrl,
                      label: "Next Week Plan",
                      hint: "Planned tasks",
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// ATTACHMENTS (IMPROVED UI)
              _sectionTitle("Attachments"),
              _card(
                Column(
                  children: [

                    /// Upload Area
                    InkWell(
                      onTap: _pickFile,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.blue.shade50,
                        ),
                        child: Column(
                          children: const [
                            Icon(Icons.upload_file,
                                size: 40, color: Colors.blue),
                            SizedBox(height: 8),
                            Text(
                              "Tap to upload file",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "PDF, DOC, DOCX, JPG, PNG",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// Selected File Preview
                    if (selectedFile != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.insert_drive_file,
                                color: Colors.blue),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                selectedFile!.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  selectedFile = null;
                                });
                              },
                            )
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// ACTION BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saveDraft,
                      child: const Text("Save Draft"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6BB6FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _submitReport,
                      child: const Text("Submit Report"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _card(Widget child) {
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
  }) {
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

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 2,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (v) =>
          v == null || v.isEmpty ? "This field is required" : null,
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

  const _infoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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