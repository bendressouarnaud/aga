class StatutMatrimonial {

  // A t t r i b u t e s  :
  final int id;
  final String libelle;

  // M e t h o d s  :
  StatutMatrimonial({required this.id, required this.libelle});
  factory StatutMatrimonial.fromDatabaseJson(Map<String, dynamic> data) => StatutMatrimonial(
      id: data['id'],
      libelle: data['libelle']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "libelle": libelle
  };
}