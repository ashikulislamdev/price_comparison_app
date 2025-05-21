import 'package:flutter/material.dart';
import 'package:price_comparison_app/view/fashion_classifier_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Price Comparison App',
      debugShowCheckedModeBanner: false,
      home: const FashionClassifierScreen(),
    );
  }
}

