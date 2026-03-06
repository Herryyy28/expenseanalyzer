import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';

import '../screens/analytics/prediction_screen.dart';

import '../screens/settings/budget_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/home': (_) => const HomeScreen(),
    '/prediction': (_) => const PredictionScreen(),
    '/budget': (_) => const BudgetScreen(),
  };
}
