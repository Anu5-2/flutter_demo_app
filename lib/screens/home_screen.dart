import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/pet_location_model.dart';
import '../services/mqtt_service.dart';
import '../services/geofence_service.dart';
import '../services/notification_service.dart';
import '../services/local_auth_service.dart';
import '../services/device_service.dart';
import '../widgets/bottom_nav.dart';
import 'location_screen.dart';
import 'geofence_screen.dart';
import 'alerts_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String petName;
  const HomeScreen({super.key, this.petName = 'Pet Owner'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  PetLocationModel pet = PetLocationModel();
  late String _petName;
  String _petKey = 'buddy';

  MqttService _mqttService = MqttService(petId: 'buddy');
  DeviceService _deviceService = DeviceService();
  bool _wasInsideSafeZone = true;

  @override
  void initState() {
    super.initState();
    _petName = widget.petName;
    if (_petName == 'Pet Owner') {
      _loadSessionName();
    } else {
      _petKey = _petName.trim().toLowerCase();
      _initializeServices();
    }
  }

  Future<void> _loadSessionName() async {
    final user = await LocalAuthService().getCurrentUser();
    final saved = user?['petName'] as String?;
    if (saved != null && saved.isNotEmpty && mounted) {
      _petKey = saved.trim().toLowerCase();
      setState(() => _petName = saved);
      _initializeServices();
    }
  }

  void _initializeServices() {
    _mqttService = MqttService(petId: _petKey);
    _deviceService = DeviceService();
    _connectMqtt();
  }

  Future<void> _connectMqtt() async {
    try {
      await _mqttService.connect();

      _mqttService.subscribeToLocation((lat, lng) {
        if (!mounted) return;
        setState(() {
          pet = pet.copyWith(latitude: lat, longitude: lng);
        });
        _checkGeofence(lat, lng);
      });

      _mqttService.subscribeToBattery((percent) {
        if (!mounted) return;
        setState(() {
          pet = pet.copyWith(batteryPercent: percent);
        });
      });
    } catch (e) {
      debugPrint('MQTT connection failed: $e');
    }
  }

  void _checkGeofence(double lat, double lng) {
    final inside = GeofenceService.isInsideSafeZone(
      petLat: lat,
      petLng: lng,
      centerLat: pet.fenceCenterLat,
      centerLng: pet.fenceCenterLng,
      radiusMeters: pet.fenceRadiusMeters,
    );

    setState(() {
      pet = pet.copyWith(isInsideSafeZone: inside);
    });

    // Only fire an alert on the transition from inside -> outside,
    // not on every single MQTT update while already outside.
    if (_wasInsideSafeZone && !inside) {
      NotificationService().showLocalAlert(
        title: 'PET ZONE Alert',
        body: '$_petName has left the safe zone!',
      );
      FirebaseFirestore.instance.collection('alerts').add({
        'petKey': _petKey, // Added for AlertsScreen filtering
        'petId': _petKey,
        'petName': _petName,
        'alertType': 'left_zone',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else if (!_wasInsideSafeZone && inside) {
      NotificationService().showLocalAlert(
        title: 'PET ZONE',
        body: '$_petName has returned to the safe zone.',
      );
      FirebaseFirestore.instance.collection('alerts').add({
        'petKey': _petKey, // Added for AlertsScreen filtering
        'petId': _petKey,
        'petName': _petName,
        'alertType': 'returned_to_zone',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    _wasInsideSafeZone = inside;
  }

  void _onNavTap(int index) {
    if (index == 0) {
      setState(() => _navIndex = index);
      return;
    }
    setState(() => _navIndex = index);
    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LocationScreen(pet: pet)),
        ).then((_) => setState(() => _navIndex = 0));
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GeofenceScreen(
              pet: pet,
              onSave: (radius) {
                setState(() => pet = pet.copyWith(fenceRadiusMeters: radius));
              },
            ),
          ),
        ).then((_) => setState(() => _navIndex = 0));
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AlertsScreen()),
        ).then((_) => setState(() => _navIndex = 0));
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        ).then((_) => setState(() => _navIndex = 0));
        break;
    }
  }

  @override
  void dispose() {
    _mqttService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paleBlueBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              _buildWelcomeBanner(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildPetStatusCard(),
                    const SizedBox(height: 16),
                    _buildCurrentLocationCard(),
                    const SizedBox(height: 16),
                    _buildQuickActionsRow(),
                    const SizedBox(height: 16),
                    _buildConnectedDeviceCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: AppColors.lightBlueBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: const Row(
        children: [
          Icon(Icons.pets, color: AppColors.primaryBlue, size: 26),
          SizedBox(width: 8),
          Text(
            AppStrings.appName,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue),
          ),
          Spacer(),
          Icon(Icons.notifications_none,
              color: AppColors.primaryBlue, size: 26),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      color: AppColors.lightBlueBg,
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, $_petName!',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue)),
                const SizedBox(height: 6),
                const Text('Keep your pet safe with real-time\ntracking 💙',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
              ],
            ),
          ),
          Image.asset(
            'assets/images/dog.png',
            width: 130,
            height: 130,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.pets,
              size: 100,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: cardShadowList,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: pet.isInsideSafeZone
                ? AppColors.safeGreen
                : AppColors.dangerRed,
            child: Icon(
              pet.isInsideSafeZone ? Icons.shield : Icons.warning_amber_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pet Status',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  pet.isInsideSafeZone
                      ? 'Inside Safe Zone'
                      : 'Outside Safe Zone',
                  style: TextStyle(
                      color: pet.isInsideSafeZone
                          ? AppColors.safeGreen
                          : AppColors.dangerRed,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  pet.isInsideSafeZone
                      ? 'Your pet is inside the defined safe area.'
                      : 'Your pet has left the safe area!',
                  style:
                      const TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 28,
            backgroundColor: pet.isInsideSafeZone
                ? AppColors.safeGreenLight
                : AppColors.dangerRedBg,
            child: Icon(Icons.location_on,
                color: pet.isInsideSafeZone
                    ? AppColors.safeGreen
                    : AppColors.dangerRed,
                size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: cardShadowList,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.location_on,
                        color: AppColors.primaryBlue, size: 18),
                    SizedBox(width: 6),
                    Text('Current Location',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textDark)),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Latitude',
                              style: TextStyle(
                                  color: AppColors.textGrey, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(pet.latDisplay,
                              style: const TextStyle(
                                  fontSize: 15, color: AppColors.textDark)),
                        ],
                      ),
                    ),
                    Container(
                        width: 1, height: 30, color: Colors.grey.shade300),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Longitude',
                              style: TextStyle(
                                  color: AppColors.textGrey, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(pet.lngDisplay,
                              style: const TextStyle(
                                  fontSize: 15, color: AppColors.textDark)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 90,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.paleBlueBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.location_on,
                color: AppColors.primaryBlue, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.flag,
            iconBg: AppColors.primaryBlue,
            cardBg: AppColors.actionBlueBg,
            titleColor: AppColors.primaryBlue,
            title: 'View Location',
            subtitle: "See your pet's live location",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LocationScreen(pet: pet)),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.fence,
            iconBg: AppColors.safeGreen,
            cardBg: AppColors.actionGreenBg,
            titleColor: AppColors.safeGreen,
            title: 'Set Geo-Fence',
            subtitle: 'Define a safe zone for your pet',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GeofenceScreen(
                    pet: pet,
                    onSave: (radius) {
                      setState(
                          () => pet = pet.copyWith(fenceRadiusMeters: radius));
                    },
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.notifications,
            iconBg: AppColors.actionPurple,
            cardBg: AppColors.actionPurpleBg,
            titleColor: AppColors.textDark,
            title: 'Alerts',
            subtitle: 'View all alerts and notifications',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlertsScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedDeviceCard() {
    return StreamBuilder<DeviceStatus>(
      stream: _deviceService.watchDeviceStatus(_petKey),
      builder: (context, snapshot) {
        final deviceStatus = snapshot.data ??
            DeviceStatus(
              batteryPercent: 0,
              deviceName: 'Pet Tracker Collar',
              lastSeenOnline: null,
            );

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.actionBlueBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.watch, color: AppColors.primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Connected Device',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.textGrey)),
                    Text(deviceStatus.deviceName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: deviceStatus.isOnline
                                ? AppColors.safeGreen
                                : AppColors.dangerRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          deviceStatus.isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: deviceStatus.isOnline
                                ? AppColors.safeGreen
                                : AppColors.dangerRed,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.actionBlueBg,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            deviceStatus.networkMode.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.signal_cellular_4_bar,
                  color: AppColors.primaryBlue, size: 18),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${deviceStatus.signalStrength}%',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Signal',
                      style:
                          TextStyle(fontSize: 11, color: AppColors.textGrey)),
                ],
              ),
              const SizedBox(width: 10),
              const Icon(Icons.battery_full,
                  color: AppColors.safeGreen, size: 18),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${deviceStatus.batteryPercent}%',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Battery',
                      style:
                          TextStyle(fontSize: 11, color: AppColors.textGrey)),
                ],
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: AppColors.textGrey),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color cardBg;
  final Color titleColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.iconBg,
    required this.cardBg,
    required this.titleColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: iconBg,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: titleColor)),
            const SizedBox(height: 4),
            Text(subtitle,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textGrey)),
            const SizedBox(height: 8),
            const Icon(Icons.arrow_forward,
                size: 16, color: AppColors.textDark),
          ],
        ),
      ),
    );
  }
}
