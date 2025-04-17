import 'package:flutter/material.dart';
import '../models/roadmap.dart';

class SkillRoadmapScreen extends StatelessWidget {
  final String skillName;
  final String level;
  final Roadmap roadmap;

  const SkillRoadmapScreen({
    super.key,
    required this.skillName,
    required this.level,
    required this.roadmap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('$skillName Roadmap'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: roadmap.steps.length,
          itemBuilder: (context, index) {
            final step = roadmap.steps[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
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
              child: Column(
                children: [
                  // Step Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFD9BDFE),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Color(0xFF523C72),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            step.description,
                            style: const TextStyle(
                              color: Color(0xFF523C72),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Step Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.explanation,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1D1B20),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Practice:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D1B20),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          step.practicePrompt,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1D1B20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
