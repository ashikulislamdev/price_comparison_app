import 'package:flutter/material.dart';
// import 'package:price_comparison_app/view/mockapi_classifier.dart';
// import 'package:price_comparison_app/view/fashion_classifier_screen.dart';
import 'package:price_comparison_app/view/multistore_fashion_classifier.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Price Comparison App',
      debugShowCheckedModeBanner: false,
      home: const MultiFashionClassifierScreen(),
    );
  }
}

