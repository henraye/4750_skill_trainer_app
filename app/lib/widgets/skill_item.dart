import 'package:flutter/material.dart';

class SkillItem extends StatelessWidget {
  final String letter;
  final String level;
  final String skillName;
  final VoidCallback onRemove;

  const SkillItem({
    super.key,
    required this.letter,
    required this.level,
    required this.skillName,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFD9BDFE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  color: Color(0xFF523C72),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Skill Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level,
                  style: const TextStyle(
                    color: Color(0xFF49454F),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  skillName,
                  style: const TextStyle(
                    color: Color(0xFF1D1B20),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Remove Button
          IconButton(
            onPressed: onRemove,
            icon: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF49454F),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Color(0xFF49454F),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
