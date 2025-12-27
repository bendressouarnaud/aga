class MessageResponse {
  final int id;
  final String local_dateTime;
  final String message;
  final int http_status;

  const MessageResponse({
    required this.id,
    required this.local_dateTime,
    required this.message,
    required this.http_status
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
        id: json['id'],
        local_dateTime: json['local_dateTime'],
        message: json['message'],
        http_status: json['http_status']
    );
  }
}