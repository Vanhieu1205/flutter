import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../../models/income_model.dart';
import '../../components/transaction_list_item.dart';

class IncomeListScreen extends StatelessWidget {
  const IncomeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<IncomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(child: Text('Error: ${viewModel.error}'));
          }

          if (viewModel.incomes.isEmpty) {
            return const Center(child: Text('Chưa có khoản thu nhập nào'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.incomes.length,
            itemBuilder: (context, index) {
              final income = viewModel.incomes[index];
              return TransactionListItem(
                transaction: income,
                dismissibleKey: Key(income.id),
                onDismissed: (direction) {
                  viewModel.deleteIncome(income.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa khoản thu nhập'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/editIncome',
                    arguments: income,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addIncome');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class IncomeCard extends StatelessWidget {
  final Income income;

  const IncomeCard({super.key, required this.income});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${income.amount.toStringAsFixed(0)} VNĐ',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDate(income.date),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              income.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
