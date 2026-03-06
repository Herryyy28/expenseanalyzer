import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../../providers/expense_provider.dart';
import '../../services/ocr_service.dart';
import 'dart:io' show Platform;

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _ocrService = OCRService();
  bool _isSaving = false;
  bool _isScanning = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _scanReceipt() async {
    if (kIsWeb || (Platform.isWindows || Platform.isLinux)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt scan only available on Mobile.')),
      );
      return;
    }

    setState(() => _isScanning = true);
    final result = await _ocrService.scanReceipt();
    if (result != null) {
      if (result['merchant'] != null) _titleCtrl.text = result['merchant'];
      if (result['amount'] != null)
        _amountCtrl.text = result['amount'].toString();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data extracted! 🎉')));
      }
    }
    setState(() => _isScanning = false);
  }

  Future<void> _saveExpense() async {
    if (_titleCtrl.text.isEmpty || _amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      await provider.addExpense(_titleCtrl.text, amount);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Expense"),
        actions: [
          if (_isScanning)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.receipt_long),
              tooltip: "Scan Receipt",
              onPressed: _scanReceipt,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: "Expense Title",
                hintText: "e.g. Grocery, Pizza",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Amount",
                prefixText: "₹ ",
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveExpense,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Add Expense"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
