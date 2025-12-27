class Diplome {

  // A t t r i b u t e s  :
  final int id;
  final String libelle;

  // M e t h o d s  :
  Diplome({required this.id, required this.libelle});
  factory Diplome.fromDatabaseJson(Map<String, dynamic> data) => Diplome(
      id: data['id'],
      libelle: data['libelle']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "libelle": libelle
  };
}