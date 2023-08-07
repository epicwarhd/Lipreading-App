class ChatUsers {
  String? name;
  String? messageText;
  String? imageURL;
  String? time;
  String? id;

  ChatUsers(
      {required this.name,
      required this.messageText,
      required this.id,
      required this.imageURL,
      required this.time});

  ChatUsers.fromJson(Map<String, dynamic> json) {
    imageURL = json['avatar'] ?? '';
    messageText = json['messageText'] ?? '';
    name = json['username'] ?? '';
    time = json['time'] ?? '';
    id = json['id'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['imageURL'] = imageURL;
    data['messageText'] = messageText;
    data['name'] = name;
    data['time'] = time;
    data['id'] = id;
    return data;
  }
}
