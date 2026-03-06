import 'package:intl/intl.dart';

class Utils {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatCurrency(double amount) {
    return "₹${amount.toStringAsFixed(2)}";
  }
}
