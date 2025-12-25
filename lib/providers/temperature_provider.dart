import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/temperature_data.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TemperatureProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final NotificationService _notificationService = NotificationService();
  List<TemperatureData> _currentTemperatures = [];
  List<TemperatureData> _historicalData = [];
  List<TemperatureData> _alerts = [];
  StreamSubscription? _temperatureSubscription;
  StreamSubscription? _historicalSubscription;
  StreamSubscription? _alertsSubscription;
  String _lastNotificationStatus = '';

  // Temperature limits
  double _minTemp = 2.0;
  double _maxTemp = 8.0;

  // Getters for temperature limits
  double get minTemp => _minTemp;
  double get maxTemp => _maxTemp;

  List<TemperatureData> get currentTemperatures => _currentTemperatures;
  List<TemperatureData> get historicalData => _historicalData;
  List<TemperatureData> get alerts => _alerts;

  TemperatureProvider() {
    _initializeSubscriptions();
  }

  // Method to update temperature limits
  void updateTemperatureLimits(double min, double max) {
    _minTemp = min;
    _maxTemp = max;
    notifyListeners();
  }

  void _initializeSubscriptions() {
    // Subscribe to real-time temperature updates
    _temperatureSubscription = _firebaseService.getTemperatureStream().listen((temperatures) {
      _currentTemperatures = temperatures;
      if (temperatures.isNotEmpty) {
        final latestTemp = temperatures.first;
        final status = getTemperatureStatus(latestTemp.temperature);
        
        // Only show notification if status has changed to critical
        if (status == 'critical' && _lastNotificationStatus != 'critical') {
          _notificationService.showTemperatureAlert(latestTemp.temperature, status);
        }
        _lastNotificationStatus = status;
      }
      notifyListeners();
    });

    // Subscribe to historical data
    _historicalSubscription = _firebaseService.getHistoricalData().listen((snapshot) {
      _historicalData = snapshot.docs
          .map((doc) => TemperatureData.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      
      // Group data by hour
      _historicalData = _groupDataByHour(_historicalData);
      notifyListeners();
    });

    // Subscribe to alerts
    _alertsSubscription = _firebaseService.getAlerts().listen((snapshot) {
      _alerts = snapshot.docs
          .map((doc) => TemperatureData.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    });
  }

  List<TemperatureData> _groupDataByHour(List<TemperatureData> data) {
    if (data.isEmpty) return [];

    // Sort data by timestamp
    data.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Group data by hour
    Map<int, List<TemperatureData>> hourlyData = {};
    for (var reading in data) {
      final hour = reading.timestamp.hour;
      hourlyData.putIfAbsent(hour, () => []).add(reading);
    }

    // Calculate average temperature for each hour
    List<TemperatureData> hourlyAverages = [];
    hourlyData.forEach((hour, readings) {
      if (readings.isNotEmpty) {
        final avgTemp = readings.map((r) => r.temperature).reduce((a, b) => a + b) / readings.length;
        hourlyAverages.add(TemperatureData(
          id: readings.first.id,
          temperature: avgTemp,
          location: readings.first.location,
          deviceId: readings.first.deviceId,
          timestamp: readings.first.timestamp,
          status: _getStatus(avgTemp),
        ));
      }
    });

    // Sort by hour
    hourlyAverages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return hourlyAverages;
  }

  String _getStatus(double temperature) {
    if (temperature < _minTemp || temperature > _maxTemp) {
      return 'critical';
    } else if (temperature < (_minTemp + 0.5) || temperature > (_maxTemp - 0.5)) {
      return 'warning';
    }
    return 'normal';
  }

  @override
  void dispose() {
    _temperatureSubscription?.cancel();
    _historicalSubscription?.cancel();
    _alertsSubscription?.cancel();
    super.dispose();
  }

  Future<void> addTemperatureReading(TemperatureData data) async {
    await _firebaseService.addTemperatureReading(data);
  }

  bool isTemperatureInRange(double temperature) {
    return temperature >= _minTemp && temperature <= _maxTemp;
  }

  String getTemperatureStatus(double temperature) {
    if (temperature < _minTemp) return 'critical';
    if (temperature > _maxTemp) return 'critical';
    if (temperature < (_minTemp + 0.5) || temperature > (_maxTemp - 0.5)) return 'warning';
    return 'normal';
  }

  Color getGraphColor(double temperature) {
    if (temperature < _minTemp || temperature > _maxTemp) {
      return Colors.red;
    }
    return Colors.green;
  }
} 