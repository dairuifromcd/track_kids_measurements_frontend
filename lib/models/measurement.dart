class Measurement {
  final int id;
  final int childId;
  final DateTime date;
  final double height;
  final double weight;

  Measurement({
    required this.id,
    required this.childId,
    required this.date,
    required this.height,
    required this.weight,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      id: json['id'],
      childId: json['child_id'],
      date: DateTime.parse(json['date']),
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'child_id': childId,
      'date': date.toIso8601String(),
      'height': height,
      'weight': weight,
    };
  }
}