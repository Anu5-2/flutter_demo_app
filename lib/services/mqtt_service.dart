import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../config/app_config.dart';

class MqttService {
  late MqttServerClient _client;
  final String petId;

  static const String _broker = AppConfig.mqttBroker;
  static const int _port = AppConfig.mqttPort;
  static const String _username = AppConfig.mqttUsername;
  static const String _password = AppConfig.mqttPassword;

  bool _isConnected = false;

  MqttService({required this.petId}) {
    _client = MqttServerClient.withPort(
      _broker,
      'flutter_client_$petId',
      _port,
    );
    _client.secure = true;
    _client.keepAlivePeriod = 30;
    _client.logging(on: false);
    _client.onDisconnected = () => _isConnected = false;
  }

  Future<void> connect() async {
    if (_isConnected) return;
    final connMessage = MqttConnectMessage()
        .authenticateAs(_username, _password)
        .withClientIdentifier('flutter_client_$petId')
        .startClean();
    _client.connectionMessage = connMessage;

    try {
      await _client.connect();
      _isConnected = true;
    } catch (e) {
      _client.disconnect();
      rethrow;
    }
  }

  void subscribeToLocation(void Function(double lat, double lng) onUpdate) {
    final topic = 'petzone/$petId/location';
    _client.subscribe(topic, MqttQos.atLeastOnce);
    _client.updates?.listen((events) {
      for (final event in events) {
        final recMess = event.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          final lat = data['lat'];
          final lng = data['lng'];
          if (lat is num && lng is num) {
            onUpdate(lat.toDouble(), lng.toDouble());
          }
        } catch (_) {
          // Ignore malformed payloads from beta device firmware.
        }
      }
    });
  }

  void subscribeToBattery(void Function(int percent) onUpdate) {
    final topic = 'petzone/$petId/battery';
    _client.subscribe(topic, MqttQos.atLeastOnce);
    _client.updates?.listen((events) {
      for (final event in events) {
        final recMess = event.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          final percent = data['percent'];
          if (percent is num) {
            onUpdate(percent.round());
          }
        } catch (_) {
          // Ignore malformed payloads from beta device firmware.
        }
      }
    });
  }

  /// Accepts a GSM-ready telemetry payload from a SIM-based tracker.
  /// Supported payloads include:
  /// { "lat": 12.97, "lng": 77.59, "battery": 82, "signalStrength": 78, "networkMode": "gsm" }
  void subscribeToTelemetry(
    void Function(Map<String, dynamic> telemetry) onUpdate,
  ) {
    final topic = 'petzone/$petId/telemetry';
    _client.subscribe(topic, MqttQos.atLeastOnce);
    _client.updates?.listen((events) {
      for (final event in events) {
        final recMess = event.payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
          recMess.payload.message,
        );
        try {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          onUpdate(data);
        } catch (_) {
          // Ignore malformed payloads.
        }
      }
    });
  }

  void disconnect() {
    _client.disconnect();
    _isConnected = false;
  }
}
