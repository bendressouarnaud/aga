class RequeteSql {

  // A t t r i b u t e s  :
  final int id;
  final String phrase;
  final String requete;

  // M e t h o d s  :
  RequeteSql({required this.id, required this.phrase, required this.requete});
  factory RequeteSql.fromDatabaseJson(Map<String, dynamic> data) => RequeteSql(
      id: data['id'],
      phrase: data['phrase'],
      requete: data['requete']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "phrase": phrase,
    "requete": requete
  };
}