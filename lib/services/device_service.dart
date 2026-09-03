import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceStatus {
  final int batteryPercent;
  final String deviceName;
  final DateTime? lastSeenOnline;
  final String networkMode;
  final int signalStrength;

  DeviceStatus({
    required this.batteryPercent,
    required this.deviceName,
    required this.lastSeenOnline,
    this.networkMode = 'gsm',
    this.signalStrength = 0,
  });

  bool get isOnline {
    if (lastSeenOnline == null) return false;
    final secondsSinceLastSeen =
        DateTime.now().difference(lastSeenOnline!).inSeconds;
    return secondsSinceLastSeen <= 120;
  }
}

/// Tracks device (collar) status in Firestore, keyed by the pet's own
/// key (from LocalAuthService) instead of a Firebase Auth UID, since
/// this app uses local, on-device accounts rather than Firebase Auth.
class DeviceService {
  final _db = FirebaseFirestore.instance;

  Stream<DeviceStatus> watchDeviceStatus(String petKey) {
    if (petKey.isEmpty) {
      return Stream.value(DeviceStatus(
        batteryPercent: 0,
        deviceName: 'Not connected',
        lastSeenOnline: null,
        networkMode: 'gsm',
        signalStrength: 0,
      ));
    }

    return _db.collection('devices').doc(petKey).snapshots().map((doc) {
      final data = doc.data() ?? {};
      final ts = data['lastSeenOnline'];
      DateTime? lastSeen;
      if (ts is Timestamp) lastSeen = ts.toDate();

      return DeviceStatus(
        batteryPercent: (data['batteryPercent'] ?? 0) as int,
        deviceName: (data['deviceName'] ?? 'Pet Tracker Collar') as String,
        lastSeenOnline: lastSeen,
        networkMode: (data['networkMode'] ?? 'gsm') as String,
        signalStrength: (data['signalStrength'] ?? 0) as int,
      );
    });
  }

  /// Simulates a GSM-connected ESP32 heartbeat until live hardware is wired up.
  Future<void> pushTestHeartbeat(
    String petKey, {
    int batteryPercent = 85,
    String networkMode = 'gsm',
    int signalStrength = 78,
    double? latitude,
    double? longitude,
  }) async {
    if (petKey.isEmpty) return;

    final payload = {
      'batteryPercent': batteryPercent,
      'deviceName': 'Pet Tracker Collar',
      'networkMode': networkMode.toLowerCase(),
      'signalStrength': signalStrength,
      'lastSeenOnline': FieldValue.serverTimestamp(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };

    await _db
        .collection('devices')
        .doc(petKey)
        .set(payload, SetOptions(merge: true));
  }

  /// Real hardware heartbeat from a GSM SIM-based collar/device.
  Future<void> updateGsmHeartbeat({
    required String petKey,
    required int batteryPercent,
    required String networkMode,
    required int signalStrength,
    double? latitude,
    double? longitude,
  }) async {
    await pushTestHeartbeat(
      petKey,
      batteryPercent: batteryPercent,
      networkMode: networkMode,
      signalStrength: signalStrength,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
