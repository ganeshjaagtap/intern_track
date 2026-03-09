import 'package:flutter/material.dart';
import '../../../../models/student_draft.dart';

class InternshipDetailsScreen extends StatefulWidget {
  const InternshipDetailsScreen({super.key});

  @override
  State<InternshipDetailsScreen> createState() =>
      _InternshipDetailsScreenState();
}

class _InternshipDetailsScreenState extends State<InternshipDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final _formKey = GlobalKey<FormState>();
  final Color primaryBlue = const Color(0xFF1976D2);

  // Controllers (prefilled)
  final TextEditingController titleController =
      TextEditingController(text: StudentDraft.role);
  final TextEditingController companyController =
      TextEditingController(text: StudentDraft.company);
  final TextEditingController startDateController =
      TextEditingController();
  final TextEditingController endDateController =
      TextEditingController();

  String internshipType = "Paid";
  String mode = "Online";

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _animation = Tween<double>(begin: -200, end: 200).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    // Prefill duration if available
    if (StudentDraft.duration != null) {
      final parts = StudentDraft.duration!.split(" - ");
      if (parts.length == 2) {
        startDateController.text = parts[0];
        endDateController.text = parts[1];
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// SAVE INTO DRAFT
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      StudentDraft.role = titleController.text.trim();
      StudentDraft.company = companyController.text.trim();
      StudentDraft.duration =
          "${startDateController.text} - ${endDateController.text}";

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🔁 BACKGROUND
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_animation.value, 0),
                child: child,
              );
            },
            child: OverflowBox(
              maxWidth: MediaQuery.of(context).size.width * 2,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 2,
                height: MediaQuery.of(context).size.height,
                child: Image.asset(
                  'assets/images/collage_bg.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          /// 🔷 UI
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 50),

                      Icon(Icons.work, size: 60, color: primaryBlue),
                      const SizedBox(height: 10),
                      Text(
                        "Internship Details",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryBlue,
                        ),
                      ),

                      const SizedBox(height: 30),

                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _inputField(
                                "Internship Title",
                                titleController,
                                Icons.assignment,
                                validator: (v) =>
                                    v!.isEmpty ? "Required" : null,
                              ),
                              _inputField(
                                "Company Name",
                                companyController,
                                Icons.business,
                                validator: (v) =>
                                    v!.isEmpty ? "Required" : null,
                              ),

                              _inputField(
                                "Start Date",
                                startDateController,
                                Icons.date_range,
                                readOnly: true,
                                onTap: () => _pickDate(true),
                                validator: (v) =>
                                    v!.isEmpty ? "Select start date" : null,
                              ),
                              _inputField(
                                "End Date",
                                endDateController,
                                Icons.event,
                                readOnly: true,
                                onTap: () => _pickDate(false),
                                validator: _validateEndDate,
                              ),

                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _saveForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryBlue,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "Save & Go Back",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: primaryBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  void _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      if (isStart) {
        startDate = picked;
        startDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      } else {
        endDate = picked;
        endDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      }
    }
  }

  String? _validateEndDate(String? value) {
    if (value == null || value.isEmpty) return "Select end date";
    if (startDate != null && endDate != null) {
      if (endDate!.isBefore(startDate!)) {
        return "End date must be after start date";
      }
    }
    return null;
  }
}
