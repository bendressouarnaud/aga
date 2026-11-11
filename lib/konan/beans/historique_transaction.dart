class HistoriqueTransaction {
  final String entite;
  final String contact;
  final String requesterType;
  final int requesterId;
  final int montant;
  final int millisecondes;
  final int statutPaiement;
  final String transactionId;

  const HistoriqueTransaction({
    required this.entite,
    required this.contact,
    required this.requesterType,
    required this.requesterId,
    required this.montant,
    required this.millisecondes,
    required this.statutPaiement,
    required this.transactionId,
  });

  /*factory HistoriqueTransaction.fromJson(Map<String, dynamic> json) {
    return HistoriqueTransaction(
        entite: json['entite'],
        total: json['total']
    );
  }*/

  /*Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['total'] = total;
    return data;
  }*/
}