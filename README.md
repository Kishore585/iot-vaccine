# IoT Vaccine Temperature Monitoring System

This system monitors vaccine storage temperatures using ESP32 and DHT11 sensors, with real-time data visualization through a Flutter application.

## Hardware Requirements

- ESP32 development board
- DHT11 temperature sensor
- Jumper wires
- USB cable for programming ESP32

## Software Requirements

### ESP32 Setup
1. Install Arduino IDE
2. Install required libraries:
   - Firebase ESP32 Client
   - DHT sensor library
   - WiFi library
3. Configure ESP32:
   - Connect DHT11 to ESP32:
     - VCC to 3.3V
     - DATA to GPIO4
     - GND to GND
   - Update WiFi credentials in `esp32_code/iotvaccine.ino`
   - Update Firebase credentials in `esp32_code/iotvaccine.ino`

### Flutter Application Setup
1. Install Flutter SDK
2. Install required dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase:
   - Create a new Firebase project
   - Add Android/iOS apps to your Firebase project
   - Download and add the configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS
   - Enable Realtime Database and Firestore in Firebase Console

## Running the Application

### ESP32
1. Open `esp32_code/iotvaccine.ino` in Arduino IDE
2. Select your ESP32 board and port
3. Upload the code

### Flutter App
1. Run the Flutter application:
   ```bash
   flutter run
   ```

## Features

- Real-time temperature monitoring
- Temperature history visualization
- Alert system for temperature violations
- Multiple device support
- Location-based monitoring

## Temperature Ranges

- Normal: 2.5°C - 7.5°C
- Warning: 2.0°C - 2.5°C or 7.5°C - 8.0°C
- Critical: < 2.0°C or > 8.0°C

## Security Notes

- Keep your Firebase credentials secure
- Use environment variables for sensitive data in production
- Implement proper authentication for the Flutter application
- Secure your WiFi network

## Troubleshooting

1. If ESP32 fails to connect to WiFi:
   - Check WiFi credentials
   - Ensure WiFi network is 2.4GHz (ESP32 doesn't support 5GHz)

2. If temperature readings are incorrect:
   - Check DHT11 connections
   - Ensure proper power supply
   - Verify sensor is not damaged

3. If Firebase connection fails:
   - Verify Firebase credentials
   - Check internet connection
   - Ensure Firebase project is properly configured
