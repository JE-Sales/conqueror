// text_recognition_service.dart
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognitionService {
  static Future<String?> recognizeText(File imageFile) async {
    // Initialize the text recognizer
    final textRecognizer = TextRecognizer();

    // Perform text recognition on the image
    final inputImage = InputImage.fromFile(imageFile);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    // Extract recognized text
    String recognizedTextString = recognizedText.text;

    // Clean up resources
    textRecognizer.close();

    // Return the recognized text
    return recognizedTextString;
  }
}

