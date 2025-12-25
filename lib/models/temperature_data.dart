class TemperatureData {
  final String id;
  final double temperature;
  final String location;
  final DateTime timestamp;
  final String deviceId;
  final String status; // 'normal', 'warning', 'critical'

  TemperatureData({
    required this.id,
    required this.temperature,
    required this.location,
    required this.timestamp,
    required this.deviceId,
    required this.status,
  });

  factory TemperatureData.fromJson(Map<dynamic, dynamic> json) {
    try {
      return TemperatureData(
        id: json['id']?.toString() ?? '',
        temperature: (json['temperature'] is num) 
            ? (json['temperature'] as num).toDouble()
            : double.tryParse(json['temperature'].toString()) ?? 0.0,
        location: json['location']?.toString() ?? 'Unknown Location',
        timestamp: json['timestamp'] != null 
            ? DateTime.parse(json['timestamp'].toString())
            : DateTime.now(),
        deviceId: json['deviceId']?.toString() ?? 'Unknown Device',
        status: json['status']?.toString() ?? 'normal',
      );
    } catch (e) {
      print('Error parsing TemperatureData: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'temperature': temperature,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'deviceId': deviceId,
      'status': status,
    };
  }

  String getStatusMessage() {
    if (temperature < 2.0) {
      return 'Temperature too low!';
    } else if (temperature > 8.0) {
      return 'Temperature too high!';
    }
    return 'Temperature normal';
  }
} 