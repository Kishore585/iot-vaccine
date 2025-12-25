import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/temperature_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double _minTemp = 2.0;
  double _maxTemp = 8.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Vaccine Temperature Monitor',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () => _showTemperatureLimitsDialog(context),
          ),
        ],
      ),
      body: Consumer<TemperatureProvider>(
        builder: (context, provider, child) {
          final currentTemp = provider.currentTemperatures.isNotEmpty
              ? provider.currentTemperatures.first.temperature
              : 0.0;
          final status = provider.getTemperatureStatus(currentTemp);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDigitalTemperatureMeter(currentTemp, status),
                const SizedBox(height: 24),
                _buildCurrentTemperatureCard(context, currentTemp, status),
                const SizedBox(height: 24),
                _buildTemperatureChart(context),
                const SizedBox(height: 24),
                _buildAlertsList(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDigitalTemperatureMeter(double temperature, String status) {
    Color meterColor;
    switch (status) {
      case 'critical':
        meterColor = Colors.red;
        break;
      case 'warning':
        meterColor = Colors.orange;
        break;
      default:
        meterColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Current Temperature',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${temperature.toStringAsFixed(1)}°C',
            style: GoogleFonts.robotoMono(
              fontSize: 72,
              color: meterColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Status: ${status.toUpperCase()}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: meterColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTemperatureCard(BuildContext context, double temperature, String status) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Reading',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temperature',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      '${temperature.toStringAsFixed(1)}°C',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.poppins(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemperatureChart(BuildContext context) {
    return Consumer<TemperatureProvider>(
      builder: (context, provider, child) {
        final historicalData = provider.historicalData;
        
        // Calculate average temperature
        final avgTemp = historicalData.isEmpty ? 0.0 : 
            historicalData.map((e) => e.temperature).reduce((a, b) => a + b) / historicalData.length;
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 380,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Temperature History',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (historicalData.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Avg: ${avgTemp.toStringAsFixed(1)}°C',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        if (historicalData.length >= 2) ...[
                          _buildTrendIndicator(
                            historicalData.last.temperature,
                            historicalData[historicalData.length - 2].temperature,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Touch points for details',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendItem(
                      'Normal',
                      Colors.green,
                      provider.minTemp,
                      provider.maxTemp,
                    ),
                    const SizedBox(width: 16),
                    _buildLegendItem(
                      'Warning',
                      Colors.orange,
                      provider.minTemp + 0.5,
                      provider.maxTemp - 0.5,
                    ),
                    const SizedBox(width: 16),
                    _buildLegendItem(
                      'Critical',
                      Colors.red,
                      provider.minTemp - 1,
                      provider.maxTemp + 1,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 1,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toStringAsFixed(1)}°C',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= historicalData.length) return const Text('');
                              final hour = historicalData[value.toInt()].timestamp.hour;
                              final minute = historicalData[value.toInt()].timestamp.minute;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      minX: 0,
                      maxX: historicalData.length > 0 ? (historicalData.length - 1).toDouble() : 0,
                      minY: provider.minTemp - 1,
                      maxY: provider.maxTemp + 1,
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final date = historicalData[barSpot.x.toInt()].timestamp;
                              return LineTooltipItem(
                                '${barSpot.y.toStringAsFixed(1)}°C\n${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }).toList();
                          },
                        ),
                        handleBuiltInTouches: true,
                        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                          return spotIndexes.map((spotIndex) {
                            return TouchedSpotIndicatorData(
                              FlLine(
                                color: provider.getGraphColor(barData.spots[spotIndex].y),
                                strokeWidth: 2,
                              ),
                              FlDotData(
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 6,
                                    color: provider.getGraphColor(spot.y),
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                            );
                          }).toList();
                        },
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: historicalData.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.temperature,
                            );
                          }).toList(),
                          isCurved: true,
                          color: historicalData.isNotEmpty
                              ? provider.getGraphColor(historicalData.last.temperature)
                              : Colors.blue,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: provider.getGraphColor(spot.y),
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: historicalData.isNotEmpty
                                ? provider.getGraphColor(historicalData.last.temperature).withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color, double minTemp, double maxTemp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label (${minTemp.toStringAsFixed(1)}°C - ${maxTemp.toStringAsFixed(1)}°C)',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList(BuildContext context) {
    return Consumer<TemperatureProvider>(
      builder: (context, provider, child) {
        final alerts = provider.alerts;
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Alerts',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                if (alerts.isEmpty)
                  Center(
                    child: Text(
                      'No alerts',
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {
                      final alert = alerts[index];
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getStatusColor(alert.status).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.warning_rounded,
                            color: _getStatusColor(alert.status),
                          ),
                        ),
                        title: Text(
                          '${alert.temperature.toStringAsFixed(1)}°C',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${alert.location} - ${alert.timestamp.toString()}',
                          style: GoogleFonts.poppins(
                            color: Colors.black54,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(alert.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            alert.status.toUpperCase(),
                            style: GoogleFonts.poppins(
                              color: _getStatusColor(alert.status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTemperatureLimitsDialog(BuildContext context) {
    final provider = Provider.of<TemperatureProvider>(context, listen: false);
    final minController = TextEditingController(text: provider.minTemp.toString());
    final maxController = TextEditingController(text: provider.maxTemp.toString());

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Set Temperature Range',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set the acceptable temperature range for vaccine storage',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: minController,
                  decoration: InputDecoration(
                    labelText: 'Minimum Temperature (°C)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.thermostat_outlined),
                    helperText: 'Recommended: 2.0°C',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    setState(() {
                      // Validate input
                      final minTemp = double.tryParse(value) ?? 2.0;
                      final maxTemp = double.tryParse(maxController.text) ?? 8.0;
                      if (minTemp >= maxTemp) {
                        minController.text = (maxTemp - 1).toString();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: maxController,
                  decoration: InputDecoration(
                    labelText: 'Maximum Temperature (°C)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.thermostat_outlined),
                    helperText: 'Recommended: 8.0°C',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    setState(() {
                      // Validate input
                      final maxTemp = double.tryParse(value) ?? 8.0;
                      final minTemp = double.tryParse(minController.text) ?? 2.0;
                      if (maxTemp <= minTemp) {
                        maxController.text = (minTemp + 1).toString();
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Temperature must be maintained between 2°C and 8°C for optimal vaccine storage.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final minTemp = double.tryParse(minController.text) ?? 2.0;
                final maxTemp = double.tryParse(maxController.text) ?? 8.0;
                
                // Validate the range
                if (minTemp < maxTemp) {
                  provider.updateTemperatureLimits(minTemp, maxTemp);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Minimum temperature must be less than maximum temperature',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save Range',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Widget _buildTrendIndicator(double currentTemp, double previousTemp) {
    final difference = currentTemp - previousTemp;
    final isIncreasing = difference > 0;
    final isDecreasing = difference < 0;
    final color = isIncreasing ? Colors.red : (isDecreasing ? Colors.green : Colors.grey);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isIncreasing ? Icons.trending_up : (isDecreasing ? Icons.trending_down : Icons.trending_flat),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${difference.abs().toStringAsFixed(1)}°C',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 