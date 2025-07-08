import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/food_recognition_service.dart';
import 'screens/home_screen.dart';
import 'providers/food_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FoodProvider()),
      ],
      child: MaterialApp(
        title: 'Food Macros Finder',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
