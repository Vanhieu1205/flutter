import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'), // AppBar title for Dashboard
        backgroundColor: const Color(0xFF3ACBAB), // Consistent AppBar color
        automaticallyImplyLeading: false, // Hide back button on main screens
      ),
      body: Consumer2<IncomeViewModel, ExpenseViewModel>(
        builder: (context, incomeViewModel, expenseViewModel, child) {
          if (incomeViewModel.isLoading || expenseViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalIncome = incomeViewModel.incomes.fold<double>(
            0,
            (sum, income) => sum + income.amount,
          );

          final totalExpense = expenseViewModel.expenses.fold<double>(
            0,
            (sum, expense) => sum + expense.amount,
          );

          final balance = totalIncome - totalExpense;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(
                title: 'Total Balance',
                amount: balance,
                color: Colors.teal, // Use teal for balance as in design
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Income',
                      amount: totalIncome,
                      color: Colors.green, // Green for income
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ), // Spacing between income and expense cards
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Expense',
                      amount: totalExpense,
                      color: Colors.red, // Red for expense
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ), // Styled header
              ),
              const SizedBox(height: 16),
              _RecentTransactionsList(
                incomes: incomeViewModel.incomes,
                expenses: expenseViewModel.expenses,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Add subtle shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ), // Rounded corners
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
            ), // Subdued title
            const SizedBox(height: 8),
            Text(
              '${amount.toStringAsFixed(0)} VNĐ',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ), // Adjust text style for amount
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTransactionsList extends StatelessWidget {
  final List<dynamic> incomes;
  final List<dynamic> expenses;

  const _RecentTransactionsList({
    required this.incomes,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final allTransactions = [
      ...incomes.map(
        (income) => _Transaction(
          amount: income.amount,
          description: income.description,
          date: income.date,
          isIncome: true,
        ),
      ),
      ...expenses.map(
        (expense) => _Transaction(
          amount: expense.amount,
          description: expense.description,
          date: expense.date,
          isIncome: false,
        ),
      ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    if (allTransactions.isEmpty) {
      return const Center(
        child: Text('Chưa có giao dịch nào gần đây'),
      ); // Updated empty state text
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allTransactions.length > 5
          ? 5
          : allTransactions.length, // Show up to 5 recent transactions
      itemBuilder: (context, index) {
        final transaction = allTransactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8), // Adjust spacing
          elevation: 2, // Subtle shadow for list items
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: transaction.isIncome
                  ? Colors.green
                  : Colors.red, // Color based on type
              child: Icon(
                transaction.isIncome
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: Colors.white,
                size: 20, // Adjust icon size
              ),
            ),
            title: Text(
              transaction.description,
              style: Theme.of(context).textTheme.titleMedium,
            ), // Adjust text style
            subtitle: Text(
              '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
              style: Theme.of(context).textTheme.bodySmall, // Adjust text style
            ),
            trailing: Text(
              '${transaction.amount.toStringAsFixed(0)} VNĐ',
              style: TextStyle(
                color: transaction.isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16, // Adjust font size
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Transaction {
  final double amount;
  final String description;
  final DateTime date;
  final bool isIncome;

  _Transaction({
    required this.amount,
    required this.description,
    required this.date,
    required this.isIncome,
  });
}
