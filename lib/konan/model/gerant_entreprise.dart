class GerantEntreprise {

  // A t t r i b u t e s  :
  final int id;
  final int actif;
  final int coGerant;
  final int entreprise;

  // M e t h o d s  :
  GerantEntreprise({
        required this.id,
        required this.actif,
        required this.coGerant,
        required this.entreprise
      });

  factory GerantEntreprise.fromDatabaseJson(Map<String, dynamic> data) => GerantEntreprise(
    id: data['id'],
    actif: data['actif'],
    coGerant: data['co_gerant'],
    entreprise: data['entreprise']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "actif": actif,
    "co_gerant": coGerant,
    "entreprise": entreprise
  };
}