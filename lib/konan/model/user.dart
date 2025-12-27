class User {

  // https://vaygeth.medium.com/reactive-flutter-todo-app-using-bloc-design-pattern-b71e2434f692
  // https://pythonforge.com/dart-classes-heritage/

  // A t t r i b u t e s  :
  final int id;
  final String nom;
  final String email;
  final String pwd;
  final String jwt;
  final String profil;
  final int milliseconds;

  // M e t h o d s  :
  User({required this.id, required this.nom, required this.email, required this.pwd, required this.jwt,
    required this.profil, required this.milliseconds});
  factory User.fromDatabaseJson(Map<String, dynamic> data) => User(
    //This will be used to convert JSON objects that
    //are coming from querying the database and converting
    //it into a Todo object
    id: data['id'],
    nom: data['nom'],
    email: data['email'],
    pwd: data['pwd'],
    jwt: data['jwt'],
    profil: data['profil'],
    milliseconds: data['milliseconds']
  );

  Map<String, dynamic> toDatabaseJson() => {
    //This will be used to convert Todo objects that
    //are to be stored into the datbase in a form of JSON
    "id": id,
    "nom": nom,
    "email": email,
    "pwd": pwd,
    "jwt": jwt,
    "profil": profil,
    "milliseconds": milliseconds
  };
}