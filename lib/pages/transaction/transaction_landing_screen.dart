import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/income_viewmodel.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../models/category_model.dart';
import '../../components/transaction_list_item.dart'; // Import reusable transaction item
import '../../models/category_model.dart' as models;

class TransactionLandingScreen extends StatelessWidget {
  const TransactionLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction'), // Updated AppBar title
        backgroundColor: const Color(0xFF3ACBAB), // Consistent AppBar color
        automaticallyImplyLeading: false, // Hide back button on main screens
      ),
      body: Consumer3<IncomeViewModel, ExpenseViewModel, CategoryViewModel>(
        builder: (context, incomeViewModel, expenseViewModel, categoryViewModel, child) {
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

          final totalBalance = totalIncome - totalExpense;

          // Combine incomes and expenses for recent transactions
          final allTransactions =
              [
                ...incomeViewModel.incomes.map(
                  (inc) => {
                    'type': 'income',
                    'data': inc,
                    'category': categoryViewModel.categories.firstWhere(
                      (cat) => cat.id == inc.categoryId,
                      orElse: () => models.Category(
                        id: '',
                        name: 'Unknown',
                        type: 'income',
                        color: Colors.grey.value.toString(),
                        icon: Icons.category.codePoint.toString(),
                      ),
                    ),
                  },
                ),
                ...expenseViewModel.expenses.map(
                  (exp) => {
                    'type': 'expense',
                    'data': exp,
                    'category': categoryViewModel.categories.firstWhere(
                      (cat) => cat.id == exp.categoryId,
                      orElse: () => models.Category(
                        id: '',
                        name: 'Unknown',
                        type: 'expense',
                        color: Colors.grey.value.toString(),
                        icon: Icons.category.codePoint.toString(),
                      ),
                    ),
                  },
                ),
              ]..sort(
                (a, b) => (b['data'] as dynamic).date.compareTo(
                  (a['data'] as dynamic).date,
                ),
              );

          // Show only the most recent 5 transactions
          final recentTransactions = allTransactions.take(5).toList();

          return ListView(
            padding: const EdgeInsets.all(16), // Adjust padding
            children: [
              // Total Balance Display
              Card(
                margin: const EdgeInsets.only(bottom: 16), // Spacing
                elevation: 4, // Subtle shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Balance', // Label
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${totalBalance.toStringAsFixed(0)} VNĐ', // Display balance
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.teal, // Use teal for balance
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16), // Spacing
              // Income and Expense Navigation Buttons/Cards
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Distribute space
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/addIncome', // Navigate to Add Income
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Income color
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ), // Adjust padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            30.0,
                          ), // Rounded corners
                        ),
                      ),
                      child: const Column(
                        // Use Column for icon and text
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Add icon and text
                          Icon(Icons.arrow_upward, size: 24), // Income icon
                          SizedBox(height: 4), // Spacing
                          Text(
                            'Income',
                            style: TextStyle(fontSize: 16),
                          ), // Label
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // Spacing between buttons
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/addExpense', // Navigate to Add Expense
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red, // Expense color
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ), // Adjust padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            30.0,
                          ), // Rounded corners
                        ),
                      ),
                      child: const Column(
                        // Use Column for icon and text
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Add icon and text
                          Icon(Icons.arrow_downward, size: 24), // Expense icon
                          SizedBox(height: 4), // Spacing
                          Text(
                            'Expense',
                            style: TextStyle(fontSize: 16),
                          ), // Label
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24), // Spacing
              // Recent Transactions List
              const Text(
                'Recent Transactions', // Header
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ), // Styled header
              ),
              const SizedBox(height: 16), // Spacing
              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable scrolling for this nested list
                itemCount: recentTransactions.length,
                itemBuilder: (context, index) {
                  final transactionData = recentTransactions[index];
                  final transaction = transactionData['data'];
                  final category = transactionData['category'] as Category?;
                  // Use the reusable TransactionListItem
                  return TransactionListItem(
                    transaction: transaction,
                    category: category,
                    dismissibleKey: Key((transaction as dynamic).id),
                    onTap: () {
                      // Navigate to edit screen based on type
                      if (transactionData['type'] == 'income') {
                        Navigator.pushNamed(
                          context,
                          '/editIncome',
                          arguments: transaction,
                        );
                      } else {
                        Navigator.pushNamed(
                          context,
                          '/editExpense',
                          arguments: transaction,
                        );
                      }
                    },
                    // Implement onDismissed if needed, but typically delete is on edit screen
                    // onDismissed: (direction) { ... },
                  );
                },
              ),
              if (recentTransactions
                  .isEmpty) // Display message if no recent transactions
                const Center(child: Text('No recent transactions')),
            ],
          );
        },
      ),
    );
  }
}
