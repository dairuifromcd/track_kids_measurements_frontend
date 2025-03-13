import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/child.dart';
import '../models/measurement.dart';
import '../services/api_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final ApiService _apiService = ApiService();
  List<Child> _children = [];
  Child? _selectedChild;
  List<Measurement> _measurements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      final children = await _apiService.getChildren();
      setState(() {
        _children = children;
        _isLoading = false;
        if (children.isNotEmpty && _selectedChild == null) {
          _selectedChild = children.first;
          _loadMeasurements();
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error loading children: ${e.toString()}');
    }
  }

  Future<void> _loadMeasurements() async {
    if (_selectedChild == null) return;

    setState(() => _isLoading = true);
    try {
      final measurements = await _apiService.getMeasurements(_selectedChild!.id, DateTime.now());
      setState(() {
        _measurements = measurements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error loading measurements: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<FlSpot> _getHeightSpots() {
    return _measurements
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.height))
        .toList();
  }

  List<FlSpot> _getWeightSpots() {
    return _measurements
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.weight))
        .toList();
  }

  Widget _buildChart(String title, List<FlSpot> spots, Color color) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Column(
        children: [
          if (_children.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<Child>(
                value: _selectedChild,
                isExpanded: true,
                items: _children.map((Child child) {
                  return DropdownMenuItem<Child>(
                    value: child,
                    child: Text(child.name),
                  );
                }).toList(),
                onChanged: (Child? child) {
                  setState(() {
                    _selectedChild = child;
                  });
                  _loadMeasurements();
                },
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _measurements.isEmpty
                    ? const Center(child: Text('No measurements recorded'))
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildChart(
                              'Height Growth (cm)',
                              _getHeightSpots(),
                              Colors.blue,
                            ),
                            _buildChart(
                              'Weight Growth (kg)',
                              _getWeightSpots(),
                              Colors.green,
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}