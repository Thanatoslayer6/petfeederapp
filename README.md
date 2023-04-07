# petfeederapp

Capstone Project - Smart Pet Feeder Application

Built using *Flutter, MQTT* and *MongoDB*

![](assets/20230221_154415_PetFeederApplicationDesign.png)

### Tools:

* Visual Studio Code ([VSCodium](https://vscodium.com/) _better fork imo_)
* Arduino IDE ([Legacy](https://www.arduino.cc/en/software/) IDE 1.8.19)
* [MQTT CLI](https://hivemq.github.io/mqtt-cli/)

### Materials:

* Wemos D1 R1 ESP8266 ([View Code](https://github.com/Thanatoslayer6/ArduinoSketches/tree/main/PetFeederExperiment/WemosD1))
* ESP32-Cam (HW-818) with OV2640 Camera ([View Code](https://github.com/Thanatoslayer6/ArduinoSketches/tree/main/PetFeederExperiment/ESP32))
* SG90 Servo Motor
* Small/Mini Breadboard
* 5V Single-Channel Relay Module
* UV-C Light Tube (around 3-6 inches)

## Getting Started:

This application requires a MongoDB Cloud database account to set up, make sure you have an accessible server either locally or globally for its CRUD (Create, Read, Update, Delete) API. The source code for the application's CRUD API written in NodeJS can be seen here [petfeederdb](https://github.com/Thanatoslayer6/petfeederdb). Furthermore, this application requires two MQTT brokers, one that is publicly available (utilizes port 1883) and one that is private (utilizes port 8883).

### Compiling/Building:

1. After setting up the CRUD API, Make sure you have `java-11-openjdk` version installed and set on your system, after which clone this repository.
2. Inside `assets/` directory create a `.env` file and follow the format:

   ```toml
   CRUD_API="https://someapi.com/" # Database CRUD API here
   MQTT_SERVER0="private.mqttbroker.com" # This MQTT broker must be private (uses port 8883)
   MQTT_USER="username" # Username for authenticating in MQTT_SERVER0
   MQTT_PASS="password" # Password for authenticating in MQTT_SERVER0
   MQTT_SERVER1="public.mqttbroker.com" # Another MQTT Server must be public (uses port 1883)
   ```
3. For testing purposes run the application in debug mode by executing `flutter run -d <device_id>` or simply `flutter run`.
4. To build the application for production simply execute `flutter build apk --release`

### Progress/Features

* [X] Themes (Light, Dark, etc)
* [X] Manual Feeding (On button click)
* [X] Automatic Feeding (Based on schedule)
* [X] UV-Light (Enable/Disable)
* [X] Camera Stream
* [X] Audio (Playing music, speaking)
* [X] History Log (Feeding logs, UV-C Light logs)
