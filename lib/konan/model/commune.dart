class Commune {

  // A t t r i b u t e s  :
  final int id;
  final int idx;
  final String libelle;

  // M e t h o d s  :
  Commune({required this.id, required this.libelle, required this.idx});
  factory Commune.fromDatabaseJson(Map<String, dynamic> data) => Commune(
      id: data['id'],
      libelle: data['libelle'],
    idx: data['index'],
    //idx: data['idx'],
  );

  factory Commune.DatabaseToObject(Map<String, dynamic> data) => Commune(
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