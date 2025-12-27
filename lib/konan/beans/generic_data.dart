class GenericData {
  final String libelle;
  final int id;

  const GenericData({
    required this.libelle,
    required this.id
  });

  factory GenericData.fromJson(Map<String, dynamic> json) {
    return GenericData(
        libelle: json['libelle'],
        id: json['id']
    );
  }
}