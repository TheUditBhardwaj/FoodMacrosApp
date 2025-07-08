// widgets/food_card.dart
import 'package:flutter/material.dart';
import '../models/food_item.dart';
import 'dart:io';

class FoodCard extends StatelessWidget {
  final FoodItem food;
  final bool showDate;
  final VoidCallback? onTap;

  const FoodCard({
    Key? key,
    required this.food,
    this.showDate = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Food Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 60,
                  child: food.imagePath != null
                      ? Image.file(
                    File(food.imagePath!),
                    fit: BoxFit.cover,
                  )
                      : Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.restaurant,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 16),

              // Food Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Confidence: ${(food.confidence * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (showDate) ...[
                      SizedBox(height: 4),
                      Text(
                        _formatDate(food.analyzedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Nutrition Summary
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${food.nutrition.calories.toStringAsFixed(0)} cal',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'P: ${food.nutrition.protein.toStringAsFixed(1)}g',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                  Text(
                    'C: ${food.nutrition.carbs.toStringAsFixed(1)}g',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                  Text(
                    'F: ${food.nutrition.fat.toStringAsFixed(1)}g',
                    style: TextStyle(fontSize: 12, color: Colors.purple),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));
    DateTime cardDate = DateTime(date.year, date.month, date.day);

    if (cardDate == today) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (cardDate == yesterday) {
      return 'Yesterday ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}