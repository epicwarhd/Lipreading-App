class ChatMessage {
  // String messageContent;
  // String messageType;
  // ChatMessage({required this.messageContent, required this.messageType});

  ChatMessage(
      {this.toId,
      required this.msg,
      this.read,
      required this.type,
      this.fromId,
      required this.sent,
      this.videoPath,
      this.thumbnail});

  late final String? toId;
  late final String msg;
  late final String? read;
  late final String? fromId;
  late final DateTime sent;
  late final String type;
  late final String? videoPath;
  late final String? thumbnail;

  ChatMessage.fromJson(Map<String, dynamic> json) {
    toId = json['receiver'].toString();
    msg = json['message'].toString();
    read = json['read'].toString();
    type = json['type'].toString();
    // type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    fromId = json['sender'].toString();
    sent = json['sent'].toDate();
    videoPath = json['video_path'];
    // duration = json['duration']
    thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['receiver'] = toId;
    data['message'] = msg;
    data['read'] = read;
    data['type'] = type;
    data['sender'] = fromId;
    data['sent'] = sent;
    data['video_path'] = videoPath;
    return data;
  }
}

// enum Type { text, image }