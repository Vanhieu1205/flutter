import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category_model.dart' as models;
import '../../core/firebase/firebase_service.dart';

class CategoryViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<models.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<models.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get userId => _auth.currentUser?.uid;
  // chức năng này sẽ lấy userId từ FirebaseAuth
  
  Future<void> loadCategories() async {
    if (userId == null) return; // Cannot load without a user
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _firebaseService.getCategories(userId!);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addCategory(models.Category category) async {
    if (userId == null) return; // Cannot add without a user
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.addCategory(userId!, category);
      _categories.add(category);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(models.Category category) async {
    if (userId == null) return; // Cannot update without a user
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.updateCategory(userId!, category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    if (userId == null) return; // Cannot delete without a user
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firebaseService.deleteCategory(userId!, categoryId);
      _categories.removeWhere((c) => c.id == categoryId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
