import 'package:flutter/material.dart';
import 'package:conqueror/constants/strings.dart';
import 'package:get/get.dart';

import '../widgets/navigation_menu.dart';

class HomeScreen extends StatelessWidget {
  final bool permissionsGranted;

  const HomeScreen({super.key, required this.permissionsGranted});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NavigationController>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('PenSnap'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'About PenSnap',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                const Text(
                  Strings.welcome,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 100), // Adjust this height to place the button further below the text
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.selectedIndex.value = 1; // Set index to "Capture" screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NavigationMenu(permissionsGranted: permissionsGranted),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black, // Text color
                      backgroundColor: const Color.fromARGB(
                          255, 221, 220, 220), // Background color
                    ),
                    child: Text('Start'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
