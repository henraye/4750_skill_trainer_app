import 'package:flutter/material.dart';
import '../models/skill.dart';
import '../models/category.dart';
import '../services/firestore_service.dart';
import '../services/openai_service.dart';

class AddSkillDialog extends StatefulWidget {
  final Function(Skill) onAdd;

  const AddSkillDialog({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddSkillDialog> createState() => _AddSkillDialogState();
}

class _AddSkillDialogState extends State<AddSkillDialog> {
  final _formKey = GlobalKey<FormState>();
  final _openAIService = OpenAIService();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;
  Category? _selectedCategory;
  String _selectedSkill = '';
  String _selectedLevel = 'Beginner';
  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSkill.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Generate a learning roadmap using OpenAI
      final roadmap = await _openAIService.generateRoadmap(
        _selectedSkill,
        _selectedLevel,
      );

      // Create the skill object with the generated roadmap
      final skill = Skill(
        name: _selectedSkill,
        level: _selectedLevel,
        roadmap: roadmap,
      );

      // Save the skill to Firestore
      await _firestoreService.addSkill(skill);

      // Close the dialog
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Skill'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category Dropdown
                DropdownButtonFormField<Category>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: Categories.all.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                      _selectedSkill =
                          ''; // Reset selected skill when category changes
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                if (_selectedCategory != null) ...[
                  // Category Description
                  Text(
                    _selectedCategory!.description,
                    style: const TextStyle(
                      color: Color(0xFF49454F),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Example Skills
                  Wrap(
                    spacing: 8,
                    children: _selectedCategory!.examples.map((skill) {
                      return FilterChip(
                        label: Text(skill),
                        selected: _selectedSkill == skill,
                        onSelected: (selected) {
                          setState(() {
                            _selectedSkill = selected ? skill : '';
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Level Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'Skill Level',
                    border: OutlineInputBorder(),
                  ),
                  items: _levels.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLevel = value!;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading || _selectedSkill.isEmpty ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
