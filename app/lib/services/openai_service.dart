import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/roadmap.dart';
import 'roadmap_cache_service.dart';
import 'package:flutter/foundation.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final _cacheService = RoadmapCacheService();

  String get _apiKey {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint(
          'OpenAI API key not found in .env file. Please add OPENAI_API_KEY=your_key_here to your .env file.');
      throw Exception(
          'OpenAI API key not configured. Please check your .env file.');
    }
    return apiKey;
  }

  Future<Roadmap> generateRoadmap(String skillName, String level) async {
    try {
      // Check cache first
      try {
        final cachedRoadmap = await _cacheService.getRoadmap(skillName, level);
        if (cachedRoadmap != null) {
          debugPrint('Using cached roadmap for $skillName at $level level');
          return cachedRoadmap;
        }
      } catch (e) {
        debugPrint('Error reading from cache: $e');
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
                  '''You are an expert skill trainer that creates detailed learning roadmaps. 
              Your response must be a valid JSON object with a "steps" array containing exactly 6 steps.
              Each step must have:
              1. A clear description of what to learn
              2. A detailed explanation of the concept
              3. A practical exercise or task to practice
              Format the response as:
              {
                "steps": [
                  {
                    "description": "Brief title of the step",
                    "explanation": "Detailed explanation of the concept",
                    "practicePrompt": "A specific task or exercise to practice"
                  },
                  ...
                ]
              }''',
            },
            {
              'role': 'user',
              'content':
                  '''Create a detailed 6-step learning roadmap for $skillName at $level level.
              Return the response as a JSON object with a "steps" array.
              Make the explanations clear and beginner-friendly.
              Include practical exercises that can be done without external tools.''',
            },
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] == null || data['choices'].isEmpty) {
          throw Exception('Invalid response format from OpenAI');
        }

        final content = data['choices'][0]['message']['content'];
        debugPrint('OpenAI Response: $content');

        final Map<String, dynamic> responseJson = jsonDecode(content);
        if (!responseJson.containsKey('steps')) {
          throw Exception('Response missing "steps" array');
        }

        final List<dynamic> stepsJson = responseJson['steps'];
        final steps = stepsJson
            .map((step) => RoadmapStep(
                  description: step['description'],
                  explanation: step['explanation'],
                  practicePrompt: step['practicePrompt'],
                ))
            .toList();

        if (steps.isEmpty) {
          throw Exception('No valid steps found in the response');
        }

        if (steps.length != 6) {
          debugPrint('Warning: Expected 6 steps but got ${steps.length}');
        }

        final roadmap = Roadmap(
          skillName: skillName,
          level: level,
          steps: steps,
          createdAt: DateTime.now(),
        );

        // Cache the roadmap
        try {
          await _cacheService.saveRoadmap(roadmap);
        } catch (e) {
          debugPrint('Error saving to cache: $e');
        }

        return roadmap;
      } else {
        debugPrint('OpenAI API Error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('Failed to generate roadmap: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error generating roadmap: $e');
      if (e.toString().contains('Network is unreachable')) {
        throw Exception('Network error: Please check your internet connection');
      }
      throw Exception('Failed to generate roadmap: $e');
    }
  }

  Future<String> askQuestion(String skillName, String question) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content':
                  '''You are a helpful tutor assisting someone learning $skillName.
              Provide clear, concise answers that are easy to understand.
              Include examples where appropriate.''',
            },
            {
              'role': 'user',
              'content': question,
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

        final answer = data['choices'][0]['message']['content'];
        return answer;
      } else {
        debugPrint('OpenAI API Error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('Failed to get answer: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting answer: $e');
      if (e.toString().contains('Network is unreachable')) {
        throw Exception('Network error: Please check your internet connection');
      }
      throw Exception('Failed to get answer: $e');
    }
  }
}
