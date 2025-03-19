import 'package:flutter/material.dart';
import '../models/skill.dart';
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
  final _nameController = TextEditingController();
  String _selectedLevel = 'Beginner';
  bool _isLoading = false;
  final _openAIService = OpenAIService();

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Generate roadmap
        final roadmap = await _openAIService.generateRoadmap(
          _nameController.text,
          _selectedLevel,
        );

        // Create skill with roadmap
        final skill = Skill(
          name: _nameController.text,
          level: _selectedLevel,
          roadmap: roadmap,
        );

        widget.onAdd(skill);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating roadmap: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Skill'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Skill Name',
                hintText: 'Enter skill name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a skill name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: const InputDecoration(
                labelText: 'Level',
                hintText: 'Select skill level',
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
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submitForm,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
