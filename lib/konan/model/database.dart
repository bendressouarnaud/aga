import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';


class DatabaseHelper {

  // This is the actual database filename that is saved in the docs directory.
  static const _databaseName = "cmci.db";

  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;


  // Make this a singleton class.
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade
    );
  }

  Future _onCreate(Database db, int newVersion) async {
    for (int version = 0; version < newVersion; version++) {
      await _performDbOperationsVersionWise(db, version + 1);
    }
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (int version = oldVersion; version < newVersion; version++) {
      await _performDbOperationsVersionWise(db, version + 1);
    }
  }

  _performDbOperationsVersionWise(Database db, int version) async {
    switch (version) {
      case 1:
        await _createDatabase(db);
        break;
    case 2:
        await _updateReservationTable(db);
        break;
    /*case 3:
      await _addStreamChatObject(db);
      break;*/
    }
  }

  Future _updateReservationTable(Database db) async {
    await db.execute('ALTER TABLE reservation ADD COLUMN paysid TEXT');
    await db.execute('ALTER TABLE reservation ADD COLUMN modeliaid TEXT');
    // Init that :
    //await db.execute('UPDATE parameters SET appmigration = 0');
  }

  Future _createDatabase(Database db) async {
    await db.execute('CREATE TABLE crm (id INTEGER PRIMARY KEY, libelle TEXT)');
    await db.execute('CREATE TABLE pays (id INTEGER PRIMARY KEY, libelle TEXT)');
    await db.execute('CREATE TABLE statut_matrimonial (id INTEGER PRIMARY KEY, libelle TEXT)');
    await db.execute('CREATE TABLE type_compte_bancaire (id INTEGER PRIMARY KEY, libelle TEXT)');
    await db.execute('CREATE TABLE type_document (id INTEGER PRIMARY KEY, libelle TEXT)');
    await db.execute('CREATE TABLE niveau_etude (id INTEGER PRIMARY KEY, libelle TEXT)');
    await db.execute('CREATE TABLE classe (id INTEGER PRIMARY KEY, libelle TEXT)');
    await db.execute('CREATE TABLE diplome (id INTEGER PRIMARY KEY, libelle TEXT)');
    await db.execute('CREATE TABLE metier (id INTEGER PRIMARY KEY, libelle TEXT)');

    await db.execute('CREATE TABLE departement (id INTEGER PRIMARY KEY, libelle TEXT, idx integer)');
    await db.execute('CREATE TABLE sous_prefecture (id INTEGER PRIMARY KEY, libelle TEXT, idx integer)');
    await db.execute('CREATE TABLE commune (id INTEGER PRIMARY KEY, libelle TEXT, idx integer)');
    await db.execute('CREATE TABLE user (id INTEGER PRIMARY KEY, nom TEXT, email TEXT, pwd TEXT, jwt TEXT, profil TEXT,'
        'milliseconds INTEGER)');

    await db.execute('CREATE TABLE artisan (id INTEGER PRIMARY KEY, nom TEXT, prenom TEXT, contact1 TEXT, contact2 TEXT,'
        'email TEXT, numero_registre TEXT, lieu_naissance_autre TEXT, lieu_naissance INTEGER, civilite TEXT, date_naissance TEXT,'
        'nationalite INTEGER, statut_matrimonial INTEGER, type_document INTEGER, niveau_etude INTEGER, formation INTEGER, classe INTEGER, '
        'diplome INTEGER, commune_residence INTEGER, activite INTEGER, sexe TEXT, numero_piece TEXT, piece_delivre INTEGER, date_emission_piece TEXT,'
        'metier INTEGER, quartier_residence TEXT, adresse_postal TEXT, photo_artisan TEXT, photo_cni_recto TEXT, photo_cni_verso TEXT, photo_diplome TEXT,'
        'date_expiration_carte TEXT, statut_kyc INTEGER, statut_paiement INTEGER, longitude REAL, latitude REAL, regime_social INTEGER, regime_travailleur INTEGER,'
        'regime_imposition_taxe_communale INTEGER, regime_imposition_micro_entreprise INTEGER, comptabilite INTEGER, chiffre_affaire INTEGER, cnps TEXT, cmu TEXT,'
        'presence_compte_bancaire INTEGER, type_compte_bancaire INTEGER, crm INTEGER, departement INTEGER, sous_prefecture INTEGER,'
        'specialite INTEGER, activite_principale INTEGER, activite_secondaire INTEGER,'
        'raison_social TEXT, sigle TEXT, date_creation TEXT, commune_activite INTEGER, quartier_activite TEXT,'
        'rccm TEXT, niveau_equipement INTEGER, millisecondes INTEGER)');

    await db.execute('CREATE TABLE apprenti (id INTEGER PRIMARY KEY, nom TEXT, prenom TEXT, contact1 TEXT, contact2 TEXT,'
        'email TEXT, numero_immatriculation TEXT, lieu_naissance_autre TEXT, lieu_naissance INTEGER, civilite TEXT, date_naissance TEXT,'
        'nationalite INTEGER, sexe TEXT, type_document INTEGER, niveau_etude INTEGER, metier INTEGER, classe INTEGER, '
        'diplome INTEGER, date_debut_apprentissage TEXT, commune_residence INTEGER, quartier_residence TEXT, adresse_postal TEXT, date_emission_piece TEXT,'
        'numero_piece TEXT, piece_delivre INTEGER, photo TEXT, photo_cni_recto TEXT, photo_cni_verso TEXT,'
        'statut_kyc INTEGER, statut_paiement INTEGER, longitude REAL, latitude REAL, a_suivi_formation INTEGER, centre_formation_metier TEXT, '
        'intitule_formation_metier TEXT, formation_metier_terminee INTEGER, diplome_obtenu_metier TEXT, cnps TEXT, cmu TEXT,'
        'artisan_id INTEGER, entreprise_id INTEGER, millisecondes INTEGER)');

    await db.execute('CREATE TABLE compagnon (id INTEGER PRIMARY KEY, nom TEXT, prenom TEXT, contact1 TEXT, contact2 TEXT,'
        'email TEXT, numero_immatriculation TEXT, lieu_naissance_autre TEXT, lieu_naissance INTEGER, civilite TEXT, date_naissance TEXT,'
        'nationalite INTEGER, sexe TEXT, type_document INTEGER, niveau_etude INTEGER, specialite INTEGER, classe INTEGER, '
        'diplome INTEGER, apprentissage_metier INTEGER, date_debut_compagnonnage TEXT, commune_residence INTEGER, quartier_residence TEXT, adresse_postal TEXT, date_emission_piece TEXT,'
        'numero_piece TEXT, piece_delivre INTEGER, photo TEXT, photo_cni_recto TEXT, photo_cni_verso TEXT, photo_diplome TEXT,'
        'statut_kyc INTEGER, statut_paiement INTEGER, longitude REAL, latitude REAL, cnps TEXT, cmu TEXT, artisan_id INTEGER, entreprise_id INTEGER,'
        'millisecondes INTEGER)');

    await db.execute('CREATE TABLE entreprise (id INTEGER PRIMARY KEY, crm INTEGER, departement INTEGER,'
        'sous_prefecture INTEGER, civilite TEXT, nom TEXT, prenom TEXT, date_naissance TEXT, lieu_naissance INTEGER,'
        'lieu_naissance_autre TEXT, nationalite INTEGER, statut_matrimonial INTEGER, type_document INTEGER,'
        'numero_piece TEXT, piece_delivre INTEGER, date_emission_piece TEXT, commune_residence INTEGER,'
        'quartier_residence TEXT, adresse_postal TEXT, contact1 TEXT, contact2 TEXT, email TEXT,'
        'forme_juridique INTEGER, activite_principale INTEGER, activite_secondaire INTEGER, denomination TEXT,'
        'sigle TEXT, date_creation TEXT, objet_social TEXT, rccm TEXT, date_rccm TEXT, capital_social INTEGER,'
        'regime_fiscal INTEGER, duree_personne_morale INTEGER, cnps_entreprise TEXT, compte_contribuable TEXT,'
        'total_associe INTEGER, commune_siege INTEGER, quartier_siege TEXT, lot TEXT, telephone TEXT,'
        'statut_kyc INTEGER, statut_paiement INTEGER, longitude REAL, latitude REAL, millisecondes INTEGER)');
  }
}