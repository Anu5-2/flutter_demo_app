class AppConfig {
  static const String mqttBroker = String.fromEnvironment(
    'MQTT_BROKER',
    defaultValue: 'b2750bcdd7914c22b8d1944da437bd22.s1.eu.hivemq.cloud',
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
    defaultValue: 'ashika14',
  );
}