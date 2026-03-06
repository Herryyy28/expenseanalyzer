import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lazily initialize GoogleSignIn only if supported
  GoogleSignIn? __googleSignIn;
  GoogleSignIn get _googleSignIn {
    __googleSignIn ??= GoogleSignIn();
    return __googleSignIn!;
  }

  bool get _isGoogleSupported =>
      kIsWeb || (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // ==================== GOOGLE SIGN IN ====================

  /// Sign in with Google
  Future<User?> signInWithGoogle() async {
    if (!_isGoogleSupported) {
      debugPrint(
        '⚠️ Google Sign-In is not supported on this platform (Windows/Linux).',
      );
      throw Exception('Google Sign-In is only available on Mobile and Web.');
    }

    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If user cancels the sign-in
      if (googleUser == null) {
        debugPrint('Google sign-in cancelled by user');
        return null;
      }

      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      debugPrint('✅ Google sign-in successful: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Google Sign-In Error: $e');
      rethrow;
    }
  }

  // ==================== EMAIL/PASSWORD AUTH ====================

  /// Sign up with email and password
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name if provided
      if (displayName != null && userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
      }

      debugPrint('✅ Email sign-up successful: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign-up Error: ${e.code} - ${e.message}');
      _handleAuthException(e);
      rethrow;
    } catch (e) {
      debugPrint('❌ Sign-up Error: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      debugPrint('✅ Email sign-in successful: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Sign-in Error: ${e.code} - ${e.message}');
      _handleAuthException(e);
      rethrow;
    } catch (e) {
      debugPrint('❌ Sign-in Error: $e');
      rethrow;
    }
  }

  // ==================== PASSWORD RESET ====================

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Password Reset Error: ${e.code} - ${e.message}');
      _handleAuthException(e);
      rethrow;
    } catch (e) {
      debugPrint('❌ Password Reset Error: $e');
      rethrow;
    }
  }

  // ==================== SIGN OUT ====================

  /// Sign out from all providers
  Future<void> signOut() async {
    try {
      // Try to disconnect Google account (ignore errors if not supported/connected)
      if (_isGoogleSupported) {
        try {
          await _googleSignIn.disconnect();
        } catch (e) {
          debugPrint('Google disconnect skipped: $e');
        }
      }

      // Sign out from Firebase
      await _auth.signOut();

      debugPrint('✅ User signed out successfully');
    } catch (e) {
      debugPrint('❌ Sign-out Error: $e');
      rethrow;
    }
  }

  // ==================== USER MANAGEMENT ====================

  /// Update user display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.reload();
      debugPrint('✅ Display name updated: $displayName');
    } catch (e) {
      debugPrint('❌ Update Display Name Error: $e');
      rethrow;
    }
  }

  /// Update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail);
      debugPrint('✅ Verification email sent to: $newEmail');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Update Email Error: ${e.code} - ${e.message}');
      _handleAuthException(e);
      rethrow;
    } catch (e) {
      debugPrint('❌ Update Email Error: $e');
      rethrow;
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
      debugPrint('✅ Password updated successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Update Password Error: ${e.code} - ${e.message}');
      _handleAuthException(e);
      rethrow;
    } catch (e) {
      debugPrint('❌ Update Password Error: $e');
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
      debugPrint('✅ Account deleted successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Delete Account Error: ${e.code} - ${e.message}');
      _handleAuthException(e);
      rethrow;
    } catch (e) {
      debugPrint('❌ Delete Account Error: $e');
      rethrow;
    }
  }

  /// Reauthenticate user with email/password
  Future<void> reauthenticateWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _auth.currentUser?.reauthenticateWithCredential(credential);
      debugPrint('✅ Reauthentication successful');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Reauthentication Error: ${e.code} - ${e.message}');
      _handleAuthException(e);
      rethrow;
    } catch (e) {
      debugPrint('❌ Reauthentication Error: $e');
      rethrow;
    }
  }

  /// Reauthenticate user with Google
  Future<void> reauthenticateWithGoogle() async {
    if (!_isGoogleSupported) {
      debugPrint('Google Re-auth not supported on this platform.');
      return;
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.currentUser?.reauthenticateWithCredential(credential);
      debugPrint('✅ Reauthentication with Google successful');
    } catch (e) {
      debugPrint('❌ Reauthentication with Google Error: $e');
      rethrow;
    }
  }

  // ==================== EMAIL VERIFICATION ====================

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      debugPrint('✅ Email verification sent');
    } catch (e) {
      debugPrint('❌ Send Email Verification Error: $e');
      rethrow;
    }
  }

  /// Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // ==================== ERROR HANDLING ====================

  /// Handle Firebase Auth exceptions and provide user-friendly messages
  void _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        debugPrint('No user found with this email.');
        break;
      case 'wrong-password':
        debugPrint('Wrong password provided.');
        break;
      case 'email-already-in-use':
        debugPrint('An account already exists with this email.');
        break;
      case 'invalid-email':
        debugPrint('The email address is invalid.');
        break;
      case 'weak-password':
        debugPrint('The password is too weak.');
        break;
      case 'operation-not-allowed':
        debugPrint('This operation is not allowed.');
        break;
      case 'user-disabled':
        debugPrint('This user account has been disabled.');
        break;
      case 'too-many-requests':
        debugPrint('Too many requests. Please try again later.');
        break;
      case 'requires-recent-login':
        debugPrint(
          'This operation requires recent authentication. Please log in again.',
        );
        break;
      default:
        debugPrint('Authentication error: ${e.message}');
    }
  }

  /// Get user-friendly error message
  String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try again.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
