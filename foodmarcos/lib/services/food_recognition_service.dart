import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/food_item.dart';
import 'nutrition_service.dart';

class FoodRecognitionService {
  static Interpreter? _interpreter;
  static List<String>? _labels;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load TFLite model with minimal configuration for compatibility
      _interpreter = await Interpreter.fromAsset('assets/food_classifier.tflite');

      // Load class labels
      String labelsData = await rootBundle.loadString('assets/class_names.txt');
      _labels = labelsData
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();

      _isInitialized = true;
      print('Food recognition model initialized successfully');
      print('Number of classes: ${_labels!.length}');
    } catch (e) {
      print('Error initializing model: $e');
      _isInitialized = false;
      throw Exception('Failed to initialize food recognition model: $e');
    }
  }

  static Future<List<FoodItem>> recognizeFood(File imageFile) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_interpreter == null || _labels == null) {
      throw Exception('Model not properly initialized');
    }

    try {
      // Preprocess image
      Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Could not decode image');
      }

      // Resize image to 224x224 (standard input size)
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

      // Convert image to normalized float array
      var input = _imageToByteListFloat32(resizedImage);

      // Prepare output buffer - simple approach
      var output = List.generate(1, (index) => List.filled(_labels!.length, 0.0));

      // Run inference
      _interpreter!.run(input, output);

      // Extract predictions
      List<double> predictions = output[0].cast<double>();

      // Apply softmax if needed
      predictions = _applySoftmax(predictions);

      // Get top 3 predictions
      List<MapEntry<int, double>> indexedPredictions = predictions
          .asMap()
          .entries
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      List<FoodItem> results = [];

      for (int i = 0; i < 3 && i < indexedPredictions.length; i++) {
        int classIndex = indexedPredictions[i].key;
        double confidence = indexedPredictions[i].value;

        // Lower confidence threshold
        if (confidence < 0.05) break;

        if (classIndex >= _labels!.length) {
          print('Warning: Class index $classIndex out of bounds');
          continue;
        }

        String className = _labels![classIndex];
        NutritionData? nutrition = NutritionService.getNutritionData(className);

        if (nutrition != null) {
          results.add(FoodItem(
            id: '${DateTime.now().millisecondsSinceEpoch}_$i',
            name: className,
            displayName: _formatFoodName(className),
            confidence: confidence,
            nutrition: nutrition,
            imagePath: imageFile.path,
          ));
        }
      }

      return results;
    } catch (e) {
      print('Error during food recognition: $e');
      throw Exception('Failed to recognize food: $e');
    }
  }

  static List<List<List<List<double>>>> _imageToByteListFloat32(img.Image image) {
    var convertedBytes = List.generate(1, (b) =>
        List.generate(224, (i) =>
            List.generate(224, (j) =>
                List.generate(3, (k) => 0.0)
            )
        )
    );

    for (int i = 0; i < 224; i++) {
      for (int j = 0; j < 224; j++) {
        final pixel = image.getPixel(j, i);
        convertedBytes[0][i][j][0] = pixel.r / 255.0;
        convertedBytes[0][i][j][1] = pixel.g / 255.0;
        convertedBytes[0][i][j][2] = pixel.b / 255.0;
      }
    }

    return convertedBytes;
  }

  static List<double> _applySoftmax(List<double> logits) {
    // Check if values are already probabilities
    double sum = logits.reduce((a, b) => a + b);
    if (sum > 0.9 && sum < 1.1) {
      return logits;
    }

    // Apply softmax
    double maxLogit = logits.reduce((a, b) => a > b ? a : b);
    List<double> exps = logits.map((x) => math.exp(x - maxLogit)).toList();
    double expSum = exps.reduce((a, b) => a + b);

    return exps.map((x) => x / expSum).toList();
  }

  static String _formatFoodName(String className) {
    return className
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
    _isInitialized = false;
  }
}