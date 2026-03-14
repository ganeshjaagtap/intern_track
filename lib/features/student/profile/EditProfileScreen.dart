import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  final ImagePicker _imagePicker = ImagePicker();
  File? _pickedImage;
  String? _profileImageUrl;

  // Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController enrollmentNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController internshipRoleController = TextEditingController();

  // Mentor Names
  final TextEditingController collegeMentorController = TextEditingController();
  final TextEditingController companyMentorController = TextEditingController();

  // Mentor IDs
  final TextEditingController facultyMentorIdController = TextEditingController();
  final TextEditingController companyMentorIdController = TextEditingController();

  String? selectedYear;
  String? selectedStatus;
  String? selectedType;
  DateTime? startDate;
  DateTime? endDate;

  final List<String> years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
  final List<String> statuses = ['Ongoing', 'Completed', 'Pending'];
  final List<String> types = ['Paid', 'Unpaid', 'Remote', 'Onsite', 'Hybrid'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    enrollmentNoController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyController.dispose();
    internshipRoleController.dispose();
    collegeMentorController.dispose();
    companyMentorController.dispose();
    facultyMentorIdController.dispose();
    companyMentorIdController.dispose();
    super.dispose();
  }

  /// ---------------- LOAD DATA FROM FIREBASE ----------------
  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data() as Map<String, dynamic>;
          setState(() {
            fullNameController.text = data['fullName'] ?? '';
            enrollmentNoController.text = data['enrollmentNo'] ?? '';
            emailController.text = data['email'] ?? '';
            phoneController.text = data['phoneNumber'] ?? '';
            companyController.text = data['company'] ?? '';
            internshipRoleController.text = data['internshipRole'] ?? '';

            // Loading Names
            collegeMentorController.text = data['collegeMentor'] ?? '';
            companyMentorController.text = data['companyMentor'] ?? '';

            // Loading IDs
            facultyMentorIdController.text = data['facultyId'] ?? '';
            companyMentorIdController.text = data['companyMentorId'] ?? '';

            selectedYear = data['year'];
            selectedStatus = data['internshipStatus'];
            selectedType = data['internshipType'];
            _profileImageUrl = data['profileImageUrl'];

            if (data['startDate'] != null) {
              startDate = DateTime.tryParse(data['startDate']);
            }
            if (data['endDate'] != null) {
              endDate = DateTime.tryParse(data['endDate']);
            }

            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// ---------------- SAVE DATA TO FIREBASE ----------------
  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .update({
          'fullName': fullNameController.text.trim(),
          'enrollmentNo': enrollmentNoController.text.trim(),
          'email': emailController.text.trim(),
          'phoneNumber': phoneController.text.trim(),
          'year': selectedYear,
          'company': companyController.text.trim(),
          'internshipRole': internshipRoleController.text.trim(),
          'internshipStatus': selectedStatus,
          'internshipType': selectedType,
          'startDate': startDate != null
              ? DateFormat('yyyy-MM-dd').format(startDate!)
              : null,
          'endDate': endDate != null
              ? DateFormat('yyyy-MM-dd').format(endDate!)
              : null,

          // Mentor details
          'collegeMentor': collegeMentorController.text.trim(),
          'facultyId': facultyMentorIdController.text.trim(),
          'companyMentor': companyMentorController.text.trim(),
          'companyMentorId': companyMentorIdController.text.trim(),

          // Keep image URL synced
          'profileImageUrl': _profileImageUrl,

          'lastUpdated': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// ---------------- IMAGE LOGIC ----------------
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

      await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .update({
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

  /// ---------------- UI BUILD ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
        title: const Text(
          "EDIT PROFILE",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar Section
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.blueGrey,
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : (_profileImageUrl != null &&
                                        _profileImageUrl!.isNotEmpty
                                    ? NetworkImage(_profileImageUrl!)
                                    : null),
                            child: (_pickedImage == null &&
                                    (_profileImageUrl == null ||
                                        _profileImageUrl!.isEmpty))
                                ? const Icon(Icons.person, size: 48)
                                : null,
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
                                    height: 24,
                                    width: 24,
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
                              backgroundColor: Colors.blue,
                              radius: 18,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: _isUploadingImage ? null : _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Personal Details
                    _buildSectionHeader('Personal Details'),
                    _buildSectionCard(children: [
                      _inputField(
                        controller: fullNameController,
                        label: "Student Full Name",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: enrollmentNoController,
                        label: "Enrollment Number",
                        icon: Icons.confirmation_number_outlined,
                      ),
                      const SizedBox(height: 14),
                      _buildDropdownField(
                        label: "Year",
                        icon: Icons.school_outlined,
                        value: selectedYear,
                        items: years,
                        onChanged: (val) => setState(() => selectedYear = val),
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: phoneController,
                        label: "Phone Number",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: emailController,
                        label: "Email",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Internship Details
                    _buildSectionHeader('Internship Details'),
                    _buildSectionCard(children: [
                      _inputField(
                        controller: companyController,
                        label: "Company Name",
                        icon: Icons.business_outlined,
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: internshipRoleController,
                        label: "Role",
                        icon: Icons.work_outline,
                      ),
                      const SizedBox(height: 14),
                      _buildDatePickerField(
                        label: "Start Date",
                        icon: Icons.calendar_today_outlined,
                        selectedDate: startDate,
                        onDateSelected: (date) => setState(() => startDate = date),
                      ),
                      const SizedBox(height: 14),
                      _buildDatePickerField(
                        label: "End Date",
                        icon: Icons.calendar_today_outlined,
                        selectedDate: endDate,
                        onDateSelected: (date) => setState(() => endDate = date),
                      ),
                      const SizedBox(height: 14),
                      _buildDropdownField(
                        label: "Status",
                        icon: Icons.info_outline,
                        value: selectedStatus,
                        items: statuses,
                        onChanged: (val) =>
                            setState(() => selectedStatus = val),
                      ),
                      const SizedBox(height: 14),
                      _buildDropdownField(
                        label: "Type",
                        icon: Icons.category_outlined,
                        value: selectedType,
                        items: types,
                        onChanged: (val) => setState(() => selectedType = val),
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // Mentor Details
                    _buildSectionHeader('Mentor Details'),
                    _buildSectionCard(children: [
                      _inputField(
                        controller: collegeMentorController,
                        label: "Faculty Mentor Name",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: facultyMentorIdController,
                        label: "Faculty Mentor ID",
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: companyMentorController,
                        label: "Company Mentor Name",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 14),
                      _inputField(
                        controller: companyMentorIdController,
                        label: "Company Mentor ID",
                        icon: Icons.fingerprint_outlined,
                      ),
                    ]),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6BB6FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(_isSaving ? "Saving..." : "Save Changes"),
                        onPressed: _isSaving ? null : _saveUserData,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  /// ---------------- UI HELPERS ----------------

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6BB6FF),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator ??
          (value) => (value == null || value.isEmpty)
              ? "$label is required"
              : null,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? "$label is required" : null,
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required IconData icon,
    required DateTime? selectedDate,
    required Function(DateTime?) onDateSelected,
  }) {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: selectedDate != null
            ? DateFormat('dd/MM/yyyy').format(selectedDate)
            : '',
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        );
        if (pickedDate != null) onDateSelected(pickedDate);
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
