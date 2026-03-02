class GenericDataAmount {
  final String libelle;
  final int valeur;
  final bool active;

  const GenericDataAmount({
    required this.libelle,
    required this.valeur,
    required this.active,
  });

  factory GenericDataAmount.fromJson(Map<String, dynamic> json) {
    return GenericDataAmount(
        libelle: json['libelle'],
        valeur: json['valeur'],
      active: json['active']
    );
  }
}