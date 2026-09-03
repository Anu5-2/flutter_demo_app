import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../constants.dart';
import '../models/pet_location_model.dart';
import '../services/location_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/map_view.dart';

class LocationScreen extends StatefulWidget {
  final PetLocationModel pet;

  const LocationScreen({super.key, required this.pet});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _positionSubscription;
  late PetLocationModel _pet;
  bool _loading = false;
  String? _error;
  String _lastUpdated = 'never';
  bool _isLive = false;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
    // If HomeScreen's own stream already delivered a fix before this
    // screen opened, reflect that immediately instead of showing a
    // contradictory "Connecting..." / "never" state next to a
    // populated map.
    if (_pet.latitude != null && _pet.longitude != null) {
      _isLive = true;
      _lastUpdated = 'just now';
    }
    _startLiveTracking();
  }

  void _startLiveTracking() {
    setState(() {
      _loading = true;
      _error = null;
    });

    _positionSubscription?.cancel();
    _positionSubscription = _locationService.getPositionStream().listen(
      (position) {
        if (!mounted) return;
        setState(() {
          _pet = _pet.copyWith(
            latitude: position.latitude,
            longitude: position.longitude,
          );
          _lastUpdated = 'just now';
          _loading = false;
          _isLive = true;
          _error = null;
        });
      },
      onError: (Object e) {
        if (!mounted) return;
        setState(() {
          _error = e.toString();
          _loading = false;
          _isLive = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _locationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFix = _pet.latitude != null && _pet.longitude != null;
    final point =
        hasFix ? LatLng(_pet.latitude!, _pet.longitude!) : const LatLng(0, 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.lightBlueBg,
        elevation: 0,
        title: const Text(
          'Location',
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryBlue),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.dangerRedBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.dangerRed),
                ),
              ),
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.paleBlueBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: hasFix
                  ? MapView(petLocation: point)
                  : Center(
                      child: _loading
                          ? const CircularProgressIndicator(
                              color: AppColors.accentBlue)
                          : const Text(
                              'No location yet.\nTap Refresh Location below.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textGrey),
                            ),
                    ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: cardShadowList,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Live Coordinates',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark),
                      ),
                      const SizedBox(width: 8),
                      if (_isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.safeGreenLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.safeGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('LIVE',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.safeGreen)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _coordTile('Latitude', _pet.latDisplay),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _coordTile('Longitude', _pet.lngDisplay),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 16, color: AppColors.textGrey),
                      const SizedBox(width: 6),
                      Text('Last updated: $_lastUpdated',
                          style: const TextStyle(
                              fontSize: 12.5, color: AppColors.textGrey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _startLiveTracking,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded),
                label:
                    Text(_loading ? 'Connecting...' : 'Restart Live Tracking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _coordTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paleBlueBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
        ],
      ),
    );
  }
}
