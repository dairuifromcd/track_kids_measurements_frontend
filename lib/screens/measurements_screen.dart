import 'package:flutter/material.dart';
import '../models/child.dart';
import '../models/measurement.dart';
import '../services/api_service.dart';
import 'measurement_form_screen.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
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

  Future<void> _deleteMeasurement(int id) async {
    try {
      await _apiService.deleteMeasurement(id);
      await _loadMeasurements();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Measurement deleted successfully')),
      );
    } catch (e) {
      _showError('Error deleting measurement: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurements'),
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
                    : ListView.builder(
                        itemCount: _measurements.length,
                        itemBuilder: (context, index) {
                          final measurement = _measurements[index];
                          return ListTile(
                            title: Text(
                              'Date: ${measurement.date.toString().split(' ')[0]}',
                            ),
                            subtitle: Text(
                              'Height: ${measurement.height}cm, Weight: ${measurement.weight}kg',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                await _deleteMeasurement(measurement.id);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _selectedChild == null
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MeasurementFormScreen(
                      child: _selectedChild!,
                    ),
                  ),
                );
                if (result == true) {
                  _loadMeasurements();
                }
              },
              child: const Icon(Icons.add),
            ),
    );
  }
}