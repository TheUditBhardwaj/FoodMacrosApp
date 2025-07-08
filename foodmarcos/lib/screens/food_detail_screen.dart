import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import '../models/food_item.dart';
import '../widgets/macro_chart.dart';

class FoodDetailScreen extends StatefulWidget {
  final List<FoodItem> foodItems;
  final File? imageFile;

  const FoodDetailScreen({
    Key? key,
    required this.foodItems,
    this.imageFile,
  }) : super(key: key);

  @override
  _FoodDetailScreenState createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.foodItems.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Food Details')),
        body: Center(child: Text('No food data available')),
      );
    }

    FoodItem selectedFood = widget.foodItems[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedFood.displayName),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Section
            if (widget.imageFile != null)
              Container(
                width: double.infinity,
                height: 200,
                child: Image.file(
                  widget.imageFile!,
                  fit: BoxFit.cover,
                ),
              ),

            // Food Selection (if multiple predictions)
            if (widget.foodItems.length > 1)
              Container(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: widget.foodItems.length,
                  itemBuilder: (context, index) {
                    FoodItem food = widget.foodItems[index];
                    bool isSelected = index == _selectedIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 8),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              food.displayName,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${(food.confidence * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Confidence Score
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.verified, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Confidence: ${(selectedFood.confidence * 100).toStringAsFixed(1)}%',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Macro Chart
                  Text(
                    'Macro Distribution',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 200,
                    child: MacroChart(nutrition: selectedFood.nutrition),
                  ),

                  SizedBox(height: 24),

                  // Nutrition Details
                  Text(
                    'Nutrition Facts',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),

                  _buildNutritionCard(selectedFood.nutrition),

                  SizedBox(height: 16),

                  // Serving Size
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.restaurant, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Serving Size: ${selectedFood.nutrition.servingSize}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(NutritionData nutrition) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildNutritionRow('Calories', '${nutrition.calories.toStringAsFixed(0)}', 'kcal', Colors.red),
            Divider(),
            _buildNutritionRow('Protein', '${nutrition.protein.toStringAsFixed(1)}', 'g', Colors.blue),
            Divider(),
            _buildNutritionRow('Carbs', '${nutrition.carbs.toStringAsFixed(1)}', 'g', Colors.orange),
            Divider(),
            _buildNutritionRow('Fat', '${nutrition.fat.toStringAsFixed(1)}', 'g', Colors.purple),
            Divider(),
            _buildNutritionRow('Fiber', '${nutrition.fiber.toStringAsFixed(1)}', 'g', Colors.green),
            Divider(),
            _buildNutritionRow('Sugar', '${nutrition.sugar.toStringAsFixed(1)}', 'g', Colors.pink),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, String unit, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        Text(
          '$value $unit',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}