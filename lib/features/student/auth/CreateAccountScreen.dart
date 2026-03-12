import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Standard Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Role-Specific Controllers
  final TextEditingController enrollmentController = TextEditingController();
  final TextEditingController collegeController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController deptController = TextEditingController();
  
  // NEW: Controller for Faculty/Mentor ID
  final TextEditingController idController = TextEditingController();

  String selectedRole = 'Student';
  final List<String> roles = ['Student', 'Faculty', 'Company Mentor'];

  bool obscurePassword = true;
  bool isLoading = false;

  final Color primaryBlue = const Color(0xFF1976D2);

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    enrollmentController.dispose();
    collegeController.dispose();
    companyController.dispose();
    designationController.dispose();
    deptController.dispose();
    idController.dispose(); // Dispose the new controller
    super.dispose();
  }

  String _getDatabaseRole(String uiRole) {
    if (uiRole == 'Faculty') return 'faculty';
    if (uiRole == 'Company Mentor') return 'mentor';
    return 'student'; 
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> handleSignUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final customId = idController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in all basic fields.");
      return;
    }

    // Validate ID for Faculty/Mentor
    if (selectedRole != 'Student' && customId.isEmpty) {
      _showSnackBar("Please provide your Employee/Mentor ID.");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        String dbRole = _getDatabaseRole(selectedRole);

        Map<String, dynamic> userData = {
          'uid': user.uid,
          'email': email,
          'fullName': name,
          'role': dbRole,
          'isApproved': false,
          'createdAt': FieldValue.serverTimestamp(),
        };

        if (selectedRole == 'Student') {
          userData['enrollmentNo'] = enrollmentController.text.trim();
          userData['college'] = collegeController.text.trim();
          userData['dept'] = 'IT';
          userData['internshipStatus'] = 'Pending';
        } else if (selectedRole == 'Company Mentor') {
          userData['mentorId'] = customId; // Saving the ID
          userData['company_name'] = companyController.text.trim();
          userData['designation'] = designationController.text.trim();
          userData['total_students'] = 0;
        } else if (selectedRole == 'Faculty') {
          userData['facultyId'] = customId; // Saving the ID
          userData['dept'] = deptController.text.trim();
          userData['college'] = collegeController.text.trim();
        }

        await FirebaseFirestore.instance.collection('user').doc(user.uid).set(userData);
        await _auth.signOut();

        if (!mounted) return;
        _showSnackBar("Request sent to HOD! You can login once approved.", isSuccess: true);
        Navigator.pop(context); 
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        if (mounted) _showSnackBar("This user already exists!");
      } else {
        if (mounted) _showSnackBar(e.message ?? "Registration failed");
      }
    } catch (e) {
      if (mounted) _showSnackBar("An unexpected error occurred.");
    }

    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: primaryBlue,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.person_add_alt_1, size: 60, color: primaryBlue),
              const SizedBox(height: 10),
              Text(
                "Join Intern Tracker",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBlue),
              ),
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: "I am a",
                        prefixIcon: Icon(Icons.badge, color: primaryBlue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      items: roles.map((String role) {
                        return DropdownMenuItem<String>(value: role, child: Text(role));
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedRole = newValue;
                            idController.clear();
                            enrollmentController.clear();
                            collegeController.clear();
                            companyController.clear();
                            designationController.clear();
                            deptController.clear();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        children: [
                          if (selectedRole == 'Student') ...[
                            _buildTextField(enrollmentController, "Enrollment Number", Icons.numbers),
                            const SizedBox(height: 16),
                            _buildTextField(collegeController, "College Name", Icons.account_balance),
                            const SizedBox(height: 16),
                          ],
                          if (selectedRole == 'Faculty') ...[
                            // NEW: Faculty ID Field
                            _buildTextField(idController, "Faculty Employee ID", Icons.badge_outlined),
                            const SizedBox(height: 16),
                            _buildTextField(deptController, "Department (e.g., IT, CSE)", Icons.domain),
                            const SizedBox(height: 16),
                            _buildTextField(collegeController, "College Name", Icons.account_balance),
                            const SizedBox(height: 16),
                          ],
                          if (selectedRole == 'Company Mentor') ...[
                            // NEW: Mentor ID Field
                            _buildTextField(idController, "Mentor ID / Employee Code", Icons.fingerprint),
                            const SizedBox(height: 16),
                            _buildTextField(companyController, "Company Name", Icons.business),
                            const SizedBox(height: 16),
                            _buildTextField(designationController, "Your Designation", Icons.work),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),

                    _buildTextField(nameController, "Full Name", Icons.person),
                    const SizedBox(height: 16),
                    _buildTextField(emailController, "Email", Icons.email, isEmail: true),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock, color: primaryBlue),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => obscurePassword = !obscurePassword),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: confirmPasswordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        prefixIcon: Icon(Icons.lock_outline, color: primaryBlue),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Submit Request to HOD", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isEmail = false}) {
    return TextField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryBlue),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}