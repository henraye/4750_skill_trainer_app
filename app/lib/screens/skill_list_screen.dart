import 'package:flutter/material.dart';
import '../widgets/skill_item.dart';
import '../models/skill.dart';
import '../widgets/add_skill_dialog.dart';

class SkillListScreen extends StatefulWidget {
  final List<Skill> skills;

  const SkillListScreen({
    super.key,
    required this.skills,
  });

  @override
  State<SkillListScreen> createState() => _SkillListScreenState();
}

class _SkillListScreenState extends State<SkillListScreen> {
  late List<Skill> _skills;

  @override
  void initState() {
    super.initState();
    _skills = List.from(widget.skills);
  }

  void _removeSkill(int index) {
    setState(() {
      _skills.removeAt(index);
    });
  }

  void _addSkill() {
    showDialog(
      context: context,
      builder: (context) => AddSkillDialog(
        onAdd: (skill) {
          setState(() {
            _skills.add(skill);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Find Skills',
                    hintStyle: const TextStyle(
                      color: Color(0xFF49454F),
                      fontSize: 16,
                    ),
                    prefixIcon:
                        const Icon(Icons.menu, color: Color(0xFF49454F)),
                    suffixIcon:
                        const Icon(Icons.search, color: Color(0xFF49454F)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),

            // Skills List and Add Button
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF7FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.black.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          itemCount: _skills.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final skill = _skills[index];
                            return SkillItem(
                              letter: skill.name[0],
                              level: skill.level,
                              skillName: skill.name,
                              onRemove: () => _removeSkill(index),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Add Button
                    ElevatedButton(
                      onPressed: _addSkill,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8DEF8),
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Icon(Icons.add, color: Color(0xFF1D192B)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
