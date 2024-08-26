import 'dart:io';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  final File? imageFile;
  final String aboutText;

  // Set a default value for aboutText
  Settings({this.imageFile, this.aboutText = 'Lorem Ipsum'});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.imageFile == null
                ? Image.asset('assets/images/temp/temp.png')
                : Image.file(widget.imageFile!),
            SizedBox(height: 20),
            Text(widget.aboutText), // Display the recognized text
          ],
        ),
      ),
    );
  }
}
