class NiveauEquipement {
  final String libelle;
  final int id;

  const NiveauEquipement({
    required this.libelle,
    required this.id
  });

  factory NiveauEquipement.fromJson(Map<String, dynamic> json) {
    return NiveauEquipement(
        libelle: json['libelle'],
        id: json['id']
    );
  }
}