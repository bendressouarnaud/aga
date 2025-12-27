class ApprentissageMetier {
  final String libelle;
  final int id;

  const ApprentissageMetier({
    required this.libelle,
    required this.id
  });

  factory ApprentissageMetier.fromJson(Map<String, dynamic> json) {
    return ApprentissageMetier(
        libelle: json['libelle'],
        id: json['id']
    );
  }
}