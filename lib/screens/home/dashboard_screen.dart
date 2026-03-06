import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/budget_alert_widget.dart';
import '../../models/expense_model.dart';
import '../../providers/security_provider.dart';
import '../../widgets/budget_progress_card.dart';
import '../../services/csv_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final securityProvider = Provider.of<SecurityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manager Dashboard"),
        actions: [
          IconButton(
            icon: Icon(
              securityProvider.biometricsEnabled ? Icons.lock : Icons.lock_open,
              color: securityProvider.biometricsEnabled
                  ? Colors.green
                  : Colors.grey,
            ),
            tooltip: 'Security Settings',
            onPressed: () {
              // Toggle biometrics for demo purposes
              securityProvider.toggleBiometrics(
                !securityProvider.biometricsEnabled,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Biometric Lock ${!securityProvider.biometricsEnabled ? 'Disabled' : 'Enabled'}',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const BudgetAlertWidget(),
            StreamBuilder<List<ExpenseModel>>(
              stream: expenseProvider.expenses,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final expenses = snapshot.data ?? [];
                final total = expenses.fold<double>(
                  0.0,
                  (sum, e) => sum + e.amount,
                );

                return Column(
                  children: [
                    _buildSpendingCard(context, total),
                    const BudgetProgressCard(),
                    _buildShortcuts(context, expenses),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpendingCard(BuildContext context, double total) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "This Month Spending",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              "₹${total.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcuts(BuildContext context, List<ExpenseModel> expenses) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ShortcutButton(
                  icon: Icons.auto_awesome,
                  label: "AI Prediction",
                  color: Colors.amber.shade700,
                  onTap: () => Navigator.pushNamed(context, '/prediction'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ShortcutButton(
                  icon: Icons.file_download,
                  label: "Export CSV",
                  color: Colors.teal,
                  onTap: () async {
                    final path = await CSVService().exportExpensesToCSV(
                      expenses,
                    );
                    if (path != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Report saved: $path')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ShortcutButton(
                  icon: Icons.security,
                  label: "Privacy Blur",
                  color: Colors.blueGrey,
                  onTap: () {
                    final sp = Provider.of<SecurityProvider>(
                      context,
                      listen: false,
                    );
                    sp.updatePrivacy(true);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ShortcutButton(
                  icon: Icons.settings,
                  label: "Budgets",
                  color: Colors.deepPurple,
                  onTap: () => Navigator.pushNamed(context, '/budget'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShortcutButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
