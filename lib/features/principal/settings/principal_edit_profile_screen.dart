import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/core/utils/user_profile_schema.dart';

class PrincipalEditProfileScreen extends StatefulWidget {
  const PrincipalEditProfileScreen({super.key});

  @override
  State<PrincipalEditProfileScreen> createState() =>
      _PrincipalEditProfileScreenState();
}

class _PrincipalEditProfileScreenState extends State<PrincipalEditProfileScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();

  String _profileImageUrl = "";
  bool _isLoading = true;
  bool _isSaving = false;

  final Color coolSky = const Color(0xFF60B5FF);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    _deptController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser.uid)
          .get();

      final data = userDoc.data() as Map<String, dynamic>? ?? {};
      if (!mounted) {
        return;
      }

      setState(() {
        _profileImageUrl = (data['profileImageUrl'] ?? '').toString();
        _fullNameController.text =
            (data['fullName'] ?? data['name'] ?? '').toString();
        _emailController.text =
            (data['email'] ?? currentUser.email ?? '').toString();
        _phoneController.text =
            (data['phoneNumber'] ?? data['phone'] ?? '').toString();
        _employeeIdController.text =
            (data['principalId'] ?? data['employeeId'] ?? '').toString();
        _deptController.text = (data['dept'] ?? '').toString();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load profile: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return;
    }

    final nameError = UserProfileSchema.validateRequired(
      _fullNameController.text,
      'Full Name',
    );
    final phoneError = UserProfileSchema.validatePhoneNumber(
      _phoneController.text,
    );
    final deptError = UserProfileSchema.validateDept(_deptController.text);
    final employeeIdError = UserProfileSchema.validateMentorId(
      _employeeIdController.text,
      label: 'Employee ID',
    );

    final firstError = [
      nameError,
      phoneError,
      deptError,
      employeeIdError,
    ].firstWhere((error) => error.isNotEmpty, orElse: () => '');

    if (firstError.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(firstError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser.uid)
          .set({
        'fullName': UserProfileSchema.normalizeName(_fullNameController.text),
        'email': UserProfileSchema.normalizeEmail(_emailController.text),
        'phoneNumber': UserProfileSchema.normalizePhoneNumber(
          _phoneController.text,
        ),
        'principalId': UserProfileSchema.normalizeMentorId(
          _employeeIdController.text,
        ),
        'employeeId': UserProfileSchema.normalizeMentorId(
          _employeeIdController.text,
        ),
        'dept': UserProfileSchema.normalizeDept(_deptController.text),
        'profileImageUrl': _profileImageUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: coolSky,
        title: const Text(
          "EDIT PROFILE",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFFF35252),
                          backgroundImage: _profileImageUrl.isNotEmpty
                              ? NetworkImage(_profileImageUrl)
                              : null,
                          child: _profileImageUrl.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: coolSky,
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _fullNameController,
                          icon: Icons.person_outline,
                          label: "Full Name",
                        ),
                        _buildTextField(
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          label: "Email",
                          readOnly: true,
                        ),
                        _buildTextField(
                          controller: _phoneController,
                          icon: Icons.phone_outlined,
                          label: "Phone Number",
                        ),
                        _buildTextField(
                          controller: _employeeIdController,
                          icon: Icons.badge_outlined,
                          label: "Employee ID",
                        ),
                        _buildTextField(
                          controller: _deptController,
                          icon: Icons.apartment_outlined,
                          label: "Department",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: coolSky,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save, color: Colors.black),
                      label: Text(
                        _isSaving ? "Saving..." : "Save Changes",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
