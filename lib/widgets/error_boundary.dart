import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// A wrapper that sets up global error handling for the app.
class ErrorBoundary extends StatelessWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  /// Call this in your main() function before runApp()
  static void init() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Use Material/Container instead of Scaffold here. 
      // If the error happens before a Navigator is present, Scaffold will fail.
      return Material(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Only show technical details in debug mode
                if (kDebugMode)
                  Text(
                    details.exception.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 12, fontFamily: 'monospace'),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Logic to restart app (this usually requires a Phoenix wrapper 
                    // or simply popping to the first route)
                  },
                  child: const Text('Return to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    // This widget now simply returns its child because 
    // the ErrorWidget.builder is handled globally.
    return child;
  }
}