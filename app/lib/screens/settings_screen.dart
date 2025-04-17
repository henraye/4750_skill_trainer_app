import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/skill.dart';
import '../widgets/legal_document_dialog.dart';
import 'profile_screen.dart';
import '../services/legal_document_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDeleting = false;
  bool _isChangingPassword = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      // Show re-authentication dialog
      final email = user.email;
      if (email == null) {
        throw Exception('User email not found');
      }

      final password = await _showReauthDialog();
      if (password == null) {
        setState(() {
          _isDeleting = false;
        });
        return;
      }

      // Re-authenticate the user
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete user's skills and data from Firestore
      final userDoc = _firestore.collection('users').doc(user.uid);
      final skillsCollection = userDoc.collection('skills');

      // Get all skills documents
      final skillsSnapshot = await skillsCollection.get();

      // Delete each skill document
      for (var doc in skillsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete user document
      await userDoc.delete();

      // Delete the user's authentication account
      await user.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<String?> _showReauthDialog() async {
    final passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Re-authenticate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please enter your password to confirm account deletion.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (passwordController.text.isNotEmpty) {
                Navigator.pop(context, passwordController.text);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isChangingPassword = true;
    });

    try {
      final result = await _showChangePasswordDialog();
      if (result == null) {
        setState(() {
          _isChangingPassword = false;
        });
        return;
      }

      final currentPassword = result['currentPassword'] ?? '';
      final newPassword = result['newPassword'] ?? '';

      if (currentPassword.isEmpty || newPassword.isEmpty) {
        throw Exception('Password fields cannot be empty');
      }

      // Re-authenticate the user
      final email = user.email;
      if (email == null) {
        throw Exception('User email not found');
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update the password
      await user.updatePassword(newPassword);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'Current password is incorrect';
          break;
        case 'weak-password':
          errorMessage = 'New password is too weak';
          break;
        default:
          errorMessage = 'An error occurred while changing password';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
        });
      }
    }
  }

  Future<Map<String, String>?> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    String? errorMessage;

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (currentPasswordController.text.isEmpty ||
                    newPasswordController.text.isEmpty ||
                    confirmPasswordController.text.isEmpty) {
                  setState(() {
                    errorMessage = 'Please fill in all fields';
                  });
                  return;
                }

                if (newPasswordController.text.length < 6) {
                  setState(() {
                    errorMessage = 'New password must be at least 6 characters';
                  });
                  return;
                }

                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  setState(() {
                    errorMessage = 'New passwords do not match';
                  });
                  return;
                }

                Navigator.pop(
                  context,
                  {
                    'currentPassword': currentPasswordController.text,
                    'newPassword': newPasswordController.text,
                  },
                );
              },
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy() async {
    final content = await LegalDocumentService.loadPrivacyPolicy();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() async {
    final content = await LegalDocumentService.loadTermsOfService();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Account Section
            _buildSection(
              title: 'Account',
              children: [
                ListTile(
                  title: const Text('Change Password'),
                  leading: const Icon(Icons.lock_outline),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _isChangingPassword ? null : _changePassword,
                ),
                ListTile(
                  title: const Text('Privacy Policy'),
                  leading: const Icon(Icons.privacy_tip_outlined),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showPrivacyPolicy,
                ),
                ListTile(
                  title: const Text('Terms of Service'),
                  leading: const Icon(Icons.description_outlined),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _showTermsOfService,
                ),
              ],
            ),

            // Danger Zone
            _buildSection(
              title: 'Danger Zone',
              children: [
                ListTile(
                  title: const Text(
                    'Delete Account',
                    style: TextStyle(color: Colors.red),
                  ),
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  onTap: _isDeleting ? null : _showDeleteAccountDialog,
                ),
              ],
            ),

            // App Info
            _buildSection(
              title: 'About',
              children: [
                ListTile(
                  title: const Text('Version'),
                  subtitle: const Text('1.0.0'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF49454F),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
            ),
            const SizedBox(height: 16),
            const Text(
              'This will permanently delete:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Your account and all associated data'),
            const Text('• Your skills and learning progress'),
            const Text('• Your profile information'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _isDeleting
                ? null
                : () async {
                    Navigator.pop(context);
                    await _deleteAccount();
                  },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: _isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
