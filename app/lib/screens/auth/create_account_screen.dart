import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main_screen.dart';
import '../../widgets/legal_document_dialog.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailSent = false;
  bool _acceptPrivacyPolicy = false;
  bool _acceptTermsOfService = false;

  @override
  void initState() {
    super.initState();
    // Request focus after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptPrivacyPolicy || !_acceptTermsOfService) {
      setState(() {
        _errorMessage =
            'Please accept both Privacy Policy and Terms of Service';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create the user account
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Send verification email
      await userCredential.user?.sendEmailVerification();

      setState(() {
        _isEmailSent = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent. Please check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Sign out the user until they verify their email
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return 'An error occurred during account creation.';
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => LegalDocumentDialog(
        title: 'Privacy Policy',
        content: '''
Last Updated: ${DateTime.now().toString().split(' ')[0]}

1. Information We Collect
We collect information that you provide directly to us, including:
- Email address
- Skill learning progress
- User preferences and settings

2. How We Use Your Information
We use the collected information to:
- Provide and maintain our service
- Improve user experience
- Send you updates and notifications

3. Data Storage and Security
Your data is stored securely in Firebase and is protected using industry-standard security measures. We implement appropriate technical and organizational measures to protect your personal information.

4. Third-Party Services
We use the following third-party services:
- Firebase Authentication for user management
- Firebase Firestore for data storage
- OpenAI API for generating learning roadmaps

5. Your Rights
You have the right to:
- Access your personal data
- Correct inaccurate data
- Request deletion of your data
- Opt-out of communications

6. Changes to This Policy
We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.

7. Contact Us
If you have any questions about this Privacy Policy, please contact us at tran.herny123@gmail.com.
''',
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => LegalDocumentDialog(
        title: 'Terms of Service',
        content: '''
Last Updated: ${DateTime.now().toString().split(' ')[0]}

1. Acceptance of Terms
By accessing or using Skill Trainer, you agree to be bound by these Terms of Service.

2. User Accounts
- You must be at least 13 years old to use this service
- You are responsible for maintaining the security of your account
- You must provide accurate and complete information
- You are limited to a maximum of 5 skills in your learning journey at a time (this will be increased in the future)

3. User Content
-You retain ownership of any content you submit to Skill Trainer. By submitting content, you grant us a limited, non-exclusive, revocable license to use, store, and process your content solely for the purpose of operating and improving the service. We do not claim ownership of your content and will not use it for marketing or commercial purposes without your explicit consent.

4. Prohibited Activities
You agree not to:
- Violate any laws or regulations
- Impersonate others
- Interfere with the service
- Use the service for unauthorized purposes

5. Intellectual Property
- The service and its content are protected by copyright
- You may not copy, modify, or distribute the service without permission

6. Limitation of Liability
To the fullest extent permitted by law, we are not liable for:
- Any indirect, incidental, or consequential damages
- Loss of data or profits
- Service interruptions or errors

7. Termination
We may terminate or suspend your account at any time for violations of these terms.

8. Changes to Terms
We may modify these terms at any time. Continued use of the service constitutes acceptance of the modified terms.

9. Governing Law
These terms are governed by the laws of the United States.

10. Contact Information
For questions about these terms, contact us at tran.herny123@gmail.com.
''',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo/Title
                const Icon(
                  Icons.school,
                  size: 80,
                  color: Color(0xFF6750A4),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D1B20),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start your learning journey',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF49454F),
                  ),
                ),
                const SizedBox(height: 48),

                // Create Account Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        value: _acceptPrivacyPolicy,
                        onChanged: (bool? value) {
                          setState(() {
                            _acceptPrivacyPolicy = value ?? false;
                          });
                        },
                        title: GestureDetector(
                          onTap: _showPrivacyPolicy,
                          child: const Text(
                            'I accept the Privacy Policy',
                            style: TextStyle(
                              color: Color(0xFF6750A4),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      CheckboxListTile(
                        value: _acceptTermsOfService,
                        onChanged: (bool? value) {
                          setState(() {
                            _acceptTermsOfService = value ?? false;
                          });
                        },
                        title: GestureDetector(
                          onTap: _showTermsOfService,
                          child: const Text(
                            'I accept the Terms of Service',
                            style: TextStyle(
                              color: Color(0xFF6750A4),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (_isEmailSent) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8DEF8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                color: Color(0xFF6750A4),
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Verification email sent!',
                                style: TextStyle(
                                  color: Color(0xFF1D1B20),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Please check your inbox and verify your email address to continue.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF49454F),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _isLoading ? null : _createAccount,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF6750A4),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(
                        color: Color(0xFF49454F),
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
