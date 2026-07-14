class PaymentLivraisonStatus {
  final int statutPaiement;
  final int statutLivraison;
  final int confirmationLivraison;

  const PaymentLivraisonStatus({
    required this.statutPaiement,
    required this.statutLivraison,
    required this.confirmationLivraison
  });

  factory PaymentLivraisonStatus.fromJson(Map<String, dynamic> json) {
    return PaymentLivraisonStatus(
        statutPaiement: json['statut_paiement'],
        statutLivraison: json['statut_livraison'],
      confirmationLivraison: json['confirmation_livraison'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statut_paiement'] = statutPaiement;
    data['statut_livraison'] = statutLivraison;
    data['confirmation_livraison'] = confirmationLivraison;
    return data;
  }
}