import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import 'package:image_picker/image_picker.dart';

import 'package:conqueror/img_acquisition/from_gallery.dart';
import 'package:conqueror/img_preprocess/manual_edit.dart';

import 'package:conqueror/ui/result_screen.dart';

//Temporary
import 'package:conqueror/detection_and_recognition/recognition.dart';
import 'package:conqueror/ui/camera_screen.dart';

class ImageSelection extends StatefulWidget {
  const ImageSelection({super.key});

  @override
  State<ImageSelection> createState() => _ImageSelectionState();
}

class _ImageSelectionState extends State<ImageSelection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: fromCamera(context)),
            const SizedBox(height: 16),
            Center(child: fromGallery(context)),
          ],
        ),
      ),
    );
  }

  Widget fromCamera(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0), // Add padding to the button
      child: ElevatedButton(
        onPressed: () {
          print('pressed');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CustomCameraScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, // Background color
          backgroundColor:
          const Color.fromARGB(255, 221, 220, 220), // Text and icon color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          padding: const EdgeInsets.all(16),
          minimumSize: const Size.fromHeight(100), // Set minimum height
        ),
        child: const Row(
          children: [
            Icon(IconlyLight.camera, size: 40), // Icon for camera
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Camera",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text("Capture Image From Camera"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget fromGallery(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0), // Add padding to the button
      child: ElevatedButton(
        onPressed: () async {
          Future<XFile?> selectedImageFuture = GalleryService.pickImageAndNavigate(context);
          XFile? selectedImage = await selectedImageFuture;

          if (selectedImage != null) {
            File? croppedImage = await ManualEdit.cropImage(context, File(selectedImage.path));
            if (croppedImage != null) {
              String? result = await TextRecognitionService.recognizeText(croppedImage);

              // Navigate to the Result screen with the cropped image and recognized text
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResultScreen(
                    imagePath: croppedImage.path,
                    ocrText: result ?? 'No text recognized.', // Pass recognized text or default
                  ),
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, // Background color
          backgroundColor: const Color.fromARGB(255, 221, 220, 220),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          padding: const EdgeInsets.all(16),
          minimumSize: const Size.fromHeight(100), // Set minimum height
        ),
        child: const Row(
          children: [
            Icon(IconlyLight.image, size: 40), // Icon for gallery
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Gallery",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text("Select From Gallery"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

