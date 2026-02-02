class Artisan {

  // A t t r i b u t e s  :
  final int id;
  final String nom;
  final String prenom;
  final String contact1;
  final String contact2;
  final String email;
  final String numero_registre;
  final String lieu_naissance_autre;
  final int lieu_naissance;
  final String civilite;
  final String date_naissance;
  final int nationalite; //pays;
  final int statut_matrimonial;
  final int type_document;
  final int niveau_etude;
  final int formation;
  final int classe;
  final int diplome;
  final int commune_residence;
  final int activite;
  final String sexe;
  final String numero_piece;
  final int piece_delivre;
  final String date_emission_piece;
  final int metier;

  final String quartier_residence;
  final String adresse_postal;
  final String photo_artisan;
  final String photo_cni_recto;
  final String photo_cni_verso;
  final String photo_diplome;
  final String date_expiration_carte;

  final int statut_kyc;
  final int statut_paiement;
  final double longitude;
  final double latitude;

  final int regime_social;
  final int regime_travailleur;
  final int regime_imposition_taxe_communale;
  final int regime_imposition_micro_entreprise;
  final int comptabilite;
  final int chiffre_affaire;
  final String cnps;
  final String cmu;
  final int presence_compte_bancaire;
  final int type_compte_bancaire;
  final int crm;
  final int departement;
  final int sous_prefecture;

  final int specialite;
  final int activite_principale;
  final int activite_secondaire;

  final String raison_social;
  final String sigle;
  final String date_creation;
  final int commune_activite;
  final String quartier_activite;
  final String rccm;
  final int niveau_equipement;
  final int millisecondes;
  final int quartier_activite_id;

  // 02/02/2026
  final int statut_artisan;

  // M e t h o d s  :
  Artisan({required this.id, required this.nom, required this.prenom, required this.civilite, required this.date_naissance, required this.numero_registre,
    required this.lieu_naissance_autre, required this.lieu_naissance, required this.nationalite, required this.statut_matrimonial,
    required this.type_document, required this.niveau_etude, required this.formation, required this.classe, required this.diplome, required this.commune_residence,
    required this.activite, required this.sexe, required this.numero_piece, required this.piece_delivre, required this.date_emission_piece, required this.metier,
    required this.quartier_residence, required this.adresse_postal, required this.contact1, required this.contact2, required this.email, required this.photo_artisan,
    required this.photo_cni_recto, required this.photo_cni_verso, required this.photo_diplome, required this.date_expiration_carte, required this.statut_kyc,
    required this.statut_paiement, required this.longitude, required this.latitude, required this.regime_social, required this.regime_travailleur,
    required this.regime_imposition_taxe_communale, required this.regime_imposition_micro_entreprise, required this.comptabilite,
    required this.chiffre_affaire, required this.cnps, required this.cmu, required this.presence_compte_bancaire, required this.type_compte_bancaire,
    required this.crm, required this.departement, required this.sous_prefecture,

    required this.specialite, required this.activite_principale, required this.activite_secondaire,
    required this.raison_social, required this.sigle, required this.date_creation,
    required this.commune_activite, required this.quartier_activite, required this.rccm,
    required this.niveau_equipement, required this.millisecondes, required this.quartier_activite_id,
    required this.statut_artisan
  });
  factory Artisan.fromDatabaseJson(Map<String, dynamic> data) => Artisan(
    id: data['id'],
    nom: data['nom'],
    prenom: data['prenom'],
    civilite: data['civilite'],
    date_naissance: data['date_naissance'],
    numero_registre: data['numero_registre'],
    lieu_naissance_autre: data['lieu_naissance_autre'],
    lieu_naissance: data['lieu_naissance'],
    nationalite: data['nationalite'],
    statut_matrimonial: data['statut_matrimonial'],
    type_document: data['type_document'],
    niveau_etude: data['niveau_etude'],
    formation: data['formation'],
    classe: data['classe'],
    diplome: data['diplome'],
    commune_residence: data['commune_residence'],
    activite: data['activite'],
    sexe: data['sexe'],
    numero_piece: data['numero_piece'],
    piece_delivre: data['piece_delivre'],
    date_emission_piece: data['date_emission_piece'],
    metier: data['metier'],
    quartier_residence: data['quartier_residence'],
    adresse_postal: data['adresse_postal'],
    contact1: data['contact1'],
    contact2: data['contact2'],
    email: data['email'],
    photo_artisan: data['photo_artisan'],
    photo_cni_recto: data['photo_cni_recto'],
    photo_cni_verso: data['photo_cni_verso'],
    photo_diplome: data['photo_diplome'],
    date_expiration_carte: data['date_expiration_carte'],
    statut_kyc: data['statut_kyc'],
    statut_paiement: data['statut_paiement'],
    longitude: data['longitude'],
    latitude: data['latitude'],
    regime_social: data['regime_social'],
    regime_travailleur: data['regime_travailleur'],
    regime_imposition_taxe_communale: data['regime_imposition_taxe_communale'],
    regime_imposition_micro_entreprise: data['regime_imposition_micro_entreprise'],
    comptabilite: data['comptabilite'],
    chiffre_affaire: data['chiffre_affaire'],
    cnps: data['cnps'],
    cmu: data['cmu'],
    presence_compte_bancaire: data['presence_compte_bancaire'],
    type_compte_bancaire: data['type_compte_bancaire'],
    crm: data['crm'],
    departement: data['departement'],
    sous_prefecture: data['sous_prefecture'],

    specialite: data['specialite'],
    activite_principale: data['activite_principale'],
    activite_secondaire: data['activite_secondaire'],

    raison_social: data['raison_social'],
    sigle: data['sigle'],
    date_creation: data['date_creation'],
    commune_activite: data['commune_activite'],
    quartier_activite: data['quartier_activite'],
    rccm: data['rccm'],
    niveau_equipement: data['niveau_equipement'],
    millisecondes: data['millisecondes'],
    quartier_activite_id: data['quartier_activite_id'],
    statut_artisan: data['statut_artisan']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "nom": nom,
    "prenom": prenom,
    "civilite": civilite,
    "date_naissance": date_naissance,
    "numero_registre": numero_registre,
    "lieu_naissance_autre": lieu_naissance_autre,
    "lieu_naissance": lieu_naissance,
    "nationalite": nationalite,
    "statut_matrimonial": statut_matrimonial,
    "type_document": type_document,
    "niveau_etude": niveau_etude,
    "formation": formation,
    "classe": classe,
    "diplome": diplome,
    "commune_residence": commune_residence,
    "activite": activite,
    "sexe": sexe,
    "numero_piece": numero_piece,
    "piece_delivre": piece_delivre,
    "date_emission_piece": date_emission_piece,
    "metier": metier,
    "quartier_residence": quartier_residence,
    "adresse_postal": adresse_postal,
    "contact1": contact1,
    "contact2": contact2,
    "email": email,
    "photo_artisan": photo_artisan,
    "photo_cni_recto": photo_cni_recto,
    "photo_cni_verso": photo_cni_verso,
    "photo_diplome": photo_diplome,
    "date_expiration_carte": date_expiration_carte,
    "statut_kyc": statut_kyc,
    "statut_paiement": statut_paiement,
    "longitude": longitude,
    "latitude": latitude,
    "regime_social": regime_social,
    "regime_travailleur": regime_travailleur,
    "regime_imposition_taxe_communale": regime_imposition_taxe_communale,
    "regime_imposition_micro_entreprise": regime_imposition_micro_entreprise,
    "comptabilite": comptabilite,
    "chiffre_affaire": chiffre_affaire,
    "cnps": cnps,
    "cmu": cmu,
    "presence_compte_bancaire": presence_compte_bancaire,
    "type_compte_bancaire": type_compte_bancaire,
    "crm": crm,
    "departement": departement,
    "sous_prefecture": sous_prefecture,

    "specialite": specialite,
    "activite_principale": activite_principale,
    "activite_secondaire": activite_secondaire,

    "raison_social": raison_social,
    "sigle": sigle,
    "date_creation": date_creation,
    "commune_activite": commune_activite,
    "quartier_activite": quartier_activite,
    "rccm": rccm,
    "niveau_equipement": niveau_equipement,
    "millisecondes": millisecondes,
    "quartier_activite_id": quartier_activite_id,
    "statut_artisan": statut_artisan
  };
}