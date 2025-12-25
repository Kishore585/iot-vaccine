#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <DHT.h>
#include <NTPClient.h>
#include <WiFiUdp.h>
#include <ArduinoJson.h>
#include <time.h>

// WiFi credentials
#define WIFI_SSID "YOUR_WIFI_SSID"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"

// Firebase credentials
#define API_KEY "AIzaSyADZhgdSifelVUJDDCc_tNDc8Y1PIUmQ-Q"
#define DATABASE_URL "https://iot-vaccine-monitor-default-rtdb.asia-southeast1.firebasedatabase.app"

// DHT22 sensor configuration
#define DHTPIN 4      // DHT22 data pin connected to GPIO4
#define DHTTYPE DHT22 // DHT sensor type
DHT dht(DHTPIN, DHTTYPE);

// Firebase objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// NTP Client for time
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP, "pool.ntp.org");

// Variables
float temperature = 0.0;
float humidity = 0.0;
unsigned long lastUpdateTime = 0;
const long updateInterval = 30000; // Update every 30 seconds
String deviceId = "ESP32_" + String((uint32_t)ESP.getEfuseMac(), HEX);
String location = "Vaccine Storage Unit 1";

// Timezone offset for India (UTC+5:30)
const long TIMEZONE_OFFSET = 19800; // 5 hours and 30 minutes in seconds

// Function declarations
void sendDataToFirebase();
String getTemperatureStatus(float temp);
String getFormattedDateTime();
void connectToWiFi();
void initializeFirebase();
void initializeDHT();

void setup() {
  Serial.begin(115200);
  Serial.println("\nStarting Vaccine Temperature Monitor...");
  
  // Initialize DHT sensor with internal pull-up
  Serial.println("Initializing DHT sensor...");
  pinMode(DHTPIN, INPUT_PULLUP); // Enable internal pull-up resistor
  dht.begin();
  delay(2000); // Give sensor time to start up
  
  // Test DHT sensor
  Serial.println("Testing DHT sensor...");
  float testTemp = dht.readTemperature();
  float testHumidity = dht.readHumidity();
  
  if (isnan(testTemp) || isnan(testHumidity)) {
    Serial.println("ERROR: Failed to read from DHT sensor!");
    Serial.println("Please check your connections:");
    Serial.println("1. VCC to 3.3V");
    Serial.println("2. GND to GND");
    Serial.println("3. DATA to GPIO4");
  } else {
    Serial.println("DHT sensor test successful!");
    Serial.printf("Initial reading - Temperature: %.1f°C, Humidity: %.1f%%\n", testTemp, testHumidity);
  }
  
  // Connect to WiFi
  connectToWiFi();
  
  // Initialize NTP with India timezone
  timeClient.begin();
  timeClient.setTimeOffset(TIMEZONE_OFFSET);
  Serial.println("Time zone set to IST (UTC+5:30)");
  
  // Initialize Firebase
  initializeFirebase();
}

void connectToWiFi() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  int wifiTimeout = 0;
  while (WiFi.status() != WL_CONNECTED && wifiTimeout < 20) {
    delay(500);
    Serial.print(".");
    wifiTimeout++;
  }
  Serial.println();

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("Connected to WiFi");
    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("Failed to connect to WiFi");
    ESP.restart();
  }
}

void initializeFirebase() {
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  Firebase.RTDB.setReadTimeout(&fbdo, 1000 * 60);
  Firebase.RTDB.setwriteSizeLimit(&fbdo, "tiny");
  
  Serial.println("Firebase initialized");
}

void loop() {
  // Check WiFi connection
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi connection lost. Reconnecting...");
    WiFi.reconnect();
    delay(5000);
    return;
  }

  // Update NTP time
  timeClient.update();

  // Read temperature and humidity
  float newTemp = dht.readTemperature();
  float newHumidity = dht.readHumidity();
  
  // Check if any reads failed
  if (isnan(newTemp) || isnan(newHumidity)) {
    Serial.println("Failed to read from DHT sensor!");
    delay(2000);
    return;
  }

  // Update values
  temperature = newTemp;
  humidity = newHumidity;

  // Print readings
  Serial.println("\nCurrent Readings:");
  Serial.printf("Temperature: %.1f°C\n", temperature);
  Serial.printf("Humidity: %.1f%%\n", humidity);
  Serial.printf("Status: %s\n", getTemperatureStatus(temperature));

  // Send data to Firebase every updateInterval
  if (millis() - lastUpdateTime >= updateInterval) {
    Serial.println("\nSending data to Firebase...");
    lastUpdateTime = millis();
    sendDataToFirebase();
  }

  delay(1000); // Small delay to prevent overwhelming the sensor
}

String getFormattedDateTime() {
  timeClient.update();
  unsigned long epochTime = timeClient.getEpochTime();
  struct tm *ptm = gmtime((time_t *)&epochTime);
  char timeString[30];
  strftime(timeString, sizeof(timeString), "%Y-%m-%dT%H:%M:%S", ptm);
  return String(timeString);
}

void sendDataToFirebase() {
  if (!Firebase.ready()) {
    Serial.println("Firebase not ready");
    return;
  }

  // Create Firebase JSON object
  FirebaseJson json;
  json.set("temperature", temperature);
  json.set("humidity", humidity);
  json.set("location", location);
  json.set("deviceId", deviceId);
  json.set("timestamp", getFormattedDateTime());
  json.set("status", getTemperatureStatus(temperature));

  // Print the data being sent
  Serial.println("\nSending data to Firebase:");
  Serial.printf("Temperature: %.1f°C\n", temperature);
  Serial.printf("Humidity: %.1f%%\n", humidity);
  Serial.printf("Device ID: %s\n", deviceId.c_str());
  Serial.printf("Location: %s\n", location.c_str());
  Serial.printf("Timestamp: %s\n", getFormattedDateTime().c_str());
  Serial.printf("Status: %s\n", getTemperatureStatus(temperature).c_str());

  // Send to Realtime Database
  String path = "/temperatures/" + deviceId;
  Serial.printf("Firebase path: %s\n", path.c_str());
  
  if (Firebase.RTDB.setJSON(&fbdo, path.c_str(), &json)) {
    Serial.println("Data sent successfully to Firebase");
    Serial.println("Response: " + fbdo.payload());
  } else {
    Serial.println("Failed to send data to Firebase");
    Serial.println("Error: " + fbdo.errorReason());
  }

  // If temperature is out of range, send to alerts
  if (temperature < 2.0 || temperature > 8.0) {
    String alertPath = "/alerts/" + deviceId + "_" + String(millis());
    Serial.printf("Sending alert to path: %s\n", alertPath.c_str());
    
    if (Firebase.RTDB.setJSON(&fbdo, alertPath.c_str(), &json)) {
      Serial.println("Alert sent successfully");
    } else {
      Serial.println("Failed to send alert");
      Serial.println("Error: " + fbdo.errorReason());
    }
  }
}

String getTemperatureStatus(float temp) {
  if (temp < 2.0 || temp > 8.0) {
    return "critical";
  } else if (temp < 2.5 || temp > 7.5) {
    return "warning";
  }
  return "normal";
} 