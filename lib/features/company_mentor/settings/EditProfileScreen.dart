import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _mentorIdController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _companyAddressController =
      TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _documentMissing = false;

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
    _mentorIdController.dispose();
    _companyNameController.dispose();
    _designationController.dispose();
    _companyAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _documentMissing = false;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final doc = await FirebaseFirestore.instance
          .collection("user")
          .doc(currentUser.uid)
          .get();

      if (!doc.exists) {
        if (!mounted) return;
        setState(() {
          _documentMissing = true;
          _isLoading = false;
        });
        return;
      }

      final data = doc.data() as Map<String, dynamic>;

      _fullNameController.text = (data["fullName"] ?? "").toString();
      _emailController.text =
          (data["email"] ?? currentUser.email ?? "").toString();
      _phoneController.text =
          (data["phoneNumber"] ?? data["phone"] ?? "").toString();
      _mentorIdController.text = (data["mentorId"] ?? "").toString();
      _companyNameController.text = (data["company_name"] ?? "").toString();
      _designationController.text = (data["designation"] ?? "").toString();
      _companyAddressController.text =
          (data["company_address"] ?? "").toString();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _documentMissing = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load profile: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User not logged in."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection("user")
          .doc(currentUser.uid)
          .update({
        "fullName": _fullNameController.text.trim(),
        "phoneNumber": _phoneController.text.trim(),
        "mentorId": _mentorIdController.text.trim(),
        "company_name": _companyNameController.text.trim(),
        "designation": _designationController.text.trim(),
        "company_address": _companyAddressController.text.trim(),
        "lastUpdated": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFF5F9ED6),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _documentMissing
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        const Text(
                          "Profile not found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _loadProfile,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFFE3EEF9),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Color(0xFF5F9ED6),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildField(
                          controller: _fullNameController,
                          label: "Full Name",
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Enter full name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _emailController,
                          label: "Email",
                          icon: Icons.email_outlined,
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _phoneController,
                          label: "Phone Number",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _mentorIdController,
                          label: "Mentor ID",
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _companyNameController,
                          label: "Company Name",
                          icon: Icons.business_outlined,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Enter company name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _designationController,
                          label: "Designation",
                          icon: Icons.work_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          controller: _companyAddressController,
                          label: "Company Address",
                          icon: Icons.location_on_outlined,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5F9ED6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: _isSaving ? null : _saveProfile,
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Save Changes",
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
