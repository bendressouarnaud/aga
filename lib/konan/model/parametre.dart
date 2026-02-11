class Parametre {

  // A t t r i b u t e s  :
  final int id;
  final int topicSubscription;
  final int param1;
  final int param2;
  final String param3;

  // M e t h o d s  :
  Parametre({required this.id, required this.topicSubscription, required this.param1, required this.param2
    , required this.param3});
  factory Parametre.fromDatabaseJson(Map<String, dynamic> data) => Parametre(
      id: data['id'],
      topicSubscription: data['topic_subscription'],
      param1: data['param1'],
    param2: data['param2'],
    param3: data['param3']
  );

  Map<String, dynamic> toDatabaseJson() => {
    "id": id,
    "topic_subscription": topicSubscription,
    "param1": param1,
    "param2": param2,
    "param3": param3
  };
}