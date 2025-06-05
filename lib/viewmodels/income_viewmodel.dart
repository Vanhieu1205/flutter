import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/income_model.dart';
import '../../core/firebase/firebase_service.dart';

class IncomeViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Income> _incomes = [];
  bool _isLoading = false;
  String? _error;

  List<Income> get incomes => _incomes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get userId => _auth.currentUser?.uid;

  Future<void> loadIncomes() async {
    if (userId == null) return; // Cannot load without a user
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _incomes = await _firebaseService.getIncomes(userId!);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addIncome(Income income) async {
    if (userId == null) return; // Cannot add without a user
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.addIncome(userId!, income);
      _incomes.add(income);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateIncome(Income income) async {
    if (userId == null) return; // Cannot update without a user
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.updateIncome(userId!, income);
      final index = _incomes.indexWhere((i) => i.id == income.id);
      if (index != -1) {
        _incomes[index] = income;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteIncome(String incomeId) async {
    if (userId == null) return; // Cannot delete without a user
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.deleteIncome(userId!, incomeId);
      _incomes.removeWhere((i) => i.id == incomeId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
