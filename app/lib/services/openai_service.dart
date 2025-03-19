import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/roadmap.dart';
import 'roadmap_cache_service.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final _cacheService = RoadmapCacheService();

  String get _apiKey {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenAI API key not found in environment variables');
    }
    return apiKey;
  }

  Future<List<String>> generateRoadmap(String skillName, String level) async {
    try {
      // Check cache first
      final cachedRoadmap = await _cacheService.getRoadmap(skillName, level);
      if (cachedRoadmap != null) {
        print('Using cached roadmap for $skillName at $level level');
        return cachedRoadmap.steps;
      }

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {
              'role': 'system',
              'content':
                  '''You are a helpful assistant that creates learning roadmaps for skills. 
              Your response must follow these rules:
              1. Each step must start with a number followed by a period (e.g., "1. Step description")
              2. Each step must be on a new line
              3. Each step should be clear and actionable
              4. Steps should build upon each other
              5. Keep descriptions concise and specific
              6. Provide exactly 6 steps''',
            },
            {
              'role': 'user',
              'content':
                  '''Create a learning roadmap for $skillName at $level level.
              Format your response exactly like this:
              1. First step
              2. Second step
              3. Third step
              4. Fourth step
              5. Fifth step
              6. Sixth step''',
            },
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] == null || data['choices'].isEmpty) {
          throw Exception('Invalid response format from OpenAI');
        }

        final content = data['choices'][0]['message']['content'];
        print('OpenAI Response: $content'); // Debug log

        // Split by newlines and clean up each line
        final lines = content.split('\n');
        final steps = <String>[];

        for (final line in lines) {
          final trimmedLine = line.trim();
          if (trimmedLine.isEmpty) continue;

          // Check if line starts with a number followed by a period
          if (RegExp(r'^\d+\.').hasMatch(trimmedLine)) {
            // Remove the number and period from the start
            final step = trimmedLine.replaceFirst(RegExp(r'^\d+\.\s*'), '');
            if (step.isNotEmpty) {
              steps.add(step);
            }
          }
        }

        if (steps.isEmpty) {
          throw Exception('No valid steps found in the response');
        }

        if (steps.length != 6) {
          print('Warning: Expected 6 steps but got ${steps.length}');
        }

        // Cache the roadmap
        final roadmap = Roadmap(
          skillName: skillName,
          level: level,
          steps: steps,
          createdAt: DateTime.now(),
        );
        await _cacheService.saveRoadmap(roadmap);

        return steps;
      } else {
        print('OpenAI API Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to generate roadmap: ${response.statusCode}');
      }
    } catch (e) {
      print('Error generating roadmap: $e');
      throw Exception('Failed to generate roadmap: $e');
    }
  }
}
