import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacultyEditProfileScreen extends StatefulWidget {
  const FacultyEditProfileScreen({super.key});

  @override
  State<FacultyEditProfileScreen> createState() => _FacultyEditProfileScreenState();
}

class _FacultyEditProfileScreenState extends State<FacultyEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;

  // Controllers for Faculty/Mentor fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController idController = TextEditingController(); // Stores Faculty ID or Mentor ID
  final TextEditingController orgController = TextEditingController(); // Stores Dept or Company Name
  final TextEditingController designationController = TextEditingController();

  String userRole = ""; // To identify if they are 'faculty' or 'mentor'

  @override
  void initState() {
    super.initState();
    _loadFacultyData();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    idController.dispose();
    orgController.dispose();
    designationController.dispose();
    super.dispose();
  }

  /// ---------------- LOAD DATA FROM FIRESTORE ----------------
  Future<void> _loadFacultyData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            userRole = data['role'] ?? 'faculty';
            nameController.text = data['fullName'] ?? data['name'] ?? '';
            phoneController.text = data['phoneNumber'] ?? data['phone'] ?? '';
            designationController.text = data['designation'] ?? '';

            if (userRole == 'faculty') {
              idController.text = data['facultyId'] ?? '';
              orgController.text = data['dept'] ?? '';
            } else {
              idController.text = data['mentorId'] ?? '';
              orgController.text = data['company_name'] ?? '';
            }
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
      setState(() => _isLoading = false);
    }
  }

  /// ---------------- SAVE DATA TO FIRESTORE ----------------
  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      Map<String, dynamic> updateData = {
        'fullName': nameController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'designation': designationController.text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      // Map specific fields based on role
      if (userRole == 'faculty') {
        updateData['facultyId'] = idController.text.trim();
        updateData['dept'] = orgController.text.trim();
      } else {
        updateData['mentorId'] = idController.text.trim();
        updateData['company_name'] = orgController.text.trim();
      }

      await FirebaseFirestore.instance.collection('user').doc(user!.uid).update(updateData);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated Successfully!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF6BB6FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text("EDIT ${userRole.toUpperCase()} PROFILE"),
        backgroundColor: primaryBlue,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildSectionCard([
                    _buildTextField(nameController, "Full Name", Icons.person),
                    const SizedBox(height: 15),
                    _buildTextField(phoneController, "Phone Number", Icons.phone, keyboardType: TextInputType.phone),
                  ]),
                  
                  const SizedBox(height: 20),

                  _buildSectionCard([
                    // Show Faculty ID or Mentor ID based on role
                    _buildTextField(
                      idController, 
                      userRole == 'faculty' ? "Faculty Employee ID" : "Mentor ID", 
                      Icons.badge
                    ),
                    const SizedBox(height: 15),
                    // Show Department or Company based on role
                    _buildTextField(
                      orgController, 
                      userRole == 'faculty' ? "Department (e.g. IT)" : "Company Name", 
                      Icons.business
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(designationController, "Designation", Icons.work),
                  ]),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _isSaving ? null : _saveData,
                      child: _isSaving 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("SAVE CHANGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6BB6FF)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (val) => (val == null || val.isEmpty) ? "This field is required" : null,
    );
  }
}