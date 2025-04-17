import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class LegalDocumentService {
  static Future<String> loadPrivacyPolicy() async {
    try {
      return await rootBundle.loadString('docs/PRIVACY_POLICY.md');
    } catch (e) {
      debugPrint('Error loading privacy policy: $e');
      return 'Error loading privacy policy. Please try again later.';
    }
  }

  static Future<String> loadTermsOfService() async {
    try {
      return await rootBundle.loadString('docs/TERMS_OF_SERVICE.md');
    } catch (e) {
      debugPrint('Error loading terms of service: $e');
      return 'Error loading terms of service. Please try again later.';
    }
  }
}
