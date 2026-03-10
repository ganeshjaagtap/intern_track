import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {

  final String name;
  final String email;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
  }

  void saveProfile() {

    if (_formKey.currentState!.validate()) {

      Navigator.pop(context, {
        "name": nameController.text,
        "email": emailController.text,
      });

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              const SizedBox(height: 10),

              /// PROFILE ICON

              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),

              const SizedBox(height: 20),

              /// NAME FIELD

              TextFormField(
                controller: nameController,

                decoration: InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter your name";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// EMAIL FIELD

              TextFormField(
                controller: emailController,

                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Enter email";
                  }

                  if (!value.contains("@")) {
                    return "Enter valid email";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              /// SAVE BUTTON

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(

                  onPressed: saveProfile,

                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),

                  child: const Text(
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
}