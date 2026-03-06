import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'config/firebase_options.dart';
import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/prediction_provider.dart';
import 'providers/security_provider.dart';
import 'widgets/lock_screen.dart';
import 'routes/app_routes.dart';
import 'screens/auth/splash_screen.dart';
import 'services/local_db_service.dart';
import 'widgets/error_boundary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Platform-specific initialization
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await _initializeServices();

  runApp(const SmartExpenseApp());
}

Future<void> _initializeServices() async {
  try {
    if (_isFirebaseSupported()) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    await LocalDBService().initDatabase();
  } catch (e) {
    debugPrint('Critical Initialization Error: $e');
  }
}

bool _isFirebaseSupported() {
  if (kIsWeb) return true;
  return Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isMacOS ||
      Platform.isWindows;
}

class SmartExpenseApp extends StatelessWidget {
  const SmartExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => PredictionProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Expense Analyzer',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: AppRoutes.routes,
        // Senior level: Using a dedicated Error Boundary and Security Wrap
        builder: (context, child) {
          // Use SecurityProvider to determine if the app should be locked
          return Consumer<SecurityProvider>(
            builder: (context, security, _) {
              // Wrap with Error Boundary
              final appWidget = ErrorBoundary(
                child: child ?? const SizedBox.shrink(),
              );

              // Only display lock screen if locked
              return Stack(
                children: [
                  appWidget,
                  if (security.isLocked) const LockScreen(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
