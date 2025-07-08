import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../providers/food_provider.dart';
import '../services/food_recognition_service.dart';
import '../models/food_item.dart';
import 'food_detail_screen.dart';
import 'history_screen.dart';
import '../widgets/food_card.dart';
import '../widgets/macro_chart.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  List<FoodItem> _recognizedFoods = [];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await FoodRecognitionService.initialize();
    await Provider.of<FoodProvider>(context, listen: false).loadRecentAnalyses();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
  }

  Future<void> _pickImage(ImageSource source) async {
    await _requestPermissions();

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _analyzeImage(File(image.path));
      }
    } catch (e) {
      _showErrorDialog('Error picking image: $e');
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);

    foodProvider.setLoading(true);

    try {
      List<FoodItem> recognizedFoods = await FoodRecognitionService.recognizeFood(imageFile);

      setState(() {
        _recognizedFoods = recognizedFoods;
      });

      if (recognizedFoods.isNotEmpty) {
        // Save the top prediction to history
        await foodProvider.addFoodAnalysis(recognizedFoods.first);

        // Navigate to detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(
              foodItems: recognizedFoods,
              imageFile: imageFile,
            ),
          ),
        );
      } else {
        _showErrorDialog('No food detected in the image. Please try with a clearer image.');
      }
    } catch (e) {
      _showErrorDialog('Error analyzing image: $e');
    } finally {
      foodProvider.setLoading(false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Library'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Macros Finder'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<FoodProvider>(
        builder: (context, foodProvider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 48,
                          color: Colors.green,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Discover Your Food\'s Nutrition',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Take a photo of your food and get instant nutrition information',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24),

                // Analyze Button
                ElevatedButton.icon(
                  onPressed: foodProvider.isLoading ? null : _showImageSourceDialog,
                  icon: foodProvider.isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Icon(Icons.camera_alt),
                  label: Text(foodProvider.isLoading ? 'Analyzing...' : 'Analyze Food'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),

                SizedBox(height: 24),

                // Recent Analyses Section
                if (foodProvider.recentAnalyses.isNotEmpty) ...[
                  Text(
                    'Recent Analyses',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: foodProvider.recentAnalyses.take(3).length,
                    itemBuilder: (context, index) {
                      FoodItem food = foodProvider.recentAnalyses[index];
                      return FoodCard(
                        food: food,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodDetailScreen(
                                foodItems: [food],
                                imageFile: food.imagePath != null ? File(food.imagePath!) : null,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HistoryScreen()),
                      );
                    },
                    child: Text('View All History'),
                  ),
                ],

                // Tips Section
                SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tips for Better Recognition',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 12),
                        _buildTipItem('Take photos in good lighting'),
                        _buildTipItem('Center the food in the frame'),
                        _buildTipItem('Avoid cluttered backgrounds'),
                        _buildTipItem('Make sure the food is clearly visible'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(child: Text(tip)),
        ],
      ),
    );
  }
}
