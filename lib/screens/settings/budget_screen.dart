import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/budget_model.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _amountCtrl = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Food',
    'Travel',
    'Shopping',
    'Health',
    'Bills',
    'Other',
  ];

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _showAddBudgetDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add/Update Budget",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
              decoration: const InputDecoration(labelText: "Category"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Monthly Limit",
                prefixText: "₹ ",
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(_amountCtrl.text);
                  if (amount != null) {
                    final userId = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).userId;
                    if (userId != null) {
                      final budget = BudgetModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userId: userId,
                        category: _selectedCategory,
                        limitAmount: amount,
                        startDate: DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          1,
                        ),
                        endDate: DateTime(
                          DateTime.now().year,
                          DateTime.now().month + 1,
                          0,
                        ),
                      );
                      Provider.of<BudgetProvider>(
                        context,
                        listen: false,
                      ).setBudget(budget);
                      _amountCtrl.clear();
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text("Set Budget"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Budget Planner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddBudgetDialog,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.budgets.isEmpty
          ? const Center(child: Text("No budgets set yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.budgets.length,
              itemBuilder: (context, index) {
                final budget = provider.budgets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    title: Text(
                      budget.category,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Limit: ₹${budget.limitAmount}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => provider.removeBudget(budget.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBudgetDialog,
        label: const Text("Add Budget"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
