class Skill {
  final String name;
  final String level;
  List<String>? roadmap;

  Skill({
    required this.name,
    required this.level,
    this.roadmap,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
      'roadmap': roadmap,
    };
  }

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      name: json['name'],
      level: json['level'],
      roadmap:
          json['roadmap'] != null ? List<String>.from(json['roadmap']) : null,
    );
  }
}
