import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/food_item.dart';

class MacroChart extends StatelessWidget {
  final NutritionData nutrition;

  const MacroChart({Key? key, required this.nutrition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final macros = nutrition.macroPercentages;

    return Row(
      children: [
        // Pie Chart
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: Colors.blue,
                  value: macros['protein']!,
                  title: '${macros['protein']!.toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.orange,
                  value: macros['carbs']!,
                  title: '${macros['carbs']!.toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.purple,
                  value: macros['fat']!,
                  title: '${macros['fat']!.toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Legend
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem('Protein', Colors.blue, '${nutrition.protein.toStringAsFixed(1)}g'),
              SizedBox(height: 8),
              _buildLegendItem('Carbs', Colors.orange, '${nutrition.carbs.toStringAsFixed(1)}g'),
              SizedBox(height: 8),
              _buildLegendItem('Fat', Colors.purple, '${nutrition.fat.toStringAsFixed(1)}g'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}