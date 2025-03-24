import 'package:flutter/material.dart';
import '../models/skill.dart';
import '../services/auth_service.dart';
import 'skill_list_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Skill> _skills = [];
  final _authService = AuthService();
  bool _hasNavigatedToProfile = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData && !_hasNavigatedToProfile) {
          // Delay the navigation to ensure the widget is fully built
          Future.delayed(Duration.zero, () {
            if (mounted && _selectedIndex != 1) {
              setState(() {
                _selectedIndex = 1;
                _hasNavigatedToProfile = true;
              });
            }
          });
        } else if (!snapshot.hasData) {
          _hasNavigatedToProfile = false;
        }

        return WillPopScope(
          onWillPop: () async {
            if (_selectedIndex != 0) {
              setState(() {
                _selectedIndex = 0;
              });
              return false;
            }
            return true;
          },
          child: Scaffold(
            body: IndexedStack(
              index: _selectedIndex,
              children: [
                SkillListScreen(skills: _skills),
                ProfileScreen(skills: _skills),
                SettingsScreen(skills: _skills),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                backgroundColor: Colors.white,
                selectedItemColor: const Color(0xFF6750A4),
                unselectedItemColor: const Color(0xFF49454F),
                onTap: _onItemTapped,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.list),
                    label: 'Skill List',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    label: 'Profile',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
