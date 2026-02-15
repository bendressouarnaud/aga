class DailyPaymentBean {
  final String day;
  final double total;

  const DailyPaymentBean({
    required this.day,
    required this.total
  });

  factory DailyPaymentBean.fromJson(Map<String, dynamic> json) {
    return DailyPaymentBean(
        day: json['day'],
        total: json['total']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['total'] = total;
    return data;
  }
}