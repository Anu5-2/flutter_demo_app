class PetLocationModel {
  final double? latitude;
  final double? longitude;
  final bool isInsideSafeZone;
  final String deviceName;
  final bool isDeviceOnline;
  final int batteryPercent;
  final String networkMode;
  final int signalStrength;

  final double fenceCenterLat;
  final double fenceCenterLng;
  final double fenceRadiusMeters;

  PetLocationModel({
    this.latitude,
    this.longitude,
    this.isInsideSafeZone = true,
    this.deviceName = 'Pet Tracker Collar',
    this.isDeviceOnline = true,
    this.batteryPercent = 85,
    this.networkMode = 'gsm',
    this.signalStrength = 80,
    this.fenceCenterLat = 12.9716,
    this.fenceCenterLng = 77.5946,
    this.fenceRadiusMeters = 200,
  });

  String get latDisplay =>
      latitude != null ? latitude!.toStringAsFixed(4) : '--.------';
  String get lngDisplay =>
      longitude != null ? longitude!.toStringAsFixed(4) : '--.------';

  PetLocationModel copyWith({
    double? latitude,
    double? longitude,
    bool? isInsideSafeZone,
    int? batteryPercent,
    String? networkMode,
    int? signalStrength,
    double? fenceCenterLat,
    double? fenceCenterLng,
    double? fenceRadiusMeters,
  }) {
    return PetLocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isInsideSafeZone: isInsideSafeZone ?? this.isInsideSafeZone,
      deviceName: deviceName,
      isDeviceOnline: isDeviceOnline,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      networkMode: networkMode ?? this.networkMode,
      signalStrength: signalStrength ?? this.signalStrength,
      fenceCenterLat: fenceCenterLat ?? this.fenceCenterLat,
      fenceCenterLng: fenceCenterLng ?? this.fenceCenterLng,
      fenceRadiusMeters: fenceRadiusMeters ?? this.fenceRadiusMeters,
    );
  }
}
