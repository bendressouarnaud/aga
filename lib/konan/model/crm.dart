class Crm {

  // A t t r i b u t e s  :
  final int id;
  final String libelle;

  // M e t h o d s  :
  Crm({required this.id, required this.libelle});
  factory Crm.fromDatabaseJson(Map<String, dynamic> data) => Crm(
      id: data['id'],
      libelle: data['libelle']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "libelle": libelle
  };
}