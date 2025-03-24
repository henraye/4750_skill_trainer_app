import 'package:flutter/material.dart';
import '../models/skill.dart';
import '../services/auth_service.dart';
import 'auth/sign_in_screen.dart';
import 'auth/create_account_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final List<Skill> skills;
  final _authService = AuthService();

  ProfileScreen({
    super.key,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 32),
            // Profile Avatar
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD9E2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: user != null
                      ? Text(
                          user.email?[0].toUpperCase() ?? '?',
                          style: const TextStyle(
                            fontSize: 60,
                            color: Color(0xFF6B2D40),
                          ),
                        )
                      : const Icon(
                          Icons.person_outline,
                          size: 60,
                          color: Color(0xFF6B2D40),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (user != null) ...[
              // User Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      user.email ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1D1B20),
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () async {
                        try {
                          await _authService.signOut();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Signed out')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: Color(0xFF6750A4)),
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Auth Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInScreen(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF6750A4),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Sign In'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateAccountScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: const BorderSide(color: Color(0xFF6750A4)),
                      ),
                      child: const Text('Create Account'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Skills Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Skills',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF49454F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        skills.map((s) => s.name).join(', '),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1D1B20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
