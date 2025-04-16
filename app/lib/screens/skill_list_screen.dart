import 'package:flutter/material.dart';
import '../widgets/skill_item.dart';
import '../models/skill.dart';
import '../widgets/add_skill_dialog.dart';
import '../services/firestore_service.dart';

class SkillListScreen extends StatefulWidget {
  const SkillListScreen({super.key});

  @override
  State<SkillListScreen> createState() => _SkillListScreenState();
}

class _SkillListScreenState extends State<SkillListScreen> {
  bool _isEditMode = false;
  final _firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _removeSkill(String skillName) async {
    try {
      debugPrint('Attempting to remove skill: $skillName');
      await _firestoreService.deleteSkill(skillName);
      debugPrint('Skill removed from Firestore');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skill removed successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error removing skill: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing skill: $e')),
        );
      }
    }
  }

  void _addSkill() {
    showDialog(
      context: context,
      builder: (context) => AddSkillDialog(
        onAdd: (skill) async {
          try {
            await _firestoreService.addSkill(skill);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error adding skill: $e')),
              );
            }
          }
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
            // Search Bar and Edit Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
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
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Find Skills',
                          hintStyle: const TextStyle(
                            color: Color(0xFF49454F),
                            fontSize: 16,
                          ),
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xFF49454F)),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Color(0xFF49454F)),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _toggleEditMode,
                    icon: Icon(
                      _isEditMode ? Icons.check : Icons.edit,
                      color: _isEditMode
                          ? const Color(0xFF6750A4)
                          : const Color(0xFF49454F),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
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
                        child: StreamBuilder<List<Skill>>(
                          stream: _firestoreService.getSkills(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }

                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final skills = snapshot.data!;
                            final filteredSkills = _searchQuery.isEmpty
                                ? skills
                                : skills
                                    .where((skill) => skill.name
                                        .toLowerCase()
                                        .contains(_searchQuery))
                                    .toList();

                            if (filteredSkills.isEmpty) {
                              return Center(
                                child: Text(
                                  _searchQuery.isEmpty
                                      ? 'No skills added yet'
                                      : 'No skills found matching "$_searchQuery"',
                                ),
                              );
                            }

                            return ListView.separated(
                              itemCount: filteredSkills.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final skill = filteredSkills[index];
                                return SkillItem(
                                  letter: skill.name[0],
                                  level: skill.level,
                                  skillName: skill.name,
                                  roadmap: skill.roadmap,
                                  showRemoveButton: _isEditMode,
                                  onRemove: () => _removeSkill(skill.id!),
                                );
                              },
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
