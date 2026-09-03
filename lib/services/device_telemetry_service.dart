class DeviceTelemetry {
  final double? latitude;
  final double? longitude;
  final int? batteryPercent;
  final int? signalStrength;
  final String networkMode;
  final DateTime timestamp;

  const DeviceTelemetry({
    this.latitude,
    this.longitude,
    this.batteryPercent,
    this.signalStrength,
    this.networkMode = 'gsm',
    required this.timestamp,
  });

  factory DeviceTelemetry.fromJson(Map<String, dynamic> json) {
    final rawLat = json['lat'];
    final rawLng = json['lng'];
    final rawBattery = json['battery'];
    final rawSignal = json['signalStrength'];
    final rawNetwork = json['networkMode'];

    return DeviceTelemetry(
      latitude: rawLat is num ? rawLat.toDouble() : null,
      longitude: rawLng is num ? rawLng.toDouble() : null,
      batteryPercent: rawBattery is num ? rawBattery.round() : null,
      signalStrength: rawSignal is num ? rawSignal.round() : null,
      networkMode: rawNetwork is String ? rawNetwork.toLowerCase() : 'gsm',
      timestamp: DateTime.now(),
    );
  }

  bool get hasLocation => latitude != null && longitude != null;
}
