import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/expense_model.dart';
import 'package:intl/intl.dart';

class CSVService {
  Future<String?> exportExpensesToCSV(List<ExpenseModel> expenses) async {
    try {
      List<List<dynamic>> rows = [];

      // Add Header
      rows.add(["Date", "Title", "Category", "Amount"]);

      for (var expense in expenses) {
        List<dynamic> row = [];
        row.add(DateFormat('yyyy-MM-dd').format(expense.date));
        row.add(expense.title);
        row.add(expense.category);
        row.add(expense.amount);
        rows.add(row);
      }

      String csvData = const ListToCsvConverter().convert(rows);
      
      final directory = await getApplicationDocumentsDirectory();
      final path = "${directory.path}/expenses_export_${DateTime.now().millisecondsSinceEpoch}.csv";
      final file = File(path);
      
      await file.writeAsString(csvData);
      return path;
    } catch (e) {
      return null;
    }
  }
}
