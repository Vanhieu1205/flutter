import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/category_model.dart';
import '../../models/income_model.dart';
import '../../models/expense_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Category Operations
  Future<List<Category>> getCategories(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .get();
    return snapshot.docs.map((doc) => Category.fromMap(doc.data())).toList();
  }

  Future<void> addCategory(String userId, Category category) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(category.id)
        .set(category.toMap());
  }

  Future<void> updateCategory(String userId, Category category) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(category.id)
        .update(category.toMap());
  }

  Future<void> deleteCategory(String userId, String categoryId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }

  // Income Operations
  Future<List<Income>> getIncomes(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('incomes')
        .get();
    return snapshot.docs.map((doc) => Income.fromMap(doc.data())).toList();
  }

  Future<void> addIncome(String userId, Income income) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('incomes')
        .doc(income.id)
        .set(income.toMap());
  }

  Future<void> updateIncome(String userId, Income income) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('incomes')
        .doc(income.id)
        .update(income.toMap());
  }

  Future<void> deleteIncome(String userId, String incomeId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('incomes')
        .doc(incomeId)
        .delete();
  }

  // Expense Operations
  Future<List<Expense>> getExpenses(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .get();
    return snapshot.docs.map((doc) => Expense.fromMap(doc.data())).toList();
  }

  Future<void> addExpense(String userId, Expense expense) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expense.id)
        .set(expense.toMap());
  }

  Future<void> updateExpense(String userId, Expense expense) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expense.id)
        .update(expense.toMap());
  }

  Future<void> deleteExpense(String userId, String expenseId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }
}
