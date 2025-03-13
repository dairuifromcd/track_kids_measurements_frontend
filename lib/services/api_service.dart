import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/child.dart';
import '../models/measurement.dart';
import '../models/stats.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';

  // Child API calls
  Future<List<Child>> getChildren() async {
    final response = await http.get(Uri.parse('$baseUrl/children/'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Child.fromJson(json)).toList();
    }
    throw Exception('Failed to load children');
  }

  Future<Child> createChild(Child child) async {
    final requestBody = json.encode(child.toJson());
    print('Creating child with request:');
    print('URL: $baseUrl/children/');
    print('Headers: {"Content-Type": "application/json"}');
    print('Body: $requestBody');

    final response = await http.post(
      Uri.parse('$baseUrl/children/'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return Child.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create child: ${response.body}');
  }

  Future<Child> updateChild(Child child) async {
    final response = await http.put(
      Uri.parse('$baseUrl/children/${child.id}/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(child.toJson()),
    );
    if (response.statusCode == 200) {
      return Child.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to update child');
  }

  Future<void> deleteChild(int childId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/children/$childId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete child');
    }
  }

  // Measurement API calls
  Future<List<Measurement>> getMeasurements(int childId, DateTime startDate, [DateTime? endDate]) async {
    final queryParams = {
      'start_date': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 'end_date': endDate.toIso8601String().split('T')[0],
    };
    final uri = Uri.parse('$baseUrl/measurements/$childId').replace(queryParameters: queryParams);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Measurement.fromJson(json)).toList();
    }
    throw Exception('Failed to load measurements');
  }

  Future<Measurement> createMeasurement(Measurement measurement) async {
    final response = await http.post(
      Uri.parse('$baseUrl/measurements'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(measurement.toJson()),
    );
    if (response.statusCode == 200) {
      return Measurement.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create measurement');
  }

  Future<Measurement> updateMeasurement(Measurement measurement) async {
    final response = await http.put(
      Uri.parse('$baseUrl/measurements/${measurement.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(measurement.toJson()),
    );
    if (response.statusCode == 200) {
      return Measurement.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to update measurement');
  }

  Future<void> deleteMeasurement(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/measurements/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete measurement');
    }
  }

  Future<void> deleteMeasurements(int childId, DateTime startDate, [DateTime? endDate]) async {
    final queryParams = {
      'start_date': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 'end_date': endDate.toIso8601String().split('T')[0],
    };
    final uri = Uri.parse('$baseUrl/measurements/$childId').replace(queryParameters: queryParams);
    final response = await http.delete(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete measurements');
    }
  }

  // Stats API calls
  Future<List<Stats>> getHeightStats() async {
    final response = await http.get(Uri.parse('$baseUrl/stats/height'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Stats.fromJson(json)).toList();
    }
    throw Exception('Failed to load height stats');
  }

  Future<List<Stats>> getWeightStats() async {
    final response = await http.get(Uri.parse('$baseUrl/stats/weight'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Stats.fromJson(json)).toList();
    }
    throw Exception('Failed to load weight stats');
  }
}