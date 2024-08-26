import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'package:iconly/iconly.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:image/image.dart' as img;
import 'package:conqueror/ui/result_screen.dart';
import '../detection_and_recognition/recognition.dart';
import '../img_preprocess/manual_edit.dart';

class CustomCameraScreen extends StatefulWidget {
  @override
  _CustomCameraScreenState createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> _cameras;
  CameraDescription? _selectedCamera;

  bool showFocusCircle = false;
  double x = 0;
  double y = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    var cameraStatus = await Permission.camera.request();

    if (cameraStatus.isGranted) {
      _initializeCamera();
    } else {
      print("Permissions not granted");
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        print("No cameras available");
        return;
      }

      _selectedCamera = _cameras.first;

      _controller = CameraController(
        _selectedCamera!,
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      _initializeControllerFuture = _controller!.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Camera initialization error: $e");
    }
  }

  Future<void> _onTap(TapUpDetails details) async {
    if (_controller?.value.isInitialized == true) {
      setState(() {
        showFocusCircle = true;
        x = details.localPosition.dx;
        y = details.localPosition.dy;
      });

      double fullWidth = MediaQuery.of(context).size.width;
      double cameraHeight = fullWidth * _controller!.value.aspectRatio;

      double xp = x / fullWidth;
      double yp = y / cameraHeight;

      Offset point = Offset(xp, yp);

      // Manually focus
      await _controller!.setFocusPoint(point);

      // Manually set light exposure
      _controller!.setExposurePoint(point);

      Future.delayed(const Duration(seconds: 2)).whenComplete(() {
        setState(() {
          showFocusCircle = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTapUp: _onTap,
                    child: Stack(
                      children: [
                        CameraPreview(_controller!),
                        if (showFocusCircle)
                          Positioned(
                            left: x - 20,
                            top: y - 20,
                            child: Icon(Icons.circle, color: Colors.white, size: 40),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed: () async {
                          try {
                            await _initializeControllerFuture;
                            final image = await _controller?.takePicture();
                            if (image != null) {
                              // Read the image file as bytes
                              final bytes = await image.readAsBytes();

                              // Decode the image to get its orientation
                              img.Image? capturedImage = img.decodeImage(Uint8List.fromList(bytes));
                              if (capturedImage != null) {
                                // Adjust the image orientation
                                final adjustedImage = img.bakeOrientation(capturedImage);

                                // Encode the adjusted image back to bytes
                                final adjustedBytes = img.encodeJpg(adjustedImage);

                                // Convert adjusted bytes to a File
                                final tempDir = await getTemporaryDirectory();
                                final tempFile = File('${tempDir.path}/captured_image.jpg');
                                await tempFile.writeAsBytes(adjustedBytes);

                                // Crop the image using your existing crop method
                                File? croppedImage = await ManualEdit.cropImage(context, tempFile);

                                if (croppedImage != null) {
                                  // Encode the cropped image to bytes
                                  final croppedImageBytes = await croppedImage.readAsBytes();

                                  // Save the cropped image to the gallery
                                  final result = await SaverGallery.saveImage(
                                      Uint8List.fromList(croppedImageBytes),
                                      quality: 100,
                                      name: "captured_image_${DateTime.now().millisecondsSinceEpoch}",
                                      androidExistNotSave: false
                                  );

                                  // Proceed with text recognition or other processing as needed
                                  String? recognizedText = await TextRecognitionService.recognizeText(croppedImage);

                                  Navigator.pop(context);
                                  // Navigate to the Result screen with the cropped image and recognized text
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ResultScreen(
                                        imagePath: croppedImage.path,
                                        ocrText: recognizedText ?? 'No text recognized.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Icon(IconlyLight.camera, color: Colors.black),
                        mini: true,
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
