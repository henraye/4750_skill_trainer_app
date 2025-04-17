import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/roadmap.dart';
import 'package:flutter/foundation.dart';

class RoadmapCacheService {
  static const String _storageKey = 'roadmap_cache';
  static const Duration _cacheDuration = Duration(days: 7);
  SharedPreferences? _prefs;

  Future<void> _ensurePrefs() async {
    if (_prefs == null) {
      try {
        _prefs = await SharedPreferences.getInstance();
      } catch (e) {
        debugPrint('Failed to initialize SharedPreferences: $e');
      }
    }
  }

  Future<Roadmap?> getRoadmap(String skillName, String level) async {
    await _ensurePrefs();
    if (_prefs == null) return null;

    try {
      final cacheData = _prefs!.getString(_storageKey);
      if (cacheData == null) return null;

      final Map<String, dynamic> cacheMap = jsonDecode(cacheData);
      final List<dynamic> cachedRoadmaps = cacheMap['roadmaps'] ?? [];

      final roadmaps = cachedRoadmaps
          .map((json) {
            try {
              return Roadmap.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              debugPrint('Error parsing roadmap from cache: $e');
              return null;
            }
          })
          .where((roadmap) => roadmap != null)
          .cast<Roadmap>()
          .toList();

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
      debugPrint('Error reading roadmap from cache: $e');
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
        try {
          final Map<String, dynamic> cacheMap = jsonDecode(cacheData);
          final List<dynamic> cachedRoadmaps = cacheMap['roadmaps'] ?? [];
          roadmaps = cachedRoadmaps
              .map((json) {
                try {
                  return Roadmap.fromJson(json as Map<String, dynamic>);
                } catch (e) {
                  debugPrint('Error parsing roadmap from cache: $e');
                  return null;
                }
              })
              .where((roadmap) => roadmap != null)
              .cast<Roadmap>()
              .toList();
        } catch (e) {
          debugPrint('Error parsing cache data: $e');
          // If cache is corrupted, start fresh
          roadmaps = [];
        }
      }

      // Remove existing roadmap for this skill and level if it exists
      roadmaps.removeWhere(
        (r) => r.skillName == roadmap.skillName && r.level == roadmap.level,
      );

      // Add new roadmap
      roadmaps.add(roadmap);

      await _saveRoadmaps(roadmaps);
    } catch (e) {
      debugPrint('Error saving roadmap to cache: $e');
    }
  }

  Future<void> _saveRoadmaps(List<Roadmap> roadmaps) async {
    if (_prefs == null) return;

    try {
      final jsonData = {
        'roadmaps': roadmaps.map((r) => r.toJson()).toList(),
      };
      await _prefs!.setString(_storageKey, jsonEncode(jsonData));
    } catch (e) {
      debugPrint('Error saving roadmaps to SharedPreferences: $e');
    }
  }
}
