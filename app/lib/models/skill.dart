import 'roadmap.dart';

class Skill {
  final String name;
  final String level;
  final Roadmap? roadmap;
  final String? id;

  Skill({
    required this.name,
    required this.level,
    this.roadmap,
    this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
      'roadmap': roadmap?.toJson(),
    };
  }

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      name: json['name'],
      level: json['level'],
      roadmap:
          json['roadmap'] != null ? Roadmap.fromJson(json['roadmap']) : null,
      id: json['id'],
    );
  }
}
