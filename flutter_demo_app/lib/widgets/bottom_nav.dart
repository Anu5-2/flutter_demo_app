import 'package:flutter/material.dart';
import '../constants.dart';
import '../screens/home_screen.dart';
import '../screens/location_screen.dart';
import '../screens/geofence_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/settings_screen.dart';
import '../models/pet_location_model.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  void _defaultNavigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget target;
    switch (index) {
      case 0:
        target = const HomeScreen();
        break;
      case 1:
        target = LocationScreen(pet: PetLocationModel());
        break;
      case 2:
        target = GeofenceScreen(
          pet: PetLocationModel(),
          onSave: (_) {},
        );
        break;
      case 3:
        target = const AlertsScreen();
        break;
      case 4:
        target = const SettingsScreen();
        break;
      default:
        target = const HomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => target),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap ?? (index) => _defaultNavigate(context, index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textGrey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined), label: 'Location'),
        BottomNavigationBarItem(icon: Icon(Icons.fence), label: 'Geo-Fence'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none), label: 'Alerts'),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined), label: 'Settings'),
      ],
    );
  }
}
