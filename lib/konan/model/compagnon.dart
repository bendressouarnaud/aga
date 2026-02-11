class Compagnon {

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
  final int specialite;
  final int classe;
  final int diplome;
  final int apprentissage_metier;
  final String date_debut_compagnonnage;

  final int commune_residence;
  final String quartier_residence;
  final String adresse_postal;

  final String numero_piece;
  final int piece_delivre;
  final String date_emission_piece;

  final String photo;
  final String photo_cni_recto;
  final String photo_cni_verso;
  final String photo_diplome;

  final int statut_kyc;
  final int statut_paiement;
  final double longitude;
  final double latitude;

  final String cnps;
  final String cmu;
  final int artisan_id;
  final int entreprise_id;
  final int millisecondes;

  // 02/02/2026
  final int statut_compagnon;
  // 11/02/2026
  final int livraisonCarte;

  // M e t h o d s  :
  Compagnon({required this.id, required this.nom, required this.prenom, required this.contact1,
    required this.contact2, required this.email, required this.numero_immatriculation, required this.lieu_naissance_autre,
    required this.lieu_naissance, required this.civilite, required this.date_naissance,
    required this.nationalite, required this.sexe, required this.type_document, required this.niveau_etude, required this.specialite,
    required this.classe, required this.diplome, required this.apprentissage_metier, required this.date_debut_compagnonnage,
    required this.commune_residence, required this.quartier_residence, required this.adresse_postal, required this.numero_piece,
    required this.piece_delivre, required this.date_emission_piece, required this.photo,
    required this.photo_cni_recto, required this.photo_cni_verso, required this.photo_diplome,
    required this.statut_kyc, required this.statut_paiement, required this.longitude, required this.latitude,
    required this.cnps, required this.cmu, required this.artisan_id, required this.entreprise_id,
    required this.millisecondes, required this.statut_compagnon, required this.livraisonCarte
  });
  factory Compagnon.fromDatabaseJson(Map<String, dynamic> data) => Compagnon(
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
      date_debut_compagnonnage: data['date_debut_compagnonnage'],
      commune_residence: data['commune_residence'],
      specialite: data['specialite'],
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
      photo_diplome: data['photo_diplome'],
      statut_kyc: data['statut_kyc'],
      statut_paiement: data['statut_paiement'],
      longitude: data['longitude'],
      latitude: data['latitude'],
      cnps: data['cnps'],
      cmu: data['cmu'],
      artisan_id: data['artisan_id'],
      entreprise_id: data['entreprise_id'],
      apprentissage_metier: data['apprentissage_metier'],
      millisecondes: data['millisecondes'],
      statut_compagnon: data['statut_compagnon'],
      livraisonCarte: data['livraison_carte']
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
    "date_debut_compagnonnage": date_debut_compagnonnage,
    "commune_residence": commune_residence,
    "specialite": specialite,
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
    "photo_diplome": photo_diplome,
    "statut_kyc": statut_kyc,
    "statut_paiement": statut_paiement,
    "longitude": longitude,
    "latitude": latitude,
    "cnps": cnps,
    "cmu": cmu,
    "artisan_id": artisan_id,
    "entreprise_id": entreprise_id,
    "apprentissage_metier": apprentissage_metier,
    "millisecondes": millisecondes,
    "statut_compagnon": statut_compagnon,
    "livraison_carte": livraisonCarte
  };
}