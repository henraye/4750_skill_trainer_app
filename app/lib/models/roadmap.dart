class RoadmapStep {
  final String description;
  final String explanation;
  final String practicePrompt;
  bool isCompleted;
  String? reflection;
  DateTime? completedAt;

  RoadmapStep({
    required this.description,
    required this.explanation,
    required this.practicePrompt,
    this.isCompleted = false,
    this.reflection,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'explanation': explanation,
      'practicePrompt': practicePrompt,
      'isCompleted': isCompleted,
      'reflection': reflection,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory RoadmapStep.fromJson(Map<String, dynamic> json) {
    return RoadmapStep(
      description: json['description'] ?? '',
      explanation: json['explanation'] ?? '',
      practicePrompt: json['practicePrompt'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      reflection: json['reflection'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }
}

class Roadmap {
  final String skillName;
  final String level;
  final List<RoadmapStep> steps;
  final DateTime createdAt;

  Roadmap({
    required this.skillName,
    required this.level,
    required this.steps,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'skillName': skillName,
      'level': level,
      'steps': steps.map((step) => step.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Roadmap.fromJson(Map<String, dynamic> json) {
    return Roadmap(
      skillName: json['skillName'],
      level: json['level'],
      steps: (json['steps'] as List)
          .map((step) => RoadmapStep.fromJson(step))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
