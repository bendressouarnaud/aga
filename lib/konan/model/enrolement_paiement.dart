class EnrolementPaiement {

  // A t t r i b u t e s  :
  int id;
  int millisecondes;
  int montant;

  // M e t h o d s  :
  EnrolementPaiement({required this.id, required this.millisecondes, required this.montant});
  factory EnrolementPaiement.fromDatabaseJson(Map<String, dynamic> data) => EnrolementPaiement(
      id: data['id'],
      millisecondes: data['millisecondes'],
      montant: data['montant']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "millisecondes": millisecondes,
    "montant": montant
  };
}