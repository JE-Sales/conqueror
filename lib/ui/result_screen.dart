import 'package:flutter/material.dart';
import 'dart:io';
import 'package:iconly/iconly.dart';
import 'package:flutter/services.dart'; // Import for clipboard functionality
import 'package:get/get.dart'; // Import for GetX

import 'package:conqueror/history/helpers/database_helper.dart';
import 'package:conqueror/history/scan_ds.dart';
import 'package:conqueror/widgets/navigation_menu.dart';

class ResultScreen extends StatelessWidget {
  final String imagePath;  // Path of the OCR image
  final String ocrText;    // OCR result text

  ResultScreen({required this.imagePath, required this.ocrText});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NavigationController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('OCR Result'),
        actions: [
          // Clipboard Button
          IconButton(
            icon: Icon(IconlyLight.document),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: ocrText));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('OCR result copied to clipboard!')),
              );
            },
          ),
          // Save Button
          IconButton(
            icon: Icon(IconlyLight.tick_square),
            onPressed: () async {
              // Save the result and image path to the database
              final scan = Scan(
                thumbnailPath: imagePath,
                textResult: ocrText,
                dateTime: DateTime.now().toIso8601String(),
              );

              await DatabaseHelper().insertScan(scan);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('OCR result saved!')),
              );

              // Navigate to the "My Scans" screen
              controller.selectedIndex.value = 2;
              Navigator.pop(context); // Close the ResultScreen
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Label for Image
            const Text(
              'Scanned Image:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Display Image with Rounded Square Border
            Container(
              height: 200, // Fixed height for the image
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12), // Same rounding for the image
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Label for OCR Result
            const Text(
              'Result:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Editable Text Box for OCR Result with Rounded Square Border
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: TextEditingController(text: ocrText),
                  maxLines: null,
                  expands: true, // Makes the TextField expand to fill available space
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
