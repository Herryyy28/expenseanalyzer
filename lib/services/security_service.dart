import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  final LocalAuthentication _auth = LocalAuthentication();
  static const String _biometricKey = 'use_biometrics';

  /// Check if the device has biometrics hardware and it's enabled
  Future<bool> get isBiometricsAvailable async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      debugPrint('Biometrics availability check error: $e');
      return false;
    }
  }

  /// Get user's preference for biometrics
  Future<bool> isBiometricsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricKey) ?? false;
  }

  /// Set user's preference for biometrics
  Future<void> setBiometricsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricKey, enabled);
  }

  /// Perform authentication
  Future<bool> authenticate() async {
    try {
      // Platform-specific options: Windows doesn't support biometricOnly: true
      // and behaves better with it set to false for fallback (PIN/Password).
      final bool isWindows = Platform.isWindows;

      return await _auth.authenticate(
        localizedReason: 'Please authenticate to view your financial data',
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: !isWindows, // Fallback to PIN/Password on Windows
        ),
      );
    } catch (e) {
      debugPrint('Authentication error: $e');
      return false;
    }
  }

  /// ENHANCED PRIVACY: Prevent app snapshots and screen recording (Android only)
  /// This is a "Senior Level" requirement for financial apps.
  Future<void> setSecureScreen(bool enabled) async {
    if (Platform.isAndroid) {
      if (enabled) {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      } else {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      }
    }
  }
}
