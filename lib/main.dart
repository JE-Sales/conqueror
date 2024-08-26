import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:conqueror/widgets/navigation_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    bool cameraPermissionGranted = false;
    bool storagePermissionGranted = false;

    // Loop until both permissions are granted
    while (!cameraPermissionGranted || !storagePermissionGranted) {
      // Request both permissions at once
      final statuses = await [
        Permission.camera,
        Permission.storage,
      ].request();

      // Check if the permissions are granted and handle null safety
      cameraPermissionGranted = statuses[Permission.camera]?.isGranted ?? false;
      storagePermissionGranted = statuses[Permission.storage]?.isGranted ?? false;

      if (!cameraPermissionGranted || !storagePermissionGranted) {
        // Show a dialog or notification to the user explaining why the permissions are needed
        await _showPermissionDialog();
      }
    }

    setState(() {
      _permissionsGranted = true;
    });
  }

  Future<void> _showPermissionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevents dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: const Text('This app needs camera and storage permissions to function correctly. Please grant the permissions.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: NavigationMenu(permissionsGranted: _permissionsGranted),
    );
  }
}
