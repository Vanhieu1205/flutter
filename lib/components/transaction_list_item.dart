import 'package:flutter/material.dart';
import '../models/income_model.dart'; // Assuming Income model is needed
import '../models/expense_model.dart'; // Assuming Expense model is needed
import '../models/category_model.dart';

// A simple union type or interface could be used if transactions were more complex.
// For now, we'll handle Income and Expense directly or use a common structure.
// Reusing the _Transaction concept from dashboard_screen.dart seems practical.

class TransactionListItem extends StatelessWidget {
  final dynamic transaction; // Can be Income or Expense model
  final VoidCallback? onTap;
  final DismissDirectionCallback? onDismissed;
  final Key dismissibleKey;
  final Category? category;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDismissed,
    required this.dismissibleKey,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if it's an income or expense
    final bool isIncome = transaction is Income;
    final double amount = transaction.amount;
    final String description = transaction.description;
    final DateTime date = transaction.date;
    // Access id based on the actual type
    final String transactionId = transaction.id;

    return Dismissible(
      key: dismissibleKey,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red, // Swipe to delete color
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: onDismissed,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8), // Adjust spacing
        elevation: 2, // Subtle shadow
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: category?.color != null
                ? Color(int.parse(category!.color))
                : (isIncome ? Colors.green : Colors.red),
            child: Icon(
              category?.icon != null
                  ? Icons
                        .category // Use a constant icon instead of dynamic IconData
                  : (isIncome ? Icons.arrow_upward : Icons.arrow_downward),
              color: Colors.white,
              size: 20, // Adjust icon size
            ),
          ),
          title: Text(
            description,
            style: Theme.of(context).textTheme.titleMedium,
          ), // Adjust text style
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (category != null)
                Text(
                  category!.name,
                  style: TextStyle(
                    color: Color(int.parse(category!.color)),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall, // Adjust text style
              ),
            ],
          ),
          trailing: Text(
            '${amount.toStringAsFixed(0)} VNĐ',
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16, // Adjust font size
            ),
          ),
        ),
      ),
    );
  }
}
