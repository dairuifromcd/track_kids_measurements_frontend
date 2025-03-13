class Child {
  final int id;
  final String name;
  final DateTime dateOfBirth;
  final String gender;

  Child({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      name: json['name'],
      dateOfBirth: DateTime.parse(json['date_of_birth']),
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'gender': gender,
    };
  }
}