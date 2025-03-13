import 'package:flutter/material.dart';
import '../models/child.dart';
import '../services/api_service.dart';

class ChildFormScreen extends StatefulWidget {
  final Child? child;

  const ChildFormScreen({super.key, this.child});

  @override
  State<ChildFormScreen> createState() => _ChildFormScreenState();
}

class _ChildFormScreenState extends State<ChildFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  late TextEditingController _nameController;
  late DateTime _dateOfBirth;
  late String _gender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child?.name);
    _dateOfBirth = widget.child?.dateOfBirth ?? DateTime.now();
    _gender = widget.child?.gender ?? 'M';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _saveChild() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final child = Child(
        id: widget.child?.id ?? 0,
        name: _nameController.text,
        dateOfBirth: _dateOfBirth,
        gender: _gender,
      );

      if (widget.child == null) {
        await _apiService.createChild(child);
      } else {
        await _apiService.updateChild(child);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.child == null ? 'Created' : 'Updated'} successfully'),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.child == null ? 'Add' : 'Edit'} Child'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date of Birth'),
                subtitle: Text(_dateOfBirth.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: const [
                  DropdownMenuItem(value: 'M', child: Text('Male')),
                  DropdownMenuItem(value: 'F', child: Text('Female')),
                ],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _gender = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveChild,
                child: Text(
                  widget.child == null ? 'Create Child' : 'Update Child',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}