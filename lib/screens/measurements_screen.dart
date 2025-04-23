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
  late int _selectedYear;
  List<int> _availableYears = [];

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _loadChildren();
  }

  void _updateAvailableYears() {
    if (_selectedChild == null) return;
    final currentYear = DateTime.now().year;
    final birthYear = _selectedChild!.dateOfBirth.year;
    _availableYears = List.generate(
      currentYear - birthYear + 1,
      (index) => currentYear - index,
    );
    _selectedYear = _availableYears.first;
  }

  Future<void> _loadChildren() async {
    try {
      final children = await _apiService.getChildren();
      setState(() {
        _children = children;
        _isLoading = false;
        if (children.isNotEmpty && _selectedChild == null) {
          _selectedChild = children.first;
          _updateAvailableYears();
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
      final startDate = DateTime(_selectedYear, 1, 1);
      final endDate = DateTime(_selectedYear, 12, 31);
      final measurements = await _apiService.getMeasurements(_selectedChild!.id, startDate, endDate);
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
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this measurement? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _apiService.deleteMeasurement(id);
        await _loadMeasurements();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Measurement deleted successfully')),
        );
      } catch (e) {
        _showError('Error deleting measurement: ${e.toString()}');
      }
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
              child: Row(
                children: [
                  Expanded(
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
                          if (child != null) {
                            _updateAvailableYears();
                          }
                        });
                        _loadMeasurements();
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  if (_selectedChild != null)
                    Expanded(
                      child: DropdownButton<int>(
                        value: _selectedYear,
                        isExpanded: true,
                        items: _availableYears.map((int year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }).toList(),
                        onChanged: (int? year) {
                          if (year != null) {
                            setState(() {
                              _selectedYear = year;
                            });
                            _loadMeasurements();
                          }
                        },
                      ),
                    ),
                ],
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MeasurementFormScreen(
                                          child: _selectedChild!,
                                          measurement: measurement,
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      _loadMeasurements();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    await _deleteMeasurement(measurement.id);
                                  },
                                ),
                              ],
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