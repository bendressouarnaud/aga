class CoGerant {

  // A t t r i b u t e s  :
  final int id;

  final String civilite;
  final String nom;
  final String prenom;
  final String dateNaissance;
  final int lieuNaissance;
  final String lieuNaissanceAutre;
  final int nationalite;
  final int statutMatrimonial;
  final int typeDocument;
  final String numeroPiece;
  final int pieceDelivre;
  final String dateEmissionPiece;
  final int communeResidence;
  final String quartierResidence;
  final String adressePostal;
  final String contact1;
  final String contact2;
  final String email;
  final String qualification;
  final int livraisonCarte;

  final String pieceIdentiteRecto;
  final String pieceIdentiteVerso;
  final int optinMail;
  final int optinSms;
  final int optinWhatsapp;
  final String signature;

  // M e t h o d s  :
  CoGerant({required this.id, required this.civilite, required this.nom, required this.prenom, required this.dateNaissance,
    required this.lieuNaissance, required this.lieuNaissanceAutre, required this.nationalite,
    required this.statutMatrimonial, required this.typeDocument, required this.numeroPiece,
    required this.pieceDelivre, required this.dateEmissionPiece, required this.communeResidence,
    required this.quartierResidence, required this.adressePostal, required this.contact1, required this.contact2,
    required this.email,required this.qualification, required this.livraisonCarte, required this.pieceIdentiteRecto,
    required this.pieceIdentiteVerso, required this.optinMail, required this.optinSms, required this.optinWhatsapp, required this.signature
  });
  factory CoGerant.fromDatabaseJson(Map<String, dynamic> data) => CoGerant(
      id: data['id'],
      civilite: data['civilite'],
      nom: data['nom'],
      prenom: data['prenom'],
      dateNaissance: data['date_naissance'],
      lieuNaissance: data['lieu_naissance'],
      lieuNaissanceAutre: data['lieu_naissance_autre'],
      nationalite: data['nationalite'],
      statutMatrimonial: data['statut_matrimonial'],
      typeDocument: data['type_document'],
      numeroPiece: data['numero_piece'],
      pieceDelivre: data['piece_delivre'],
      dateEmissionPiece: data['date_emission_piece'],
      communeResidence: data['commune_residence'],
      quartierResidence: data['quartier_residence'],
      adressePostal: data['adresse_postal'],
      contact1: data['contact1'],
      contact2: data['contact2'],
      email: data['email'],
      qualification: data['qualification'],
      livraisonCarte: data['livraison_carte'],
      pieceIdentiteRecto: data['piece_identite_recto'],
      pieceIdentiteVerso: data['piece_identite_verso'],
      optinMail: data['optin_mail'],
      optinSms: data['optin_sms'],
      optinWhatsapp: data['optin_whatsapp'],
      signature: data['signature']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "civilite": civilite,
    "nom": nom,
    "prenom": prenom,
    "date_naissance": dateNaissance,
    "lieu_naissance": lieuNaissance,
    "lieu_naissance_autre": lieuNaissanceAutre,
    "nationalite": nationalite,
    "statut_matrimonial": statutMatrimonial,
    "type_document": typeDocument,
    "numero_piece": numeroPiece,
    "piece_delivre": pieceDelivre,
    "date_emission_piece": dateEmissionPiece,
    "commune_residence": communeResidence,
    "quartier_residence": quartierResidence,
    "adresse_postal": adressePostal,
    "contact1": contact1,
    "contact2": contact2,
    "email": email,
    "qualification": qualification,
    "livraison_carte": livraisonCarte,
    "piece_identite_recto": pieceIdentiteRecto,
    "piece_identite_verso": pieceIdentiteVerso,

    "optin_mail": optinMail,
    "optin_sms": optinSms,
    "optin_whatsapp": optinWhatsapp,
    "signature": signature
  };
}