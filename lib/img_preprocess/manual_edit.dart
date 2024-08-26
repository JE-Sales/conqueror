import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ManualEdit {
  static Future<File?> cropImage(BuildContext context, File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '',
          toolbarColor: const Color.fromARGB(255, 221, 220, 220),
          activeControlsWidgetColor: const Color.fromARGB(255, 221, 220, 220),
          toolbarWidgetColor: Colors.black,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPresetCustom(),
          ],
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }

    return null;
  }
}


class CropAspectRatioPresetCustom implements CropAspectRatioPresetData {
@override
(int, int)? get data => (2, 3);

@override
String get name => '2x3 (customized)';
}