import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

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

  // Image picker and profile image
  final ImagePicker _imagePicker = ImagePicker();
  File? _pickedImage;
  String? _profileImageUrl;

  // Personal Details Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController enrollmentNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Internship Details Controllers
  final TextEditingController companyController = TextEditingController();
  final TextEditingController internshipRoleController = TextEditingController();

  // Mentor Details Controllers
  final TextEditingController collegeMentorController = TextEditingController();
  final TextEditingController companyMentorController = TextEditingController();

  // Dropdown values
  String? selectedYear;
  String? selectedStatus;
  String? selectedType;

  // Date values
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

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (pickedFile != null) {
        setState(() => _pickedImage = File(pickedFile.path));
        await _uploadProfileImage();
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_pickedImage == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${user.uid}.jpg');

        await storageRef.putFile(_pickedImage!);

        // Get download URL
        final downloadUrl = await storageRef.getDownloadURL();

        // Update Firestore with image URL
        await FirebaseFirestore.instance
            .collection('students')
            .doc(user.uid)
            .update({'profileImageUrl': downloadUrl});

        setState(() {
          _profileImageUrl = downloadUrl;
          _pickedImage = null;
          _isUploadingImage = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Error uploading image: $e');
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    }
  }

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
            collegeMentorController.text = data['collegeMentor'] ?? '';
            companyMentorController.text = data['companyMentor'] ?? '';

            selectedYear = data['year'];
            selectedStatus = data['internshipStatus'];
            selectedType = data['internshipType'];

            _profileImageUrl = data['profileImageUrl'];

            if (data['startDate'] != null) {
              startDate = (data['startDate'] as Timestamp).toDate();
            }
            if (data['endDate'] != null) {
              endDate = (data['endDate'] as Timestamp).toDate();
            }

            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

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
          'company': companyController.text.trim(),
          'internshipRole': internshipRoleController.text.trim(),
          'collegeMentor': collegeMentorController.text.trim(),
          'companyMentor': companyMentorController.text.trim(),
          'year': selectedYear,
          'internshipStatus': selectedStatus,
          'internshipType': selectedType,
          'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
          'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          setState(() => _isSaving = false);
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
      print('Error saving user data: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BB6FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
                    // PROFILE AVATAR
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.redAccent,
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : (_profileImageUrl != null
                                    ? NetworkImage(_profileImageUrl!)
                                    : null) as ImageProvider?,
                            child: (_pickedImage == null &&
                                    _profileImageUrl == null)
                                ? const Icon(Icons.person,
                                    color: Colors.white, size: 48)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: _isUploadingImage
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                onPressed: _isUploadingImage
                                    ? null
                                    : _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // SECTION A: PERSONAL DETAILS
                    _buildSectionHeader('Personal Details'),
                    _buildSectionCard(
                      children: [
                        _inputField(
                          controller: fullNameController,
                          label: "Student Full Name",
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Full Name is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _inputField(
                          controller: enrollmentNoController,
                          label: "Enrollment Number",
                          icon: Icons.confirmation_number_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enrollment Number is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildDropdownField(
                          label: "Year",
                          icon: Icons.school_outlined,
                          value: selectedYear,
                          items: years,
                          onChanged: (String? value) {
                            setState(() => selectedYear = value);
                          },
                        ),
                        const SizedBox(height: 14),
                        _inputField(
                          controller: phoneController,
                          label: "Phone Number",
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Phone Number is required";
                            }
                            if (value.length < 10) {
                              return "Enter a valid phone number";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _inputField(
                          controller: emailController,
                          label: "Email",
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email is required";
                            }
                            if (!RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                .hasMatch(value)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // SECTION B: INTERNSHIP DETAILS
                    _buildSectionHeader('Internship Details'),
                    _buildSectionCard(
                      children: [
                        _inputField(
                          controller: companyController,
                          label: "Company",
                          icon: Icons.business_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Company name is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _inputField(
                          controller: internshipRoleController,
                          label: "Role",
                          icon: Icons.work_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Role is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildDatePickerField(
                          label: "Start Date",
                          icon: Icons.calendar_today_outlined,
                          selectedDate: startDate,
                          onDateSelected: (DateTime? date) {
                            setState(() => startDate = date);
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildDatePickerField(
                          label: "End Date",
                          icon: Icons.calendar_today_outlined,
                          selectedDate: endDate,
                          onDateSelected: (DateTime? date) {
                            setState(() => endDate = date);
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildDropdownField(
                          label: "Status",
                          icon: Icons.info_outline,
                          value: selectedStatus,
                          items: statuses,
                          onChanged: (String? value) {
                            setState(() => selectedStatus = value);
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildDropdownField(
                          label: "Type",
                          icon: Icons.category_outlined,
                          value: selectedType,
                          items: types,
                          onChanged: (String? value) {
                            setState(() => selectedType = value);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // SECTION C: MENTOR DETAILS
                    _buildSectionHeader('Mentor Details'),
                    _buildSectionCard(
                      children: [
                        _inputField(
                          controller: collegeMentorController,
                          label: "College Mentor",
                          icon: Icons.person_add_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "College Mentor is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _inputField(
                          controller: companyMentorController,
                          label: "Company Mentor",
                          icon: Icons.person_add_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Company Mentor is required";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // SAVE BUTTON
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
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _isSaving ? "Saving..." : "Save Changes",
                          style: const TextStyle(fontSize: 16),
                        ),
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

  /// SECTION HEADER WIDGET
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

  /// SECTION CARD WRAPPER
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
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  /// INPUT FIELD WIDGET
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
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return "$label cannot be empty";
            }
            return null;
          },
    );
  }

  /// DROPDOWN FIELD WIDGET
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
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label is required";
        }
        return null;
      },
    );
  }

  /// DATE PICKER FIELD WIDGET
  Widget _buildDatePickerField({
    required String label,
    required IconData icon,
    required DateTime? selectedDate,
    required Function(DateTime?) onDateSelected,
  }) {
    return TextFormField(
      readOnly: true,
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        hintText: selectedDate != null
            ? DateFormat('dd/MM/yyyy').format(selectedDate)
            : 'Select date',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        suffixIcon: selectedDate != null
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => onDateSelected(null),
              )
            : null,
      ),
      validator: (value) {
        return null;
      },
    );
  }

}
