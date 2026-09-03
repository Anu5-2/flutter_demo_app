class AppConfig {
  static const String mqttBroker = String.fromEnvironment(
    'MQTT_BROKER',
    defaultValue: 'a637034e3f614359bf12dfb1bf2faa0a.s1.eu.hivemq.cloud',
  );

  static const int mqttPort = int.fromEnvironment(
    'MQTT_PORT',
    defaultValue: 8883,
  );

  static const String mqttUsername = String.fromEnvironment(
    'MQTT_USERNAME',
    defaultValue: 'petzone_device',
  );

  static const String mqttPassword = String.fromEnvironment(
    'MQTT_PASSWORD',
    defaultValue: 'eershANu@2468',
  );
}
