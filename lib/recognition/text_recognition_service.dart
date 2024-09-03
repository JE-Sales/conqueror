import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class TextRecognitionService {
  static const MethodChannel _channel = MethodChannel('com.example.pensnap/inference');

  // Method to recognize text using custom model
  static Future<String?> recognizeText(File imageFile) async {
    try {
      final String? result = await _channel.invokeMethod('recognizeText', {
        'imagePath': imageFile.path,
      });
      return result;
    } catch (e) {
      print('Error recognizing text: $e');
      return null;
    }
  }
}