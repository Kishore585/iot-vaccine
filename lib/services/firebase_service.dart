import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/temperature_data.dart';

class FirebaseService {
  late final FirebaseFirestore _firestore;
  late final DatabaseReference _database;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      print('Firebase already initialized');
      return;
    }

    try {
      print('Initializing Firebase...');
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyADZhgdSifelVUJDDCc_tNDc8Y1PIUmQ-Q",
          authDomain: "iot-vaccine-monitor.firebaseapp.com",
          databaseURL: "https://iot-vaccine-monitor-default-rtdb.asia-southeast1.firebasedatabase.app",
          projectId: "iot-vaccine-monitor",
          storageBucket: "iot-vaccine-monitor.firebasestorage.app",
          messagingSenderId: "218419493577",
          appId: "1:218419493577:web:2dd49ed7112e52b602eb18",
          measurementId: "G-D9PS4W0PZN"
        ),
      );

      print('Firebase app initialized, setting up services...');
      _firestore = FirebaseFirestore.instance;
      _database = FirebaseDatabase.instance.ref();
      
      // Test the connection
      print('Testing Firebase connections...');
      await _database.child('temperatures').limitToFirst(1).get();
      print('Realtime Database connection successful');
      
      await _firestore.collection('temperature_history').limit(1).get();
      print('Firestore connection successful');
      
      _isInitialized = true;
      print('Firebase initialization completed successfully');
    } catch (e) {
      print('Error in Firebase initialization: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  bool get isInitialized => _isInitialized;

  // Stream of temperature data from Realtime Database
  Stream<List<TemperatureData>> getTemperatureStream() {
    if (!_isInitialized) {
      print('Firebase not initialized');
      return Stream.value(<TemperatureData>[]);
    }

    print('Setting up temperature stream...');
    // First, let's check if we can read the data directly
    _database.child('temperatures').get().then((snapshot) {
      print('Direct database read result: ${snapshot.value}');
    }).catchError((error) {
      print('Error reading database directly: $error');
    });

    return _database.child('temperatures').onValue.map((event) {
      try {
        print('Received event from Firebase: ${event.snapshot.value}');
        final data = event.snapshot.value;
        
        if (data == null) {
          print('No data received from Firebase');
          return <TemperatureData>[];
        }

        print('Processing data from Firebase: $data');
        final List<TemperatureData> temperatures = [];

        if (data is Map) {
          data.forEach((key, value) {
            try {
              print('Processing device: $key');
              print('Device data: $value');
              
              if (value is Map) {
                final tempData = TemperatureData(
                  id: key.toString(),
                  temperature: (value['temperature'] as num).toDouble(),
                  location: value['location'] as String,
                  deviceId: value['deviceId'] as String,
                  timestamp: DateTime.parse(value['timestamp'] as String),
                  status: value['status'] as String? ?? 'normal',
                );
                print('Created TemperatureData: ${tempData.toJson()}');
                temperatures.add(tempData);
              } else {
                print('Invalid data format for device $key: $value');
              }
            } catch (e) {
              print('Error processing device $key: $e');
            }
          });
        } else {
          print('Invalid data format: $data');
        }

        print('Processed ${temperatures.length} temperature readings');
        temperatures.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return temperatures;
      } catch (e) {
        print('Error in getTemperatureStream: $e');
        print('Error details: ${e.toString()}');
        return <TemperatureData>[];
      }
    }).handleError((error) {
      print('Error in temperature stream: $error');
      return <TemperatureData>[];
    });
  }

  // Add new temperature reading
  Future<void> addTemperatureReading(TemperatureData data) async {
    if (!_isInitialized) return;

    try {
      await _firestore.collection('temperature_history').add({
        'temperature': data.temperature,
        'location': data.location,
        'deviceId': data.deviceId,
        'timestamp': data.timestamp.toIso8601String(),
        'status': data.status,
      });
    } catch (e) {
      print('Error in addTemperatureReading: $e');
      rethrow;
    }
  }

  // Get historical temperature data
  Stream<QuerySnapshot<Map<String, dynamic>>> getHistoricalData() {
    if (!_isInitialized) {
      return Stream.empty();
    }

    return _firestore
        .collection('temperature_history')
        .orderBy('timestamp', descending: true)
        .limit(24) // Last 24 readings
        .snapshots()
        .handleError((error) {
          print('Error in historical data stream: $error');
          return const Stream.empty();
        });
  }

  // Get alerts for temperature violations
  Stream<QuerySnapshot<Map<String, dynamic>>> getAlerts() {
    if (!_isInitialized) {
      return Stream.empty();
    }

    return _firestore
        .collection('alerts')
        .orderBy('timestamp', descending: true)
        .limit(10) // Last 10 alerts
        .snapshots()
        .handleError((error) {
          print('Error in alerts stream: $error');
          return const Stream.empty();
        });
  }

  Future<void> addAlert(TemperatureData data) async {
    if (!_isInitialized) return;

    try {
      await _firestore.collection('alerts').add({
        'temperature': data.temperature,
        'location': data.location,
        'deviceId': data.deviceId,
        'timestamp': data.timestamp.toIso8601String(),
        'status': data.status,
      });
    } catch (e) {
      print('Error in addAlert: $e');
      rethrow;
    }
  }

  // Add a method to check database connection
  Future<void> checkDatabaseConnection() async {
    try {
      print('Checking database connection...');
      final snapshot = await _database.child('temperatures').get();
      print('Database connection successful');
      print('Current data in database: ${snapshot.value}');
    } catch (e) {
      print('Database connection error: $e');
    }
  }
} 