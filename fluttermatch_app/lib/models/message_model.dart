class MessageModel {
  final int id;
  final int matchId;
  final int senderId;
  final String body;
  final bool isMine;
  final bool isRead;
  final DateTime createdAt;

  const MessageModel({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.body,
    required this.isMine,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> j) => MessageModel(
    id: j['id'],
    matchId: j['match_id'],
    senderId: j['sender_id'],
    body: j['body'],
    isMine: j['is_mine'] ?? false,
    isRead: j['is_read'] ?? false,
    createdAt: DateTime.parse(j['created_at']),
  );

  MessageModel copyWith({bool? isRead}) => MessageModel(
    id: id,
    matchId: matchId,
    senderId: senderId,
    body: body,
    isMine: isMine,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );
}
