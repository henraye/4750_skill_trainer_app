import 'package:flutter/material.dart';
import '../models/skill.dart';
import '../services/openai_service.dart';

class SkillRoadmapScreen extends StatefulWidget {
  final Skill skill;

  const SkillRoadmapScreen({
    super.key,
    required this.skill,
  });

  @override
  State<SkillRoadmapScreen> createState() => _SkillRoadmapScreenState();
}

class _SkillRoadmapScreenState extends State<SkillRoadmapScreen> {
  bool _isLoading = true;
  String? _error;
  List<String>? _roadmapSteps;
  final _openAIService = OpenAIService();

  @override
  void initState() {
    super.initState();
    _generateRoadmap();
  }

  Future<void> _generateRoadmap() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final steps = await _openAIService.generateRoadmap(
        widget.skill.name,
        widget.skill.level,
      );

      setState(() {
        _roadmapSteps = steps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to generate roadmap. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('${widget.skill.name} Roadmap'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _generateRoadmap,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _roadmapSteps?.length ?? 0,
                    itemBuilder: (context, index) {
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
                              decoration: BoxDecoration(
                                color: const Color(0xFFD9BDFE),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
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
                                  Text(
                                    'Step ${index + 1}',
                                    style: const TextStyle(
                                      color: Color(0xFF523C72),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Step Content
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                _roadmapSteps![index],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1D1B20),
                                ),
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
