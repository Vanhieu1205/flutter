import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../models/expense_model.dart';
import '../../components/transaction_list_item.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ExpenseViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(child: Text('Error: ${viewModel.error}'));
          }

          if (viewModel.expenses.isEmpty) {
            return const Center(child: Text('Chưa có khoản chi tiêu nào'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.expenses.length,
            itemBuilder: (context, index) {
              final expense = viewModel.expenses[index];
              return TransactionListItem(
                transaction: expense,
                dismissibleKey: Key(expense.id),
                onDismissed: (direction) {
                  viewModel.deleteExpense(expense.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa khoản chi tiêu'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/editExpense',
                    arguments: expense,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addExpense');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
