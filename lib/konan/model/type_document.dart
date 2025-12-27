class TypeDocument {

  // A t t r i b u t e s  :
  final int id;
  final String libelle;

  // M e t h o d s  :
  TypeDocument({required this.id, required this.libelle});
  factory TypeDocument.fromDatabaseJson(Map<String, dynamic> data) => TypeDocument(
      id: data['id'],
      libelle: data['libelle']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "libelle": libelle
  };
}