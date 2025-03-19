import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/roadmap.dart';

class RoadmapCacheService {
  static const String _storageKey = 'roadmap_cache';
  static const Duration _cacheDuration = Duration(days: 7);
  SharedPreferences? _prefs;

  Future<void> _ensurePrefs() async {
    if (_prefs == null) {
      try {
        _prefs = await SharedPreferences.getInstance();
      } catch (e) {
        print('Failed to initialize SharedPreferences: $e');
      }
    }
  }

  Future<Roadmap?> getRoadmap(String skillName, String level) async {
    await _ensurePrefs();
    if (_prefs == null) return null;

    try {
      final cacheData = _prefs!.getString(_storageKey);
      if (cacheData == null) return null;

      final List<dynamic> cachedRoadmaps = jsonDecode(cacheData);
      final roadmaps =
          cachedRoadmaps.map((json) => Roadmap.fromJson(json)).toList();

      try {
        final roadmap = roadmaps.firstWhere(
          (r) => r.skillName == skillName && r.level == level,
        );

        // Check if the roadmap is expired
        final age = DateTime.now().difference(roadmap.createdAt);
        if (age > _cacheDuration) {
          // Remove expired roadmap
          roadmaps.remove(roadmap);
          await _saveRoadmaps(roadmaps);
          return null;
        }

        return roadmap;
      } catch (e) {
        return null;
      }
    } catch (e) {
      print('Error reading roadmap from cache: $e');
      return null;
    }
  }

  Future<void> saveRoadmap(Roadmap roadmap) async {
    await _ensurePrefs();
    if (_prefs == null) return;

    try {
      final cacheData = _prefs!.getString(_storageKey);
      List<Roadmap> roadmaps = [];

      if (cacheData != null) {
        final List<dynamic> cachedRoadmaps = jsonDecode(cacheData);
        roadmaps =
            cachedRoadmaps.map((json) => Roadmap.fromJson(json)).toList();
      }

      // Remove existing roadmap for this skill and level if it exists
      roadmaps.removeWhere(
        (r) => r.skillName == roadmap.skillName && r.level == roadmap.level,
      );

      // Add new roadmap
      roadmaps.add(roadmap);

      await _saveRoadmaps(roadmaps);
    } catch (e) {
      print('Error saving roadmap to cache: $e');
    }
  }

  Future<void> _saveRoadmaps(List<Roadmap> roadmaps) async {
    if (_prefs == null) return;

    try {
      final jsonData = roadmaps.map((r) => r.toJson()).toList();
      await _prefs!.setString(_storageKey, jsonEncode(jsonData));
    } catch (e) {
      print('Error saving roadmaps to SharedPreferences: $e');
    }
  }
}
