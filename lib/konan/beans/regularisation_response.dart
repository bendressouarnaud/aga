class RegularisationResponse {
  final int statut;
  final String message;

  const RegularisationResponse({
    required this.statut,
    required this.message
  });

  factory RegularisationResponse.fromJson(Map<String, dynamic> json) {
    return RegularisationResponse(
        statut: json['statut'],
        message: json['message']
    );
  }

  /*Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['total'] = total;
    return data;
  }*/
}