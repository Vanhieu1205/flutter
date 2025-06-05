import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_model.dart';
import '../../core/firebase/firebase_service.dart';

class ExpenseViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get userId => _auth.currentUser?.uid;

  Future<void> loadExpenses() async {
    if (userId == null) return; // Cannot load without a user
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _firebaseService.getExpenses(userId!);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    if (userId == null) return; // Cannot add without a user
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.addExpense(userId!, expense);
      _expenses.add(expense);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateExpense(Expense expense) async {
    if (userId == null) return; // Cannot update without a user
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.updateExpense(userId!, expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    if (userId == null) return; // Cannot delete without a user
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.deleteExpense(userId!, expenseId);
      _expenses.removeWhere((e) => e.id == expenseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
