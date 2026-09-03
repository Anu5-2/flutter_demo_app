import 'package:geolocator/geolocator.dart';

/// Wraps the geolocator package to fetch the device's real GPS position.
class LocationService {
  Future<void> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
          'Location services are turned off. Please enable them and try again.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission was denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permission is permanently denied. Enable it in your '
          'browser or device settings, then try again.');
    }
  }

  Future<Position> getCurrentPosition() async {
    await _ensurePermission();
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Live stream of position updates. Emits a new Position whenever the
  /// device moves (or at minimum every few seconds), instead of a single
  /// one-time fetch. Caller is responsible for cancelling the subscription.
  Stream<Position> getPositionStream() async* {
    await _ensurePermission();
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // meters of movement before a new update fires
      ),
    );
  }

  /// No persistent resources to release currently, but kept so
  /// LocationScreen's dispose() call keeps working unchanged.
  void dispose() {}
}
