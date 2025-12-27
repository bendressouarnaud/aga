class Comptabilite {
  final String libelle;
  final int id;

  const Comptabilite({
    required this.libelle,
    required this.id
  });

  factory Comptabilite.fromJson(Map<String, dynamic> json) {
    return Comptabilite(
        libelle: json['libelle'],
        id: json['id']
    );
  }
}