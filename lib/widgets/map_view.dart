import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget {
  final LatLng petLocation;
  final LatLng? fenceCenter;
  final double? fenceRadiusMeters;
  final bool showFence;

  /// If true (default), the camera re-centers on the pet every time
  /// [petLocation] changes. Set to false for small, non-interactive
  /// thumbnail maps (e.g. embedded in a list) where you don't want
  /// camera jumps.
  final bool followPet;

  /// Show a manual "recenter" button. Ignored if [followPet] is true,
  /// since the map is already always centered.
  final bool showRecenterButton;

  const MapView({
    super.key,
    required this.petLocation,
    this.fenceCenter,
    this.fenceRadiusMeters,
    this.showFence = false,
    this.followPet = true,
    this.showRecenterButton = true,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  bool _mapReady = false;

  @override
  void didUpdateWidget(covariant MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final moved = oldWidget.petLocation != widget.petLocation;
    if (moved && widget.followPet && _mapReady) {
      _recenter();
    }
  }

  void _recenter() {
    // camera.zoom is only safe to read after onMapReady has fired.
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(widget.petLocation, currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.petLocation,
              initialZoom: 16,
              onMapReady: () {
                _mapReady = true;
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_demo_app',
              ),
              if (widget.showFence &&
                  widget.fenceCenter != null &&
                  widget.fenceRadiusMeters != null)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: widget.fenceCenter!,
                      radius: widget.fenceRadiusMeters!,
                      useRadiusInMeter: true,
                      color: Colors.green.withValues(alpha: 0.15),
                      borderColor: Colors.green,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.petLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.pets, color: Colors.blue, size: 34),
                  ),
                  if (widget.fenceCenter != null)
                    Marker(
                      point: widget.fenceCenter!,
                      width: 30,
                      height: 30,
                      child:
                          const Icon(Icons.flag, color: Colors.green, size: 26),
                    ),
                ],
              ),
            ],
          ),
          if (!widget.followPet && widget.showRecenterButton)
            Positioned(
              right: 8,
              bottom: 8,
              child: FloatingActionButton.small(
                heroTag: null, // avoid hero-tag clashes with multiple maps
                onPressed: _recenter,
                child: const Icon(Icons.my_location),
              ),
            ),
        ],
      ),
    );
  }
}
