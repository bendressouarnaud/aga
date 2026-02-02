class Quartier {

  // A t t r i b u t e s  :
  final int id;
  final int idx;
  final String libelle;

  // M e t h o d s  :
  Quartier({required this.id, required this.libelle, required this.idx});
  factory Quartier.fromDatabaseJson(Map<String, dynamic> data) => Quartier(
      id: data['id'],
      libelle: data['libelle'],
    idx: data['index'],
    //idx: data['idx'],
  );

  factory Quartier.DatabaseToObject(Map<String, dynamic> data) => Quartier(
    id: data['id'],
    libelle: data['libelle'],
    idx: data['idx']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "libelle": libelle,
    "idx": idx,
  };
}