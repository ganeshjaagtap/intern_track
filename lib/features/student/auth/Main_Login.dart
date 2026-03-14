import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_2/core/utils/mentor_emails.dart';
import 'package:flutter_application_2/features/student/navigation/StudentMainScreen.dart';
import 'package:flutter_application_2/features/HOD/layout/hod_main_layout.dart';
import 'package:flutter_application_2/features/faculty/dashboard/screens/faculty_dashboard_screen.dart';
import 'package:flutter_application_2/features/company_mentor/dashboard/CompanyMentorDashboardScreen.dart';
import 'package:flutter_application_2/features/principal/dashboard/principal_dashboard_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_application_2/features/student/auth/CreateAccountScreen.dart';
import 'package:flutter_application_2/features/student/auth/PendingApprovalScreen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

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

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: 0,
      end: 15,
    ).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => startAnimation = true);
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String _getDatabaseRole(String uiRole) {
    if (uiRole == 'Faculty') return 'faculty';
    if (uiRole == 'Company Mentor') return 'mentor';
    return 'student'; 
  }

  /// ---------------- ROLE SELECTION DIALOG ----------------
  Future<String?> _showRoleSelectionDialog() async {
    String tempRole = 'Student'; 
    return showDialog<String>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Welcome!", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Please select your role to complete registration:"),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: tempRole,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.badge, color: primaryBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: ['Student', 'Faculty', 'Company Mentor'].map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) tempRole = newValue;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null), 
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
              onPressed: () => Navigator.pop(context, tempRole), 
              child: const Text("Continue", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  /// ---------------- GOOGLE LOGIN ----------------
  Future<void> signInWithGoogle() async {
    setState(() => isLoading = true);
    try {
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
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

      final userRef = FirebaseFirestore.instance.collection('user').doc(user.uid);
      final snapshot = await userRef.get().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception("Network Timeout"),
      );

      if (!mounted) return;

      if (!snapshot.exists) {
        String? chosenRole = await _showRoleSelectionDialog();
        if (chosenRole == null) {
          await user.delete(); 
          await _googleSignIn.signOut();
          if (mounted) setState(() => isLoading = false);
          return;
        }

        String dbRole = _getDatabaseRole(chosenRole);
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'fullName': user.displayName ?? "New User",
          'role': dbRole,
          'dept': 'IT',
          'isApproved': false, 
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
          (route) => false,
        );
        return;
      } else {
        final data = snapshot.data() as Map<String, dynamic>;
        
        // --- SMART CHECK START ---
        bool isApproved = true; 
        if (data.containsKey('isApproved')) {
          var val = data['isApproved'];
          if (val is bool) isApproved = val;
          else if (val is String) isApproved = val.toLowerCase() == 'true';
        }
        // --- SMART CHECK END ---

        String role = data['role']?.toString().trim().toLowerCase() ?? 'student';
        String email = user.email ?? "";

        if (!isApproved && !mentorEmails.contains(email) && role != 'hod') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
            (route) => false,
          );
          return; 
        }

        _routeByRole(role, email);
        return;
      }
    } catch (e) {
      print("🚨 GOOGLE LOGIN ERROR: $e");
      if (mounted) _showError("Login failed: $e");
    }
    if (mounted) setState(() => isLoading = false);
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

      final snapshot = await FirebaseFirestore.instance.collection('user').doc(user.uid).get().timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception("Network Timeout"),
      );

      if (!mounted) return;

      if (!snapshot.exists) {
        await _auth.signOut();
        _showError("Profile not found. Please Sign Up.");
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final data = snapshot.data() as Map<String, dynamic>;
      
      // --- SMART CHECK START ---
      bool isApproved = true; 
      if (data.containsKey('isApproved')) {
        var val = data['isApproved'];
        if (val is bool) isApproved = val;
        else if (val is String) isApproved = val.toLowerCase() == 'true';
      }
      // --- SMART CHECK END ---

      String role = data['role']?.toString().trim().toLowerCase() ?? 'student';

      if (!isApproved && !mentorEmails.contains(email) && role != 'hod') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
          (route) => false,
        );
        return;
      }

      _routeByRole(role, email);
      return;
    } on FirebaseAuthException catch (e) {
      if (mounted) _showError("${e.code}: ${e.message ?? "Login failed"}");
    } catch (e) {
      print("🚨 LOGIN ERROR: $e");
      if (mounted) _showError("Unexpected error: $e");
    }
    if (mounted) setState(() => isLoading = false);
  }

  void _routeByRole(String role, String email) {
    role = role.trim().toLowerCase();
    email = email.trim().toLowerCase();
    Widget targetScreen;

    if (mentorEmails.contains(email) || role == 'hod') targetScreen = const HodMainLayout();
    else if (role == 'mentor') targetScreen = const CompanyMentorDashboardScreen();
    else if (role == 'faculty') targetScreen = const FacultyDashboardScreen();
    else if (role == 'student') targetScreen = const StudentMainScreen();
    else if (role == 'principal') targetScreen = const PrincipalDashboardScreen();
    else {
      _showError("Unknown role: $role");
      if (mounted) setState(() => isLoading = false);
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
      (route) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFF8F9FA),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Icon(Icons.school, size: 70, color: primaryBlue),
                  const SizedBox(height: 10),
                  Text("Intern Tracker", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryBlue)),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: const Color(0xFFBBDEFB), borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        TextField(controller: emailController, decoration: InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.person, color: primaryBlue), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                        const SizedBox(height: 16),
                        TextField(controller: passwordController, obscureText: obscurePassword, decoration: InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock, color: primaryBlue), suffixIcon: IconButton(icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => obscurePassword = !obscurePassword)), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
                        const SizedBox(height: 24),
                        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: isLoading ? null : handleLogin, style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 14)), child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Login", style: TextStyle(color: Colors.white)))),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(onPressed: isLoading ? null : signInWithGoogle, icon: Image.asset('assets/images/google.png', height: 22), label: const Text("Continue with Google"), style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48), backgroundColor: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAccountScreen())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: primaryBlue.withOpacity(0.5), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.2),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("New user? ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text("Sign Up", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
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
