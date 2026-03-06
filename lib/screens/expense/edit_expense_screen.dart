import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';

class EditExpenseScreen extends StatefulWidget {
  final ExpenseModel expense;
  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _amountCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.expense.title);
    _amountCtrl = TextEditingController(text: widget.expense.amount.toString());
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateExpense() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (_titleCtrl.text.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid details')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Note: We'll need to add an updateExpense method to ExpenseProvider
      // For now, let's use the delete + add approach or implement update in provider
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      
      // Since updateExpense isn't in provider yet, I'll delete and re-add or we update provider
      // Let's assume we'll fix provider next
      await provider.deleteExpense(widget.expense.id);
      await provider.addExpense(_titleCtrl.text, amount);
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Expense")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Amount",
                prefixText: "₹ ",
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _updateExpense,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text("Update Expense"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
