import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/local_db_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
  loading,
}

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final LocalDBService _localDBService = LocalDBService();

  AuthStatus _status = AuthStatus.uninitialized;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoggedIn => isAuthenticated; // Added for compatibility with UI
  String? get userId => _user?.uid;
  String? get userEmail => _user?.email;
  String? get userDisplayName => _user?.displayName;
  String? get userPhotoURL => _user?.photoURL;

  AuthProvider() {
    _initializeAuth();
  }

  /// Initialize authentication state
  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) {
      if (user == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
      } else {
        _status = AuthStatus.authenticated;
        _user = user;
        _syncUserData();
      }
      notifyListeners();
    });
  }

  /// Sync user data between Firestore and local DB
  Future<void> _syncUserData() async {
    if (_user == null) return;

    try {
      // Save/update user in Firestore
      await _firestoreService.createOrUpdateUser(
        userId: _user!.uid,
        email: _user!.email ?? '',
        name: _user!.displayName,
      );

      // Save/update user in local DB
      debugPrint('✅ User data synced successfully');
    } catch (e) {
      debugPrint('❌ Error syncing user data: $e');
    }
  }

  // ==================== SIGN IN ====================

  /// Sign in with Google (aliased as login for UI compatibility)
  Future<bool> login() async {
    return await signInWithGoogle();
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    return await _performAuthAction(() async {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        await _syncUserData();
        return true;
      }
      return false;
    }, 'Google sign-in');
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _performAuthAction(() async {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        await _syncUserData();
        return true;
      }
      return false;
    }, 'Email sign-in');
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    return await _performAuthAction(() async {
      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        await _syncUserData();
        return true;
      }
      return false;
    }, 'Email sign-up');
  }

  // ==================== SIGN OUT ====================

  /// Sign out
  Future<void> signOut() async {
    await _performAuthAction(() async {
      await _authService.signOut();

      // Clear local data
      await _localDBService.clearAllData();

      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;

      debugPrint('✅ User signed out and local data cleared');
      return true;
    }, 'Sign out');
  }

  // ==================== PASSWORD MANAGEMENT ====================

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    return await _performAuthAction(() async {
      await _authService.sendPasswordResetEmail(email);
      return true;
    }, 'Password reset');
  }

  /// Update password
  Future<bool> updatePassword(String newPassword) async {
    return await _performAuthAction(() async {
      await _authService.updatePassword(newPassword);
      return true;
    }, 'Update password');
  }

  // ==================== USER PROFILE ====================

  /// Update display name
  Future<bool> updateDisplayName(String displayName) async {
    return await _performAuthAction(() async {
      await _authService.updateDisplayName(displayName);
      _user = _authService.currentUser;
      await _syncUserData();
      return true;
    }, 'Update display name');
  }

  /// Update email
  Future<bool> updateEmail(String newEmail) async {
    return await _performAuthAction(() async {
      await _authService.updateEmail(newEmail);
      return true;
    }, 'Update email');
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    return await _performAuthAction(() async {
      await _authService.deleteAccount();
      await _localDBService.clearAllData();
      _user = null;
      _status = AuthStatus.unauthenticated;
      return true;
    }, 'Delete account');
  }

  // ==================== REAUTHENTICATION ====================

  /// Reauthenticate with email/password
  Future<bool> reauthenticateWithEmail({
    required String email,
    required String password,
  }) async {
    return await _performAuthAction(() async {
      await _authService.reauthenticateWithEmail(
        email: email,
        password: password,
      );
      return true;
    }, 'Reauthentication');
  }

  /// Reauthenticate with Google
  Future<bool> reauthenticateWithGoogle() async {
    return await _performAuthAction(() async {
      await _authService.reauthenticateWithGoogle();
      return true;
    }, 'Reauthentication with Google');
  }

  // ==================== HELPER METHODS ====================

  /// Generic method to perform auth actions with loading state and error handling
  Future<bool> _performAuthAction(
      Future<bool> Function() action,
      String actionName,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await action();
      _setLoading(false);
      return result;
    } on FirebaseAuthException catch (e) {
      _setError(_authService.getErrorMessage(e));
      _setLoading(false);
      debugPrint('❌ $actionName failed: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      _setLoading(false);
      debugPrint('❌ $actionName failed: $e');
      return false;
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _status = AuthStatus.loading;
    }
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error manually (for UI)
  void clearError() {
    _clearError();
  }

  /// Reload current user data
  Future<void> reloadUser() async {
    if (_user != null) {
      await _user!.reload();
      _user = _authService.currentUser;
      notifyListeners();
    }
  }

  /// Check if email is verified
  bool get isEmailVerified => _user?.emailVerified ?? false;

  /// Send email verification
  Future<bool> sendEmailVerification() async {
    return await _performAuthAction(() async {
      await _user?.sendEmailVerification();
      return true;
    }, 'Send email verification');
  }
}
