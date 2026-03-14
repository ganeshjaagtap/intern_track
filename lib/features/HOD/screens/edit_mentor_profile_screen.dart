import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditMentorProfileScreen extends StatefulWidget {
  const EditMentorProfileScreen({super.key});

  @override
  State<EditMentorProfileScreen> createState() =>
      _EditMentorProfileScreenState();
}

class _EditMentorProfileScreenState extends State<EditMentorProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _showDesignationField = false;
  bool _isUploadingImage = false;

  final ImagePicker _imagePicker = ImagePicker();
  File? _pickedImage;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _departmentController.dispose();
    _collegeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No logged-in user found.')),
          );
          Navigator.pop(context);
        }
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();

      final data = doc.data() ?? <String, dynamic>{};

      _fullNameController.text =
          (data['fullName'] ?? data['name'] ?? '').toString();
      _departmentController.text =
          (data['dept'] ?? data['department'] ?? '').toString();
      _collegeController.text =
          (data['college'] ?? data['collegeName'] ?? '').toString();
      _phoneController.text =
          (data['phoneNumber'] ?? data['phone'] ?? '').toString();
      _emailController.text =
          (data['email'] ?? user.email ?? 'No Email').toString();
      _designationController.text = (data['designation'] ?? '').toString();
      _profileImageUrl = (data['profileImageUrl'] ?? '').toString();
      _showDesignationField = data.containsKey('designation') ||
          _designationController.text.trim().isNotEmpty;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No logged-in user found.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updateData = <String, dynamic>{
        'fullName': _fullNameController.text.trim(),
        'dept': _departmentController.text.trim(),
        'college': _collegeController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'profileImageUrl': _profileImageUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (_showDesignationField) {
        updateData['designation'] = _designationController.text.trim();
      }

      await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .set(updateData, SetOptions(merge: true));

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save changes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() => _pickedImage = File(pickedFile.path));
      await _uploadProfileImage();
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    const String cloudName = 'dqfpu6bhv';
    const String uploadPreset = 'profile_images';

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonMap =
          jsonDecode(responseBody) as Map<String, dynamic>;
      return jsonMap['secure_url'] as String?;
    } else {
      throw Exception('Cloudinary upload failed: $responseBody');
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_pickedImage == null) return;
    setState(() => _isUploadingImage = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final imageUrl = await _uploadImageToCloudinary(_pickedImage!);

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('No image URL returned from Cloudinary');
      }

      await FirebaseFirestore.instance.collection('user').doc(user.uid).update({
        'profileImageUrl': imageUrl,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      setState(() {
        _profileImageUrl = imageUrl;
        _isUploadingImage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile image uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isUploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF6BB6FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: _isUploadingImage ? null : _pickImage,
                                child: CircleAvatar(
                                  radius: 38,
                                  backgroundColor:
                                      primaryBlue.withOpacity(0.12),
                                  backgroundImage: _pickedImage != null
                                      ? FileImage(_pickedImage!)
                                      : (_profileImageUrl != null &&
                                              _profileImageUrl!.isNotEmpty
                                          ? NetworkImage(_profileImageUrl!)
                                          : null),
                                  child: (_pickedImage == null &&
                                          (_profileImageUrl == null ||
                                              _profileImageUrl!.isEmpty))
                                      ? const Icon(
                                          Icons.person,
                                          size: 40,
                                          color: primaryBlue,
                                        )
                                      : null,
                                ),
                              ),
                              if (_isUploadingImage)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: primaryBlue,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    onPressed:
                                        _isUploadingImage ? null : _pickImage,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _fullNameController.text.trim().isEmpty
                                ? 'Mentor Profile'
                                : _fullNameController.text.trim(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _emailController.text.trim().isEmpty
                                ? 'No Email'
                                : _emailController.text.trim(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _fullNameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Full Name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _departmentController,
                            label: 'Department',
                            icon: Icons.account_balance_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Department is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _collegeController,
                            label: 'College Name',
                            icon: Icons.school_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'College Name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              final phone = value?.trim() ?? '';
                              if (phone.isEmpty) {
                                return 'Phone Number is required';
                              }
                              final digitsOnly =
                                  phone.replaceAll(RegExp(r'\D'), '');
                              if (digitsOnly.length < 10 ||
                                  digitsOnly.length > 15) {
                                return 'Enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email ID',
                            icon: Icons.email_outlined,
                            readOnly: true,
                            enabled: false,
                          ),
                          if (_showDesignationField) ...[
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _designationController,
                              label: 'Designation',
                              icon: Icons.work_outline,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSaving
                                ? null
                                : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blueGrey,
                              side: const BorderSide(color: Colors.blueGrey),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6BB6FF)),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF6BB6FF), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
