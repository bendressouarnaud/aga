class TypeCompteBancaire {

  // A t t r i b u t e s  :
  final int id;
  final String libelle;

  // M e t h o d s  :
  TypeCompteBancaire({required this.id, required this.libelle});
  factory TypeCompteBancaire.fromDatabaseJson(Map<String, dynamic> data) => TypeCompteBancaire(
      id: data['id'],
      libelle: data['libelle']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "libelle": libelle
  };
}