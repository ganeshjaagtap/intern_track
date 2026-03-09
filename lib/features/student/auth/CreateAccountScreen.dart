import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/faculty/dashboard/MentorInfoScreen.dart';
import 'package:flutter_application_2/features/interns/screens/InternshipDetailsScreen.dart';

// Import all completed screens
import '../screens/BasicInfoScreen.dart';
import '../screens/AcademicDetailsScreen.dart';
import '../screens/SkillsInterestsScreen.dart';

// Placeholder import (you will create this later)
import 'SetLoginCredentialsScreen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final Color primaryBlue = const Color(0xFF1976D2);

  // Completion flags
  bool basicDone = false;
  bool academicDone = false;
  bool internshipDone = false;
  bool mentorDone = false;
  bool skillsDone = false;

  bool get allDone =>
      basicDone &&
      academicDone &&
      internshipDone &&
      mentorDone &&
      skillsDone;

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
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    Icon(Icons.person_add,
                        size: 70, color: primaryBlue),
                    const SizedBox(height: 10),
                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// 🔵 BLOCK CARD
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
                            _block(
                              "1. Basic Information",
                              Icons.person,
                              basicDone,
                              () async {
                                final res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const BasicInfoScreen(),
                                  ),
                                );
                                if (res == true) {
                                  setState(() => basicDone = true);
                                }
                              },
                            ),
                            _block(
                              "2. Academic Details",
                              Icons.school,
                              academicDone,
                              () async {
                                final res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AcademicDetailsScreen(),
                                  ),
                                );
                                if (res == true) {
                                  setState(() => academicDone = true);
                                }
                              },
                            ),
                            _block(
                              "3. Internship Details",
                              Icons.work,
                              internshipDone,
                              () async {
                                final res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const InternshipDetailsScreen(),
                                  ),
                                );
                                if (res == true) {
                                  setState(() => internshipDone = true);
                                }
                              },
                            ),
                            _block(
                              "4. Mentor Information",
                              Icons.person_outline,
                              mentorDone,
                              () async {
                                final res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const MentorInfoScreen(),
                                  ),
                                );
                                if (res == true) {
                                  setState(() => mentorDone = true);
                                }
                              },
                            ),
                            _block(
                              "5. Skills & Interests",
                              Icons.star,
                              skillsDone,
                              () async {
                                final res = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const SkillsInterestsScreen(),
                                  ),
                                );
                                if (res == true) {
                                  setState(() => skillsDone = true);
                                }
                              },
                            ),

                            const SizedBox(height: 20),

                            /// ✅ FINAL SIGN-IN BUTTON
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: allDone
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const SetLoginCredentialsScreen(),
                                          ),
                                        );
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  disabledBackgroundColor:
                                      Colors.grey.shade400,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Proceed to Set Login ID & Password",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔙 BACK TO LOGIN
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          color: primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 BLOCK TILE
  Widget _block(
    String title,
    IconData icon,
    bool completed,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              children: [
                Icon(icon, color: primaryBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                completed
                    ? const Icon(Icons.check_circle,
                        color: Colors.green)
                    : const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
