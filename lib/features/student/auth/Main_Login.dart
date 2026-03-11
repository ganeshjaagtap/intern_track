import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/core/utils/mentor_emails.dart';
import 'package:flutter_application_2/features/student/navigation/StudentMainScreen.dart';
import 'package:flutter_application_2/features/HOD/layout/hod_main_layout.dart';
import 'package:flutter_application_2/features/faculty/dashboard/screens/faculty_dashboard_screen.dart';
import 'package:flutter_application_2/features/company_mentor/dashboard/CompanyMentorDashboardScreen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_application_2/features/student/auth/CreateAccountScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool startAnimation = false;
  bool isLoading = false;

  final Color primaryBlue = const Color(0xFF1976D2);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _animation = Tween<double>(
      begin: -200,
      end: 200,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => startAnimation = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// ---------------- GOOGLE LOGIN ----------------
  Future<void> signInWithGoogle() async {
    setState(() => isLoading = true);

    try {
      await _googleSignIn.signOut();

      final googleUser = await _googleSignIn.signIn();
      
      // Stop here if the user cancels the Google sign-in dialog
      if (googleUser == null) {
        if (mounted) setState(() => isLoading = false);
        return; 
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final userRef = FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid);

      final snapshot = await userRef.get();

      if (!mounted) return; // Added mounted check before routing

      if (!snapshot.exists) {
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName ?? "New User",
          'role': 'student',
          'dept': 'IT',
          'createdAt': FieldValue.serverTimestamp(),
        });

        _routeByRole('student', user.email ?? "");
      } else {
        _routeByRole(
          snapshot.get('role').toString().toLowerCase(),
          user.email ?? "",
        );
      }
    } catch (e) {
      if (mounted) _showError("Google login failed"); // Added mounted check
    }

    if (mounted) setState(() => isLoading = false); // Added mounted check
  }

  /// ---------------- EMAIL LOGIN ----------------
  Future<void> handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Enter email and password");
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      
      if (user == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();

      if (!mounted) return; // Added mounted check before using context/routing

      if (!snapshot.exists) {
        await _auth.signOut();
        _showError("Profile not found. Please Sign Up.");
        if (mounted) setState(() => isLoading = false);
        return;
      }

      _routeByRole(snapshot.get('role'), email);
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError(e.message ?? "Login failed"); // Added mounted check
    }

    if (mounted) setState(() => isLoading = false); // Added mounted check
  }

  /// ---------------- ROUTING ----------------
  void _routeByRole(String role, String email) {
    email = email.toLowerCase();

    // HOD / college mentors use HodMainLayout
    if (mentorEmails.contains(email) || role == 'hod') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HodMainLayout()),
      );
      return;
    }

    // Company mentors have role "mentor" in Firestore
    if (role == 'mentor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CompanyMentorDashboardScreen()),
      );
      return;
    }

    // Faculty users
    if (role == 'faculty') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FacultyDashboardScreen()),
      );
      return;
    }

    // Students
    if (role == 'student') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StudentMainScreen()),
      );
      return;
    }

    _showError("Unknown role: $role");
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND ANIMATION
          AnimatedBuilder(
            animation: _animation,
            builder: (_, child) => Transform.translate(
              offset: Offset(_animation.value, 0),
              child: child,
            ),
            child: Image.asset(
              'assets/images/collage_bg.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
          ),

          /// LOGIN FORM
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Icon(Icons.school, size: 70, color: primaryBlue),
                  const SizedBox(height: 10),

                  Text(
                    "Intern Tracker",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        /// EMAIL
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.person, color: primaryBlue),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// PASSWORD
                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock, color: primaryBlue),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(
                                () => obscurePassword = !obscurePassword,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        /// LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Login",
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// GOOGLE LOGIN
                        OutlinedButton.icon(
                          onPressed: isLoading ? null : signInWithGoogle,
                          icon: Image.asset(
                            'assets/images/google.png',
                            height: 22,
                          ),
                          label: const Text("Continue with Google"),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SIGN UP
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateAccountScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("New user? "),
                        Text(
                          "Sign Up",
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}