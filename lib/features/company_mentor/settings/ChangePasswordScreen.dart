import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController currentPasswordController =
      TextEditingController();

  final TextEditingController newPasswordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  void changePassword() {

    if (_formKey.currentState!.validate()) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password updated successfully"),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Change Password"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [

              const SizedBox(height: 10),

              /// CURRENT PASSWORD

              TextFormField(
                controller: currentPasswordController,
                obscureText: obscureCurrent,

                decoration: InputDecoration(
                  labelText: "Current Password",

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureCurrent
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureCurrent = !obscureCurrent;
                      });
                    },
                  ),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter current password";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// NEW PASSWORD

              TextFormField(
                controller: newPasswordController,
                obscureText: obscureNew,

                decoration: InputDecoration(
                  labelText: "New Password",

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureNew
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureNew = !obscureNew;
                      });
                    },
                  ),
                ),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter new password";
                  }

                  if (value.length < 6) {
                    return "Password must be at least 6 characters";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// CONFIRM PASSWORD

              TextFormField(
                controller: confirmPasswordController,
                obscureText: obscureConfirm,

                decoration: InputDecoration(
                  labelText: "Confirm Password",

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirm
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirm = !obscureConfirm;
                      });
                    },
                  ),
                ),

                validator: (value) {

                  if (value == null || value.isEmpty) {
                    return "Confirm your password";
                  }

                  if (value != newPasswordController.text) {
                    return "Passwords do not match";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              /// UPDATE BUTTON

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: changePassword,

                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),

                  child: const Text(
                    "Update Password",
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