class StatsBeanManager {
  final int id;
  final String nom;
  final String contact;
  final String datenaissance;
  final String metier;
  final int paiement;
  final String commune;
  final String type;
  final String image;
  final String datenrolement;
  final String quartier;
  final int amende;
  final double latitude;
  final double longitude;

  const StatsBeanManager({
    required this.id,
    required this.nom,
    required this.contact,
    required this.datenaissance,
    required this.metier,
    required this.paiement,
    required this.commune,
    required this.type,
    required this.image,
    required this.datenrolement,
    required this.quartier,
    required this.amende,
    required this.latitude,
    required this.longitude
  });

  factory StatsBeanManager.fromJson(Map<String, dynamic> json) {
    return StatsBeanManager(
        id: json['id'],
        nom: json['nom'],
        contact: json['contact'],
        datenaissance: json['datenaissance'],
        metier: json['metier'],
      paiement: json['paiement'],
      commune: json['commune'],
        type: json['type'],
      image: json['image'],
        datenrolement: json['datenrolement'],
        quartier: json['quartier'],
        amende: json['amende'],
      latitude: json['latitude'],
      longitude: json['longitude']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nom'] = nom;
    data['contact'] = contact;
    data['datenaissance'] = datenaissance;
    data['metier'] = metier;
    data['paiement'] = paiement;
    data['commune'] = commune;
    data['type'] = type;
    data['image'] = image;
    data['datenrolement'] = datenrolement;
    data['quartier'] = quartier;
    data['amende'] = amende;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}