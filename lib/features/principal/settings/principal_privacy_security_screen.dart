import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/features/student/auth/Main_Login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class PrincipalPrivacySecurityScreen extends StatefulWidget {
  const PrincipalPrivacySecurityScreen({super.key});

  @override
  State<PrincipalPrivacySecurityScreen> createState() =>
      _PrincipalPrivacySecurityScreenState();
}

class _PrincipalPrivacySecurityScreenState
    extends State<PrincipalPrivacySecurityScreen> {
  final Color coolSky = const Color(0xFF60B5FF);

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isLoggingOut = false;

  bool _twoFactorAuth = false;
  bool _biometricLogin = true;
  bool _hideProfile = true;
  bool _loginAlerts = true;

  String _email = '';
  String _fullName = 'Principal';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) {
        return;
      }
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .get();
      final data = doc.data() ?? <String, dynamic>{};
      final settings =
          (data['privacySecurity'] as Map<String, dynamic>?) ??
          <String, dynamic>{};

      if (!mounted) {
        return;
      }

      setState(() {
        _email = (data['email'] ?? user.email ?? '').toString();
        _fullName =
            (data['fullName'] ?? data['name'] ?? 'Principal').toString();
        _twoFactorAuth = (settings['twoFactorAuth'] as bool?) ?? false;
        _biometricLogin = (settings['biometricLogin'] as bool?) ?? true;
        _hideProfile = (settings['hideProfile'] as bool?) ?? true;
        _loginAlerts = (settings['loginAlerts'] as bool?) ?? true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load security settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance.collection('user').doc(user.uid).set({
        'privacySecurity': {
          'twoFactorAuth': _twoFactorAuth,
          'biometricLogin': _biometricLogin,
          'hideProfile': _hideProfile,
          'loginAlerts': _loginAlerts,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Privacy and security settings saved'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _updateToggle({
    required bool value,
    required void Function() applyLocal,
  }) async {
    applyLocal();
    if (mounted) {
      setState(() {});
    }
    await _saveSettings();
  }

  Future<void> _sendPasswordReset() async {
    final user = FirebaseAuth.instance.currentUser;
    final email = _email.trim().isEmpty ? user?.email ?? '' : _email.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No email address found for this account.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) {
        return;
      }

      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Password Reset Sent'),
          content: Text(
            'A password reset link has been sent to $email.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not send password reset email: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logoutAllDevices() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Log Out From All Devices?'),
            content: const Text(
              'This will sign you out on this device now and mark your account for forced re-login on other devices using your latest security state.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Log Out',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirm) {
      return;
    }

    setState(() => _isLoggingOut = true);

    try {
      await FirebaseFirestore.instance.collection('user').doc(user.uid).set({
        'security': {
          'logoutAllAt': FieldValue.serverTimestamp(),
          'lastSecurityAction': 'logout_all_devices',
        },
      }, SetOptions(merge: true));

      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() => _isLoggingOut = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: coolSky,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'PRIVACY & SECURITY',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _email.isEmpty ? 'No email found' : _email,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Security',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildSettingsContainer([
                  _buildActionTile(
                    Icons.lock_outline,
                    'Change Password',
                    'Send a reset link to your registered email',
                    _sendPasswordReset,
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    Icons.verified_user_outlined,
                    'Two-Factor Authentication',
                    'Store your preference for extra account security',
                    _twoFactorAuth,
                    (val) => _updateToggle(
                      value: val,
                      applyLocal: () => _twoFactorAuth = val,
                    ),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    Icons.fingerprint,
                    'Biometric Login',
                    'Store your biometric preference for this account',
                    _biometricLogin,
                    (val) => _updateToggle(
                      value: val,
                      applyLocal: () => _biometricLogin = val,
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                const Text(
                  'Privacy',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildSettingsContainer([
                  _buildSwitchTile(
                    Icons.visibility_off_outlined,
                    'Hide Profile Information',
                    'Save whether your profile should stay less visible',
                    _hideProfile,
                    (val) => _updateToggle(
                      value: val,
                      applyLocal: () => _hideProfile = val,
                    ),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    Icons.notifications_active_outlined,
                    'Login Activity Alerts',
                    'Save whether new login activity should be tracked',
                    _loginAlerts,
                    (val) => _updateToggle(
                      value: val,
                      applyLocal: () => _loginAlerts = val,
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                if (_isSaving)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: LinearProgressIndicator(),
                  ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _isLoggingOut
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.red,
                              ),
                            )
                          : const Icon(
                              Icons.logout,
                              color: Colors.red,
                              size: 20,
                            ),
                    ),
                    title: const Text(
                      'Log Out from All Devices',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: const Text(
                      'Sign out here now and mark the account for forced re-login',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),
                    onTap: _isLoggingOut ? null : _logoutAllDevices,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _buildSettingsContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: coolSky),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: coolSky,
      secondary: Icon(icon, color: coolSky),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
