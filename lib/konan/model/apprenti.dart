class Apprenti {

  // A t t r i b u t e s  :
  final int id;
  final String nom;
  final String prenom;
  final String contact1;
  final String contact2;
  final String email;
  final String numero_immatriculation;

  final String lieu_naissance_autre;
  final int lieu_naissance;
  final String civilite;
  final String date_naissance;
  final int nationalite; //pays;
  final String sexe;

  final int type_document;
  final int niveau_etude;
  final int metier;
  final int classe;
  final int diplome;
  final String date_debut_apprentissage;

  final int commune_residence;
  final String quartier_residence;
  final String adresse_postal;
  //final int activite;

  final String numero_piece;
  final int piece_delivre;
  final String date_emission_piece;
  
  final String photo;
  final String photo_cni_recto;
  final String photo_cni_verso;

  final int statut_kyc;
  final int statut_paiement;
  final double longitude;
  final double latitude;

  final int a_suivi_formation;
  final String centre_formation_metier;
  final String intitule_formation_metier;
  final int formation_metier_terminee;
  final String diplome_obtenu_metier;
  final String cnps;
  final String cmu;
  final int artisan_id;
  final int entreprise_id;
  final int millisecondes;

  // 02/02/2026
  final int statut_apprenti;


  // M e t h o d s  :
  Apprenti({required this.id, required this.nom, required this.prenom, required this.civilite, required this.date_naissance,
    required this.numero_immatriculation, required this.lieu_naissance_autre, required this.lieu_naissance, required this.nationalite,
    required this.type_document, required this.niveau_etude, required this.classe, required this.diplome, required this.date_debut_apprentissage, 
    required this.commune_residence, required this.metier, required this.sexe, required this.numero_piece, required this.piece_delivre,
    required this.date_emission_piece, required this.quartier_residence, required this.adresse_postal, required this.contact1,
    required this.contact2, required this.email, required this.photo,
    required this.photo_cni_recto, required this.photo_cni_verso, required this.statut_kyc,
    required this.statut_paiement, required this.longitude, required this.latitude,
    required this.a_suivi_formation, required this.centre_formation_metier, required this.intitule_formation_metier,
    required this.formation_metier_terminee, required this.diplome_obtenu_metier,
    required this.cnps, required this.cmu, required this.artisan_id, required this.entreprise_id,
    required this.millisecondes, required this.statut_apprenti
  });
  factory Apprenti.fromDatabaseJson(Map<String, dynamic> data) => Apprenti(
    id: data['id'],
    nom: data['nom'],
    prenom: data['prenom'],
    civilite: data['civilite'],
    date_naissance: data['date_naissance'],
    numero_immatriculation: data['numero_immatriculation'],
    lieu_naissance_autre: data['lieu_naissance_autre'],
    lieu_naissance: data['lieu_naissance'],
    nationalite: data['nationalite'],
    type_document: data['type_document'],
    niveau_etude: data['niveau_etude'],
    classe: data['classe'],
    diplome: data['diplome'],
    date_debut_apprentissage: data['date_debut_apprentissage'],
    commune_residence: data['commune_residence'],
    metier: data['metier'],
    sexe: data['sexe'],
    numero_piece: data['numero_piece'],
    piece_delivre: data['piece_delivre'],
    date_emission_piece: data['date_emission_piece'],
    quartier_residence: data['quartier_residence'],
    adresse_postal: data['adresse_postal'],
    contact1: data['contact1'],
    contact2: data['contact2'],
    email: data['email'],
    photo: data['photo'],
    photo_cni_recto: data['photo_cni_recto'],
    photo_cni_verso: data['photo_cni_verso'],
    statut_kyc: data['statut_kyc'],
    statut_paiement: data['statut_paiement'],
    longitude: data['longitude'],
    latitude: data['latitude'],
    a_suivi_formation: data['a_suivi_formation'],
    centre_formation_metier: data['centre_formation_metier'],
    intitule_formation_metier: data['intitule_formation_metier'],
    formation_metier_terminee: data['formation_metier_terminee'],
    diplome_obtenu_metier: data['diplome_obtenu_metier'],
    cnps: data['cnps'],
    cmu: data['cmu'],

    artisan_id: data['artisan_id'],
      entreprise_id: data['entreprise_id'],
    millisecondes: data['millisecondes'],
      statut_apprenti: data['statut_apprenti']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "nom": nom,
    "prenom": prenom,
    "civilite": civilite,
    "date_naissance": date_naissance,
    "numero_immatriculation": numero_immatriculation,
    "lieu_naissance_autre": lieu_naissance_autre,
    "lieu_naissance": lieu_naissance,
    "nationalite": nationalite,
    "type_document": type_document,
    "niveau_etude": niveau_etude,
    "classe": classe,
    "diplome": diplome,
    "date_debut_apprentissage": date_debut_apprentissage,
    "commune_residence": commune_residence,
    "metier": metier,
    "sexe": sexe,
    "numero_piece": numero_piece,
    "piece_delivre": piece_delivre,
    "date_emission_piece": date_emission_piece,
    "quartier_residence": quartier_residence,
    "adresse_postal": adresse_postal,
    "contact1": contact1,
    "contact2": contact2,
    "email": email,
    "photo": photo,
    "photo_cni_recto": photo_cni_recto,
    "photo_cni_verso": photo_cni_verso,
    "statut_kyc": statut_kyc,
    "statut_paiement": statut_paiement,
    "longitude": longitude,
    "latitude": latitude,
    "a_suivi_formation": a_suivi_formation,
    "centre_formation_metier": centre_formation_metier,
    "intitule_formation_metier": intitule_formation_metier,
    "formation_metier_terminee": formation_metier_terminee,
    "diplome_obtenu_metier": diplome_obtenu_metier,
    "cnps": cnps,
    "cmu": cmu,

    "artisan_id": artisan_id,
    "entreprise_id": entreprise_id,
    "millisecondes": millisecondes,
    "statut_apprenti": statut_apprenti
  };
}