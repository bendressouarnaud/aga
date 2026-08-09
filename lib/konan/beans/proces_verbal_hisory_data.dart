class ProcesVerbalHisoryData {
  final String nomEntite;
  final String contactEntite;
  final String dateEnrolement;
  final String datePv;
  final String metier;
  final String agent;
  final String dateReglement;

  const ProcesVerbalHisoryData({
    required this.nomEntite,
    required this.contactEntite,
    required this.dateEnrolement,
    required this.datePv,
    required this.metier,
    required this.agent,
    required this.dateReglement
  });

  factory ProcesVerbalHisoryData.fromJson(Map<String, dynamic> json) {
    return ProcesVerbalHisoryData(
      nomEntite: json['nom_entite'],
      contactEntite: json['contact_entite'],
      dateEnrolement: json['date_enrolement'],
      datePv: json['date_pv'],
        metier: json['metier'],
      agent: json['agent'],
      dateReglement: json['date_reglement']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nom_entite'] = nomEntite;
    data['contact_entite'] = contactEntite;
    data['date_enrolement'] = dateEnrolement;
    data['date_pv'] = datePv;
    data['metier'] = metier;
    data['agent'] = agent;
    data['date_reglement'] = dateReglement;
    return data;
  }
}