import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../constants.dart';
import '../models/pet_location_model.dart';
import '../services/location_service.dart';
import '../widgets/map_view.dart';

class GeofenceScreen extends StatefulWidget {
  final PetLocationModel pet;
  final void Function(double radiusMeters) onSave;

  const GeofenceScreen({
    super.key,
    required this.pet,
    required this.onSave,
  });

  @override
  State<GeofenceScreen> createState() => _GeofenceScreenState();
}

class _GeofenceScreenState extends State<GeofenceScreen> {
  final LocationService _locationService = LocationService();
  late double _radius;
  LatLng? _center;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Safe Clamp: Ensures radius stays within Slider min (50) and max (1000)
    _radius = widget.pet.fenceRadiusMeters.clamp(50.0, 1000.0);
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    // Fallback: Use existing pet coordinates if available
    if (widget.pet.latitude != null && widget.pet.longitude != null) {
      if (mounted) {
        setState(() {
          _center = LatLng(widget.pet.latitude!, widget.pet.longitude!);
          _loading = false;
        });
      }
      return;
    }

    try {
      final position = await _locationService.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paleBlueBg,
      appBar: AppBar(
        title: const Text('Set Geo-Fence'),
        backgroundColor: AppColors.lightBlueBg,
        foregroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _error!,
                                style: const TextStyle(color: AppColors.dangerRed),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _loading = true;
                                    _error = null;
                                  });
                                  _loadCurrentLocation();
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : MapView(
                        petLocation: _center!,
                        fenceCenter: _center!,
                        fenceRadiusMeters: _radius,
                        showFence: true,
                      ),
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safe Zone Radius: ${_radius.round()} m',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
                Slider(
                  value: _radius,
                  min: 50,
                  max: 1000,
                  divisions: 19,
                  activeColor: AppColors.safeGreen,
                  label: '${_radius.round()} m',
                  onChanged: (val) => setState(() => _radius = val),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.safeGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _center == null
                        ? null
                        : () {
                            widget.onSave(_radius);
                            Navigator.pop(context);
                          },
                    child: const Text(
                      'Save Geo-Fence',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}