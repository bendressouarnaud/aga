class StatsBean {
  final String libelle;
  final int population;
  final int attendu;
  final int paye;
  final double pourcentage;

  const StatsBean({
    required this.libelle,
    required this.population,
    required this.attendu,
    required this.paye,
    required this.pourcentage
  });

  factory StatsBean.fromJson(Map<String, dynamic> json) {
    return StatsBean(
        libelle: json['libelle'],
        population: json['population'],
        attendu: json['attendu'],
        paye: json['paye'],
        pourcentage: json['pourcentage']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['libelle'] = libelle;
    data['population'] = population;
    data['attendu'] = attendu;
    data['paye'] = paye;
    data['pourcentage'] = pourcentage;
    return data;
  }
}