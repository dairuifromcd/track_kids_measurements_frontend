import 'package:flutter/material.dart';
import '../models/child.dart';
import '../models/measurement.dart';
import '../services/api_service.dart';

class MeasurementFormScreen extends StatefulWidget {
  final Child child;
  final Measurement? measurement;

  const MeasurementFormScreen({
    super.key,
    required this.child,
    this.measurement,
  });

  @override
  State<MeasurementFormScreen> createState() => _MeasurementFormScreenState();
}

class _MeasurementFormScreenState extends State<MeasurementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  late DateTime _date;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _date = widget.measurement?.date ?? DateTime.now();
    _heightController = TextEditingController(
      text: widget.measurement?.height.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.measurement?.weight.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: widget.child.dateOfBirth,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _saveMeasurement() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final measurement = Measurement(
        id: widget.measurement?.id ?? 0,
        childId: widget.child.id,
        date: DateTime(_date.year, _date.month, _date.day),
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
      );

      if (widget.measurement == null) {
        await _apiService.createMeasurement(measurement);
      } else {
        await _apiService.updateMeasurement(measurement);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.measurement == null ? 'Created' : 'Updated'} successfully',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.measurement == null ? 'Add' : 'Edit'} Measurement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                title: const Text('Date'),
                subtitle: Text(_date.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  suffixText: 'cm',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter height';
                  }
                  final height = double.tryParse(value);
                  if (height == null || height <= 0) {
                    return 'Please enter a valid height';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  suffixText: 'kg',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter weight';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveMeasurement,
                child: Text(
                  widget.measurement == null
                      ? 'Create Measurement'
                      : 'Update Measurement',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}