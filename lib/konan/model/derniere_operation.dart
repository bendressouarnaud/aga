class DerniereOperation {

  // A t t r i b u t e s  :
  int id;
  String libelle;// Nom ou dénomination
  String detail; // ex: 23000 F | 05 06 27 67 98
  int action; // 0: Enregistré | 1: Modifié | 2: Payé
  int requesterId;
  int millisecondes;
  String requesterType; // ART : ARTISAN | APP : APPRENTI | COM : COMPAGNON | ENT : ENTREPRISE

  // M e t h o d s  :
  DerniereOperation({required this.id, required this.libelle, required this.detail, required this.action,
    required this.requesterId, required this.requesterType, required this.millisecondes});
  factory DerniereOperation.fromDatabaseJson(Map<String, dynamic> data) => DerniereOperation(
      id: data['id'],
      libelle: data['libelle'],
      detail: data['detail'],
      action: data['action'],
      requesterId: data['requester_id'],
      millisecondes: data['millisecondes'],
      requesterType: data['requester_type']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "libelle": libelle,
    "detail": detail,
    "action": action,
    "requester_id": requesterId,
    "millisecondes": millisecondes,
    "requester_type": requesterType
  };
}