class Classe {

  // A t t r i b u t e s  :
  final int id;
  final String libelle;

  // M e t h o d s  :
  Classe({required this.id, required this.libelle});
  factory Classe.fromDatabaseJson(Map<String, dynamic> data) => Classe(
      id: data['id'],
      libelle: data['libelle']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "libelle": libelle
  };
}