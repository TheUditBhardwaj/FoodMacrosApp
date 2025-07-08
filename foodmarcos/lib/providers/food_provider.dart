import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/database_service.dart';

class FoodProvider extends ChangeNotifier {
  List<FoodItem> _recentAnalyses = [];
  bool _isLoading = false;
  FoodItem? _currentFood;

  List<FoodItem> get recentAnalyses => _recentAnalyses;
  bool get isLoading => _isLoading;
  FoodItem? get currentFood => _currentFood;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setCurrentFood(FoodItem? food) {
    _currentFood = food;
    notifyListeners();
  }

  Future<void> addFoodAnalysis(FoodItem food) async {
    await DatabaseService.saveFoodAnalysis(food);
    _recentAnalyses.insert(0, food);
    if (_recentAnalyses.length > 20) {
      _recentAnalyses = _recentAnalyses.take(20).toList();
    }
    notifyListeners();
  }

  Future<void> loadRecentAnalyses() async {
    _recentAnalyses = await DatabaseService.getRecentAnalyses();
    notifyListeners();
  }
}