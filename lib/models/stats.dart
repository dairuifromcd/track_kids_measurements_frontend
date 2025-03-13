class Stats {
  final int sex;
  final double agemos;
  final double l;
  final double m;
  final double s;
  final double p3;
  final double p5;
  final double p10;
  final double p25;
  final double p50;
  final double p75;
  final double p90;
  final double p95;
  final double p97;

  Stats({
    required this.sex,
    required this.agemos,
    required this.l,
    required this.m,
    required this.s,
    required this.p3,
    required this.p5,
    required this.p10,
    required this.p25,
    required this.p50,
    required this.p75,
    required this.p90,
    required this.p95,
    required this.p97,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      sex: json['Sex'],
      agemos: json['Agemos'].toDouble(),
      l: json['L'].toDouble(),
      m: json['M'].toDouble(),
      s: json['S'].toDouble(),
      p3: json['P3'].toDouble(),
      p5: json['P5'].toDouble(),
      p10: json['P10'].toDouble(),
      p25: json['P25'].toDouble(),
      p50: json['P50'].toDouble(),
      p75: json['P75'].toDouble(),
      p90: json['P90'].toDouble(),
      p95: json['P95'].toDouble(),
      p97: json['P97'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Sex': sex,
      'Agemos': agemos,
      'L': l,
      'M': m,
      'S': s,
      'P3': p3,
      'P5': p5,
      'P10': p10,
      'P25': p25,
      'P50': p50,
      'P75': p75,
      'P90': p90,
      'P95': p95,
      'P97': p97,
    };
  }
}