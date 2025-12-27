class EnrolementAmountToPay {
  final int seul;
  final int tout;

  const EnrolementAmountToPay({
    required this.seul,
    required this.tout
  });

  factory EnrolementAmountToPay.fromJson(Map<String, dynamic> json) {
    return EnrolementAmountToPay(
        seul: json['seul'],
        tout: json['tout']
    );
  }
}