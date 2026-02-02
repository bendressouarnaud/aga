class Entreprise {

  // A t t r i b u t e s  :
  final int id;
  // G E R A N T
  final int crm;
  final int departement;
  final int sous_prefecture;

  final String civilite;
  final String nom;
  final String prenom;
  final String date_naissance;
  final int lieu_naissance;
  final String lieu_naissance_autre;
  final int nationalite;
  final int statut_matrimonial;
  final int type_document;
  final String numero_piece;
  final int piece_delivre;
  final String date_emission_piece;
  final int commune_residence;
  final String quartier_residence;
  final String adresse_postal;
  final String contact1;
  final String contact2;
  final String email;

  // E N T R E P R I S E
  final int forme_juridique;
  final int activite_principale;
  final int activite_secondaire;
  final String denomination;
  final String sigle;
  final String date_creation;
  final String objet_social;
  final String rccm;
  final String date_rccm;
  final int capital_social;
  final int regime_fiscal;
  final int duree_personne_morale;
  final String cnps_entreprise;
  final String compte_contribuable;
  final int total_associe;
  final int commune_siege;
  final String quartier_siege;
  final String lot;
  final String telephone;
  final int statut_kyc;
  final int statut_paiement;
  final double longitude;
  final double latitude;
  final int millisecondes;
  final int quartier_siege_id;


  // M e t h o d s  :
  Entreprise({required this.id, required this.crm, required this.departement, required this.sous_prefecture,
    required this.civilite, required this.nom, required this.prenom, required this.date_naissance,
    required this.lieu_naissance, required this.lieu_naissance_autre, required this.nationalite,
    required this.statut_matrimonial, required this.type_document, required this.numero_piece,
    required this.piece_delivre, required this.date_emission_piece, required this.commune_residence,
    required this.quartier_residence, required this.adresse_postal, required this.contact1, required this.contact2,
    required this.email, required this.forme_juridique, required this.activite_principale,
    required this.activite_secondaire, required this.denomination, required this.sigle, required this.date_creation,
    required this.objet_social, required this.rccm, required this.date_rccm, required this.capital_social,
    required this.regime_fiscal, required this.duree_personne_morale, required this.cnps_entreprise,
    required this.compte_contribuable, required this.total_associe, required this.commune_siege,
    required this.quartier_siege, required this.lot, required this.telephone, required this.statut_kyc,
    required this.statut_paiement, required this.longitude, required this.latitude, required this.millisecondes,
    required this.quartier_siege_id
  });
  factory Entreprise.fromDatabaseJson(Map<String, dynamic> data) => Entreprise(
      id: data['id'],
      crm: data['crm'],
      departement: data['departement'],
      sous_prefecture: data['sous_prefecture'],
      civilite: data['civilite'],
      nom: data['nom'],
      prenom: data['prenom'],
      date_naissance: data['date_naissance'],
      lieu_naissance: data['lieu_naissance'],
      lieu_naissance_autre: data['lieu_naissance_autre'],
      nationalite: data['nationalite'],
      statut_matrimonial: data['statut_matrimonial'],
      type_document: data['type_document'],
      numero_piece: data['numero_piece'],
      piece_delivre: data['piece_delivre'],
      date_emission_piece: data['date_emission_piece'],
      commune_residence: data['commune_residence'],
      quartier_residence: data['quartier_residence'],
      adresse_postal: data['adresse_postal'],
      contact1: data['contact1'],
      contact2: data['contact2'],
      email: data['email'],
      forme_juridique: data['forme_juridique'],
      activite_principale: data['activite_principale'],
      activite_secondaire: data['activite_secondaire'],
      denomination: data['denomination'],
      sigle: data['sigle'],
      date_creation: data['date_creation'],
      objet_social: data['objet_social'],
      rccm: data['rccm'],
      date_rccm: data['date_rccm'],
      capital_social: data['capital_social'],
      regime_fiscal: data['regime_fiscal'],
      duree_personne_morale: data['duree_personne_morale'],
      cnps_entreprise: data['cnps_entreprise'],
      compte_contribuable: data['compte_contribuable'],
      total_associe: data['total_associe'],
      commune_siege: data['commune_siege'],
      quartier_siege: data['quartier_siege'],
      lot: data['lot'],
      telephone: data['telephone'],
      statut_kyc: data['statut_kyc'],
      statut_paiement: data['statut_paiement'],
      longitude: data['longitude'],
      latitude: data['latitude'],
    millisecondes: data['millisecondes'],
    quartier_siege_id: data['quartier_siege_id'],
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "crm": crm,
    "departement": departement,
    "sous_prefecture": sous_prefecture,
    "civilite": civilite,
    "nom": nom,
    "prenom": prenom,
    "date_naissance": date_naissance,
    "lieu_naissance": lieu_naissance,
    "lieu_naissance_autre": lieu_naissance_autre,
    "nationalite": nationalite,
    "statut_matrimonial": statut_matrimonial,
    "type_document": type_document,
    "numero_piece": numero_piece,
    "piece_delivre": piece_delivre,
    "date_emission_piece": date_emission_piece,
    "commune_residence": commune_residence,
    "quartier_residence": quartier_residence,
    "adresse_postal": adresse_postal,
    "contact1": contact1,
    "contact2": contact2,
    "email": email,
    "forme_juridique": forme_juridique,
    "activite_principale": activite_principale,
    "activite_secondaire": activite_secondaire,
    "denomination": denomination,
    "sigle": sigle,
    "date_creation": date_creation,
    "objet_social": objet_social,
    "rccm": rccm,
    "date_rccm": date_rccm,
    "capital_social": capital_social,
    "regime_fiscal": regime_fiscal,
    "duree_personne_morale": duree_personne_morale,
    "cnps_entreprise": cnps_entreprise,
    "compte_contribuable": compte_contribuable,
    "total_associe": total_associe,
    "commune_siege": commune_siege,
    "quartier_siege": quartier_siege,
    "lot": lot,
    "telephone": telephone,
    "statut_kyc": statut_kyc,
    "statut_paiement": statut_paiement,
    "longitude": longitude,
    "latitude": latitude,
    "millisecondes": millisecondes,
    "quartier_siege_id": quartier_siege_id,
  };
}