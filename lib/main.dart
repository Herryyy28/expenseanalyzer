import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'config/firebase_options.dart';
import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/budget_provider.dart';
import 'providers/prediction_provider.dart';
import 'routes/app_routes.dart';
import 'screens/auth/splash_screen.dart';
import 'services/local_db_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for Windows/Linux
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  try {
    // Initialize Firebase only on supported platforms
    if (_isFirebaseSupported()) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('✅ Firebase initialized successfully');
    } else {
      debugPrint('⚠️ Firebase not supported on this platform. Using local storage only.');
    }

    // Initialize local database
    await LocalDBService().initDatabase();
    debugPrint('✅ Local database initialized');

  } catch (e, stackTrace) {
    debugPrint('❌ Initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  runApp(const SmartExpenseApp());
}

/// Check if Firebase is supported on the current platform
bool _isFirebaseSupported() {
  if (kIsWeb) return true;

  try {
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows;
  } catch (e) {
    return false;
  }
}

class SmartExpenseApp extends StatelessWidget {
  const SmartExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<ExpenseProvider>(
          create: (_) => ExpenseProvider(),
        ),
        ChangeNotifierProvider<BudgetProvider>(
          create: (_) => BudgetProvider(),
        ),
        ChangeNotifierProvider<PredictionProvider>(
          create: (_) => PredictionProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Expense Analyzer',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: AppRoutes.routes,
        builder: (context, widget) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return _CustomErrorWidget(errorDetails: errorDetails);
          };
          return widget ?? const SizedBox.shrink();
        },
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const _NotFoundScreen(),
          );
        },
      ),
    );
  }
}

class _CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;
  const _CustomErrorWidget({required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                Text(errorDetails.exception.toString(), style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 100, color: Colors.grey),
            const Text('404', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.home),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
