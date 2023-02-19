import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTT {
  static MqttServerClient client =
      MqttServerClient.withPort('example.com', 'phoneClient', 8883);

  Future<void> publishMessage() async {
    // Set the authentication credentials
    client.logging(on: true);
    client.secure = true;
    // client.username = 'your_username';
    // client.password = 'your_password';

    // Connect to the broker
    await client.connect();

    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString('Hello from MQTT').payload;

    // Publish a message to the 'test' topic
    //client.publishMessage('test', MqttQos.atLeastOnce, builder);

    // Disconnect from the broker
    client.disconnect();
  }
}
