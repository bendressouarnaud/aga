class Metier {

  // A t t r i b u t e s  :
  final int id;
  final String libelle;

  // M e t h o d s  :
  Metier({required this.id, required this.libelle});
  factory Metier.fromDatabaseJson(Map<String, dynamic> data) => Metier(
      id: data['id'],
      libelle: data['libelle']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "libelle": libelle
  };
}