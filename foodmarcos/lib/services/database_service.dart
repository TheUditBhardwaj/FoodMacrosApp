import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/food_item.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'food_macros.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE food_analyses(id TEXT PRIMARY KEY, name TEXT, display_name TEXT, confidence REAL, calories REAL, protein REAL, carbs REAL, fat REAL, fiber REAL, sugar REAL, serving_size TEXT, image_path TEXT, analyzed_at TEXT)',
        );
      },
    );
  }

  static Future<void> saveFoodAnalysis(FoodItem food) async {
    final db = await database;
    await db.insert(
      'food_analyses',
      {
        'id': food.id,
        'name': food.name,
        'display_name': food.displayName,
        'confidence': food.confidence,
        'calories': food.nutrition.calories,
        'protein': food.nutrition.protein,
        'carbs': food.nutrition.carbs,
        'fat': food.nutrition.fat,
        'fiber': food.nutrition.fiber,
        'sugar': food.nutrition.sugar,
        'serving_size': food.nutrition.servingSize,
        'image_path': food.imagePath,
        'analyzed_at': food.analyzedAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<FoodItem>> getRecentAnalyses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'food_analyses',
      orderBy: 'analyzed_at DESC',
      limit: 20,
    );

    return List.generate(maps.length, (i) {
      return FoodItem(
        id: maps[i]['id'],
        name: maps[i]['name'],
        displayName: maps[i]['display_name'],
        confidence: maps[i]['confidence'],
        nutrition: NutritionData(
          calories: maps[i]['calories'],
          protein: maps[i]['protein'],
          carbs: maps[i]['carbs'],
          fat: maps[i]['fat'],
          fiber: maps[i]['fiber'],
          sugar: maps[i]['sugar'],
          servingSize: maps[i]['serving_size'],
        ),
        imagePath: maps[i]['image_path'],
        analyzedAt: DateTime.parse(maps[i]['analyzed_at']),
      );
    });
  }
}