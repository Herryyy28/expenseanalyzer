import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/expense_model.dart';

class EditExpenseScreen extends StatefulWidget {
  final ExpenseModel expense;
  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  late TextEditingController titleCtrl;
  late TextEditingController amountCtrl;

  @override
  void initState() {
    titleCtrl = TextEditingController(text: widget.expense.title);
    amountCtrl =
        TextEditingController(text: widget.expense.amount.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleCtrl),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Update"),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collectionGroup('expenses')
                    .where(FieldPath.documentId,
                    isEqualTo: widget.expense.id)
                    .get();

                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
