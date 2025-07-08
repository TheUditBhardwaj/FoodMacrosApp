// models/food_item.dart
class FoodItem {
  final String id;
  final String name;
  final String displayName;
  final double confidence;
  final NutritionData nutrition;
  final String? imagePath;
  final DateTime analyzedAt;

  FoodItem({
    required this.id,
    required this.name,
    required this.displayName,
    required this.confidence,
    required this.nutrition,
    this.imagePath,
    DateTime? analyzedAt,
  }) : analyzedAt = analyzedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'confidence': confidence,
      'nutrition': nutrition.toJson(),
      'imagePath': imagePath,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      displayName: json['displayName'],
      confidence: json['confidence'].toDouble(),
      nutrition: NutritionData.fromJson(json['nutrition']),
      imagePath: json['imagePath'],
      analyzedAt: DateTime.parse(json['analyzedAt']),
    );
  }
}

class NutritionData {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final String servingSize;

  NutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.servingSize,
  });

  Map<String, double> get macroPercentages {
    double proteinCal = protein * 4;
    double carbsCal = carbs * 4;
    double fatCal = fat * 9;
    double totalMacroCal = proteinCal + carbsCal + fatCal;

    if (totalMacroCal == 0) {
      return {'protein': 0, 'carbs': 0, 'fat': 0};
    }

    return {
      'protein': (proteinCal / totalMacroCal) * 100,
      'carbs': (carbsCal / totalMacroCal) * 100,
      'fat': (fatCal / totalMacroCal) * 100,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'servingSize': servingSize,
    };
  }

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      calories: json['calories'].toDouble(),
      protein: json['protein'].toDouble(),
      carbs: json['carbs'].toDouble(),
      fat: json['fat'].toDouble(),
      fiber: json['fiber'].toDouble(),
      sugar: json['sugar'].toDouble(),
      servingSize: json['servingSize'],
    );
  }
}
