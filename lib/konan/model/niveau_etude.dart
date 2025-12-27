class NiveauEtude {

  // A t t r i b u t e s  :
  final int id;
  final String libelle;

  // M e t h o d s  :
  NiveauEtude({required this.id, required this.libelle});
  factory NiveauEtude.fromDatabaseJson(Map<String, dynamic> data) => NiveauEtude(
      id: data['id'],
      libelle: data['libelle']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "libelle": libelle
  };
}