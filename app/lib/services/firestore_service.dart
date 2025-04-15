import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/skill.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user's document reference
  DocumentReference get _userDoc {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(user.uid);
  }

  // Create or update user document
  Future<void> createUserDocument({
    required String email,
    String? displayName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(user.uid).set({
      'email': email,
      'displayName': displayName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Add a skill to user's skills collection
  Future<void> addSkill(Skill skill) async {
    final docRef = await _userDoc.collection('skills').add({
      'name': skill.name,
      'level': skill.level,
      'roadmap': skill.roadmap,
      'createdAt': FieldValue.serverTimestamp(),
    });
    debugPrint('Added skill with ID: ${docRef.id}');
  }

  // Get all skills for the current user
  Stream<List<Skill>> getSkills() {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('No authenticated user found');
      return Stream.value([]);
    }

    debugPrint('Fetching skills for user: ${user.uid}');

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('skills')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .handleError((error) {
      debugPrint('Error fetching skills: $error');
      return [];
    }).map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            try {
              return Skill(
                name: data['name'] ?? '',
                level: data['level'] ?? '',
                roadmap: data['roadmap'] != null
                    ? List<String>.from(data['roadmap'])
                    : null,
                id: doc.id,
              );
            } catch (e) {
              debugPrint('Error parsing skill data: $e');
              return null;
            }
          })
          .where((skill) => skill != null)
          .cast<Skill>()
          .toList();
    });
  }

  // Delete a skill
  Future<void> deleteSkill(String skillId) async {
    debugPrint('Deleting skill with ID: $skillId');
    await _userDoc.collection('skills').doc(skillId).delete();
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
  }) async {
    await _userDoc.update({
      'displayName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
