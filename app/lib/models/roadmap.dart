class Roadmap {
  final String skillName;
  final String level;
  final List<String> steps;
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
      'steps': steps,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Roadmap.fromJson(Map<String, dynamic> json) {
    return Roadmap(
      skillName: json['skillName'],
      level: json['level'],
      steps: List<String>.from(json['steps']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
