import 'package:flutter/material.dart';
import '../../../models/student_draft.dart';

class MentorInfoScreen extends StatefulWidget {
  const MentorInfoScreen({super.key});

  @override
  State<MentorInfoScreen> createState() => _MentorInfoScreenState();
}

class _MentorInfoScreenState extends State<MentorInfoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final _formKey = GlobalKey<FormState>();
  final Color primaryBlue = const Color(0xFF1976D2);

  // Controllers (prefilled)
  final TextEditingController mentorNameController =
      TextEditingController(text: StudentDraft.mentorName);
  final TextEditingController mentorMobileController =
      TextEditingController(text: StudentDraft.mentorMobile);

  String feedbackStatus =
      StudentDraft.mentorFeedbackStatus ?? "Pending";

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// SAVE INTO DRAFT
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      StudentDraft.mentorName = mentorNameController.text.trim();
      StudentDraft.mentorMobile = mentorMobileController.text.trim();
      StudentDraft.mentorFeedbackStatus = feedbackStatus;

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

                      Icon(Icons.person_outline,
                          size: 60, color: primaryBlue),
                      const SizedBox(height: 10),
                      Text(
                        "Mentor Information",
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
                                "Mentor Name",
                                mentorNameController,
                                Icons.person,
                                validator: (v) =>
                                    v!.isEmpty ? "Required" : null,
                              ),
                              _inputField(
                                "Mentor Mobile Number",
                                mentorMobileController,
                                Icons.phone,
                                keyboard: TextInputType.phone,
                                validator: _validateMobile,
                              ),

                              DropdownButtonFormField<String>(
                                value: feedbackStatus,
                                items: ["Pending", "Completed", "Reviewed"]
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => feedbackStatus = v!),
                                decoration: InputDecoration(
                                  labelText: "Mentor Feedback Status",
                                  filled: true,
                                  fillColor: Colors.white,
                                  prefixIcon: Icon(Icons.feedback,
                                      color: primaryBlue),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _saveForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryBlue,
                                    padding:
                                        const EdgeInsets.symmetric(
                                            vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "Save & Go Back",
                                    style:
                                        TextStyle(color: Colors.black),
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
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
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

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) return "Required";
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return "Enter 10-digit mobile number";
    }
    return null;
  }
}
