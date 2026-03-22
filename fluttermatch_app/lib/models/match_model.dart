class MatchOtherUser {
  final int id;
  final String name;
  final String? photoUrl;

  const MatchOtherUser({required this.id, required this.name, this.photoUrl});

  factory MatchOtherUser.fromJson(Map<String, dynamic> j) =>
      MatchOtherUser(id: j['id'], name: j['name'], photoUrl: j['photo_url']);
}

class LastMessage {
  final String body;
  final bool isMine;
  final DateTime createdAt;

  const LastMessage({
    required this.body,
    required this.isMine,
    required this.createdAt,
  });

  factory LastMessage.fromJson(Map<String, dynamic> j) => LastMessage(
    body: j['body'],
    isMine: j['is_mine'] ?? false,
    createdAt: DateTime.parse(j['created_at']),
  );
}

class MatchModel {
  final int id;
  final MatchOtherUser otherUser;
  final LastMessage? lastMessage;
  final int unreadCount;
  final DateTime? matchedAt;

  const MatchModel({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
    this.matchedAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> j) => MatchModel(
    id: j['id'],
    otherUser: MatchOtherUser.fromJson(j['other_user']),
    lastMessage: j['last_message'] != null
        ? LastMessage.fromJson(j['last_message'])
        : null,
    unreadCount: j['unread_count'] ?? 0,
    matchedAt: j['matched_at'] != null ? DateTime.parse(j['matched_at']) : null,
  );

  MatchModel copyWith({int? unreadCount, LastMessage? lastMessage}) =>
      MatchModel(
        id: id,
        otherUser: otherUser,
        lastMessage: lastMessage ?? this.lastMessage,
        unreadCount: unreadCount ?? this.unreadCount,
        matchedAt: matchedAt,
      );
}
