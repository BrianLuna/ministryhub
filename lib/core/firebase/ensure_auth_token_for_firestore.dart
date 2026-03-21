import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// On web, Firestore can briefly run queries before the ID token is attached,
/// which surfaces as `permission-denied` even with correct Security Rules.
///
/// Call this before Firestore reads that require [request.auth] in rules.
Future<void> ensureAuthTokenForFirestore({required String userId}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || user.uid != userId) {
    return;
  }
  try {
    await user.getIdToken();
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('ensureAuthTokenForFirestore: $e\n$st');
    }
  }
}
