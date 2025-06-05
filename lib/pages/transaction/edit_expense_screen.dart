import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/expense_viewmodel.dart';
import '../../viewmodels/category_viewmodel.dart';
import '../../models/expense_model.dart';
import '../../models/category_model.dart' as models;

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.expense.amount.toStringAsFixed(0),
    );
    _descriptionController = TextEditingController(
      text: widget.expense.description,
    );
    _selectedDate = widget.expense.date;
    _selectedCategoryId = widget.expense.categoryId;

    // Fetch categories when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().loadCategories();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _deleteExpense() async {
    // Add confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // Dismiss and return false
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(true), // Dismiss and return true
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      context.read<ExpenseViewModel>().deleteExpense(widget.expense.id);
      Navigator.pop(context); // Pop edit screen after deleting
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense deleted successfully!')),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedExpense = Expense(
        id: widget.expense.id,
        categoryId: _selectedCategoryId,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        date: _selectedDate,
        userId: widget.expense.userId,
      );

      context.read<ExpenseViewModel>().updateExpense(updatedExpense);
      Navigator.pop(context); // Pop edit screen after saving
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EDIT EXPENSE'), // Updated title
        backgroundColor: Colors.teal, // Consistent AppBar color
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.white,
            ), // Styled delete icon
            onPressed: _deleteExpense,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24), // Increased padding
          children: [
            Consumer<CategoryViewModel>(
              builder: (context, categoryViewModel, child) {
                if (categoryViewModel.isLoading) {
                  return const CircularProgressIndicator();
                }

                if (categoryViewModel.error != null) {
                  return Text(
                    'Error loading categories: ${categoryViewModel.error}',
                  );
                }

                final expenseCategories = categoryViewModel.categories
                    .where((category) => category.type == 'expense')
                    .toList();

                // Find the currently selected category to ensure it exists in the dropdown
                final selectedCategory = expenseCategories.firstWhere(
                  (category) => category.id == _selectedCategoryId,
                  orElse: () => expenseCategories.isNotEmpty
                      ? expenseCategories.first
                      : null
                            as models.Category, // Handle case where category is not found or list is empty
                );

                return DropdownButtonFormField<String>(
                  value: selectedCategory
                      ?.id, // Use the found category's id or null
                  decoration: InputDecoration(
                    labelText: 'Choose Category', // Updated label
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  items: expenseCategories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount', // Updated label
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                prefixText: 'VNĐ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description', // Updated label
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date', // Updated label
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontSize: 16), // Style date text
                    ),
                    Icon(Icons.calendar_today, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Button color
                foregroundColor: Colors.white, // Text color
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontSize: 18),
              ), // Updated label and size
            ),
            const SizedBox(height: 16), // Space between buttons
            OutlinedButton(
              onPressed: _deleteExpense,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red, // Text color
                side: const BorderSide(color: Colors.red), // Border color
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                minimumSize: const Size(
                  double.infinity,
                  50,
                ), // Full width button
              ),
              child: const Text(
                'Delete Expense',
                style: TextStyle(fontSize: 18),
              ), // Updated label and size
            ),
          ],
        ),
      ),
    );
  }
}
