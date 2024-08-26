import 'dart:io';
import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget {
  final File? imageFile;
  final String aboutText;

  // Set a default value for aboutText
  AboutUs({this.imageFile, this.aboutText = 'Lorem Ipsum'});

  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
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
