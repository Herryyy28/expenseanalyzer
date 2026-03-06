import 'package:flutter/material.dart';
import '../services/security_service.dart';

class SecurityProvider extends ChangeNotifier {
  final SecurityService _securityService = SecurityService();
  bool _isLocked = false;
  bool _biometricsEnabled = false;

  bool get isLocked => _isLocked;
  bool get biometricsEnabled => _biometricsEnabled;

  SecurityProvider() {
    _init();
  }

  Future<void> _init() async {
    _biometricsEnabled = await _securityService.isBiometricsEnabled();
    final bool hardwareAvailable = await _securityService.isBiometricsAvailable;

    // Only lock if biometrics enabled AND hardware is actually available
    if (_biometricsEnabled && hardwareAvailable) {
      _isLocked = true;
    } else if (_biometricsEnabled && !hardwareAvailable) {
      // Direct open if biometrics are "enabled" but hardware isn't ready
      // This is common after migrating from phone to PC.
      debugLog(
        'Biometrics enabled but hardware not available - direct opening.',
      );
      _isLocked = false;
    }
    notifyListeners();
  }

  void debugLog(String message) => debugPrint('SecurityProvider: $message');

  Future<void> unlock() async {
    if (!_biometricsEnabled) {
      _isLocked = false;
      notifyListeners();
      return;
    }

    final success = await _securityService.authenticate();
    if (success) {
      _isLocked = false;
      notifyListeners();
    }
  }

  Future<void> toggleBiometrics(bool value) async {
    await _securityService.setBiometricsEnabled(value);
    _biometricsEnabled = value;
    notifyListeners();
  }

  /// Lock app on background / logout
  void lock() {
    if (_biometricsEnabled) {
      _isLocked = true;
      notifyListeners();
    }
  }

  /// Enable screen privacy
  Future<void> updatePrivacy(bool enabled) async {
    await _securityService.setSecureScreen(enabled);
  }
}
