import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GalleryService {
  static Future<XFile?> pickImageAndNavigate(BuildContext context) async {
    ImagePicker _imagePicker = ImagePicker();

    XFile? xfile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (xfile != null) {
      return xfile;
    }
    return null;
  }
}
