import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_demo_app/services/device_service.dart';

void main() {
  group('DeviceStatus', () {
    test('treats GSM heartbeats within 120 seconds as online', () {
      final now = DateTime.now();
      final status = DeviceStatus(
        batteryPercent: 82,
        deviceName: 'Pet Tracker Collar',
        lastSeenOnline: now.subtract(const Duration(seconds: 45)),
        networkMode: 'gsm',
        signalStrength: 78,
      );

      expect(status.isOnline, isTrue);
      expect(status.networkMode, 'gsm');
      expect(status.signalStrength, 78);
    });

    test('marks device offline after heartbeat timeout', () {
      final status = DeviceStatus(
        batteryPercent: 15,
        deviceName: 'Pet Tracker Collar',
        lastSeenOnline: DateTime.now().subtract(const Duration(minutes: 3)),
        networkMode: 'gsm',
        signalStrength: 18,
      );

      expect(status.isOnline, isFalse);
      expect(status.networkMode, 'gsm');
      expect(status.signalStrength, 18);
    });
  });
}
