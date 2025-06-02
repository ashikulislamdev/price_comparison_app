# 📱 Price Comparison Mobile App

This is the Flutter-based mobile application for the **Image-Based Price Comparison System**.

## 🎯 Overview

This app lets users upload an image of a fashion product (e.g., bag, shoe, shirt). The app uses a trained deep learning model to detect the product category, then queries multiple online stores (Amazon, Walmart, eBay, JD) to find and display the best-priced options.

- 🧠 Built with TensorFlow Lite (model inference)
- 📡 Integrates with backend FastAPI for classification and product data
- 📷 Uses image picker to classify product from the gallery
- 🛒 Lists top results from Amazon API + local mock APIs
- 🔎 Results are filterable by store and sorted by price

## 📸 Demo Video

📽️ Watch here: [https://youtu.be/vfC0H4d8Rfc](https://youtu.be/vfC0H4d8Rfc)

## 🔗 Related Repository

Backend: [price_comparison_backend](https://github.com/ashikulislamdev/price_comparison_backend)


## 🚀 Setup Instructions

1. Clone the repo
2. Run `flutter pub get`
3. Update the API IP address based on your backend host in `core/constants/ncc.dart`
4. Connect your Android device or emulator
5. Run `flutter run`

## 📘 Report

Read the full implementation paper (PDF): [Price_Comparison_System_Based_on_Image_Recognition.pdf](./Price_Comparison_System_Based_on_Image_Recognition.pdf)
