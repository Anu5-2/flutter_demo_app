import 'package:geolocator/geolocator.dart';

class GeofenceService {
  static double distanceFromCenter({
    required double petLat,
    required double petLng,
    required double centerLat,
    required double centerLng,
  }) {
    return Geolocator.distanceBetween(petLat, petLng, centerLat, centerLng);
  }

  static bool isInsideSafeZone({
    required double petLat,
    required double petLng,
    required double centerLat,
    required double centerLng,
    required double radiusMeters,
  }) {
    final distance = distanceFromCenter(
      petLat: petLat,
      petLng: petLng,
      centerLat: centerLat,
      centerLng: centerLng,
    );
    return distance <= radiusMeters;
  }
}
