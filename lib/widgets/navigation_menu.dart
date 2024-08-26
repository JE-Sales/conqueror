import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';

import 'package:conqueror/ui/home_screen.dart';
import 'package:conqueror/ui/img_select_screen.dart';
import 'package:conqueror/ui/history_screen.dart';
import 'package:conqueror/ui/settings_screen.dart';
import 'package:conqueror/ui/abtus_screen.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key, required bool permissionsGranted});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: Obx(
            () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
          controller.selectedIndex.value = index,
          backgroundColor: darkMode ? Colors.black : Colors.white,
          indicatorColor: darkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          destinations: const [
            NavigationDestination(icon: Icon(IconlyLight.home), label: 'Home'),
            NavigationDestination(
                icon: Icon(IconlyLight.camera), label: 'Capture'),
            NavigationDestination(
                icon: Icon(IconlyLight.document), label: 'My Scans'),
            NavigationDestination(
                icon: Icon(IconlyLight.setting), label: 'Settings'),
            NavigationDestination(
                icon: Icon(IconlyLight.user), label: 'About Us'),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomeScreen(permissionsGranted: true,),
    const ImageSelection(),
    const ScanScreen(),
    Settings(),
    AboutUs()
  ];
}