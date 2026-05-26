class ActionTerrain {

  // A t t r i b u t e s  :
  final int id;
  final int actif;
  final int communeId;
  final int quartierId;

  // M e t h o d s  :
  ActionTerrain({
        required this.id,
        required this.actif,
        required this.communeId,
        required this.quartierId
      });

  factory ActionTerrain.fromDatabaseJson(Map<String, dynamic> data) => ActionTerrain(
    id: data['id'],
    actif: data['actif'],
    communeId: data['commune_id'],
    quartierId: data['quartier_id']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "actif": actif,
    "commune_id": communeId,
    "quartier_id": quartierId
  };
}