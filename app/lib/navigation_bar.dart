import 'package:flutter/material.dart';
import 'package:my_first_project/skill.dart';
import 'package:my_first_project/main.dart';
class NavigationBar extends StatelessWidget {
  const NavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: const Text(
              'Skill Trainer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Enter a Skill'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SkillInputPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Skills'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SkillListPage(),  // Directly use the global skills list
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
            },
          ),
        ],
      ),
    );
  }
}
