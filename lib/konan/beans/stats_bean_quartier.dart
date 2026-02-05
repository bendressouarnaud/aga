class StatsBeanQuartier {
  final String quartier;
  final String date;
  final int total;

  const StatsBeanQuartier({
    required this.quartier,
    required this.date,
    required this.total
  });

  factory StatsBeanQuartier.fromJson(Map<String, dynamic> json) {
    return StatsBeanQuartier(
        quartier: json['quartier'],
        date: json['date'],
        total: json['total']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['quartier'] = quartier;
    data['date'] = date;
    data['total'] = total;
    return data;
  }
}