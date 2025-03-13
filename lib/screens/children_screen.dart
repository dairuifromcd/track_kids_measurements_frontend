import 'package:flutter/material.dart';
import '../models/child.dart';
import '../services/api_service.dart';
import 'child_form_screen.dart';

class ChildrenScreen extends StatefulWidget {
  const ChildrenScreen({super.key});

  @override
  State<ChildrenScreen> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  final ApiService _apiService = ApiService();
  List<Child> _children = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      final children = await _apiService.getChildren();
      if (!mounted) return;
      setState(() {
        _children = children;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading children: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteChild(int id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this child? This action cannot be undone.'),
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

    if (confirm != true) return;

    try {
      await _apiService.deleteChild(id);
      await _loadChildren();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting child: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Children'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _children.isEmpty
              ? const Center(child: Text('No children added yet'))
              : ListView.builder(
                  itemCount: _children.length,
                  itemBuilder: (context, index) {
                    final child = _children[index];
                    return ListTile(
                      title: Text(child.name),
                      subtitle: Text(
                        'Born: ${child.dateOfBirth.toString().split(' ')[0]} - ${child.gender}',
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
                                  builder: (context) => ChildFormScreen(child: child),
                                ),
                              );
                              if (result == true) {
                                _loadChildren();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteChild(child.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChildFormScreen(),
            ),
          );
          if (result == true) {
            _loadChildren();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}