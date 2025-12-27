class SearchResponseData {
  final String nom;
  final String metier;
  final String date;
  final String contact;
  final int id;

  const SearchResponseData({
    required this.nom,
    required this.metier,
    required this.date,
    required this.contact,
    required this.id
  });

  factory SearchResponseData.fromJson(Map<String, dynamic> json) {
    return SearchResponseData(
        nom: json['nom'],
        metier: json['metier'],
        date: json['date'],
        contact: json['contact'],
        id: json['id']
    );
  }
}