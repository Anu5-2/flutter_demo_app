import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceRegistrationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registerDevice({
    required String petKey,
    required String petName,
    required String deviceName,
    required String networkMode,
  }) async {
    await _db.collection('devices').doc(petKey).set({
      'petKey': petKey,
      'petName': petName,
      'deviceName': deviceName,
      'networkMode': networkMode.toLowerCase(),
      'lastSeenOnline': FieldValue.serverTimestamp(),
      'batteryPercent': 0,
      'signalStrength': 0,
      'registeredAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateDeviceStatus({
    required String petKey,
    required int batteryPercent,
    required int signalStrength,
    required String networkMode,
    double? latitude,
    double? longitude,
  }) async {
    await _db.collection('devices').doc(petKey).set({
      'petKey': petKey,
      'batteryPercent': batteryPercent,
      'signalStrength': signalStrength,
      'networkMode': networkMode.toLowerCase(),
      'lastSeenOnline': FieldValue.serverTimestamp(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    }, SetOptions(merge: true));
  }
}
