import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/constants/api_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../../models/match_model.dart';
import '../../models/message_model.dart';
import '../../providers/match_provider.dart';
import '../../services/match_service.dart';
import '../../core/network/dio_client.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final MatchModel match;

  const ChatScreen({super.key, required this.match});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  static const _pink = Color(0xFFE84393);

  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _messages = <MessageModel>[];

  WebSocketChannel? _channel;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final service = MatchService(ref.read(dioProvider));
      final msgs = await service.getMessages(widget.match.id);
      setState(() {
        _messages.addAll(msgs);
        _loading = false;
      });
      _scrollToBottom();
      ref.read(matchProvider.notifier).clearUnread(widget.match.id);
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _connectWebSocket() async {
    final token = await SecureStorage.getToken();
    if (token == null) return;

    // Reverb WebSocket URL
    final wsUrl =
        'ws://${ApiConstants.reverbHost}:${ApiConstants.reverbPort}/app/${ApiConstants.reverbKey}'
        '?protocol=7&client=flutter&version=1.0';

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    // Subscribe to private channel
    _channel!.sink.add(
      jsonEncode({
        'event': 'pusher:subscribe',
        'data': {
          'channel': 'private-match.${widget.match.id}',
          'auth': await _getChannelAuth(token),
        },
      }),
    );

    _channel!.stream.listen((raw) {
      final data = jsonDecode(raw as String);
      final event = data['event'] as String?;

      if (event == 'App\\Events\\MessageSent' || event == 'message.sent') {
        final payload = jsonDecode(data['data'] as String);
        final msg = MessageModel.fromJson(payload);

        if (!_messages.any((m) => m.id == msg.id)) {
          setState(() => _messages.add(msg));
          _scrollToBottom();
          ref
              .read(matchProvider.notifier)
              .updateLastMessage(widget.match.id, msg);
        }
      }
    });
  }

  Future<String> _getChannelAuth(String token) async {
    // Ask Laravel to sign the channel subscription
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.post(
        '/broadcasting/auth',
        data: {
          'socket_id': 'flutter.${DateTime.now().millisecondsSinceEpoch}',
          'channel_name': 'private-match.${widget.match.id}',
        },
      );
      return res.data['auth'] as String;
    } catch (_) {
      return '';
    }
  }

  Future<void> _sendMessage() async {
    final body = _msgCtrl.text.trim();
    if (body.isEmpty || _sending) return;

    _msgCtrl.clear();
    setState(() => _sending = true);

    try {
      final service = MatchService(ref.read(dioProvider));
      final msg = await service.sendMessage(widget.match.id, body);
      setState(() => _messages.add(msg));
      _scrollToBottom();
      ref.read(matchProvider.notifier).updateLastMessage(widget.match.id, msg);
    } catch (_) {
      _msgCtrl.text = body; // restore on failure
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final other = widget.match.otherUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1A1A2E),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFFFE0F0),
              backgroundImage: other.photoUrl != null
                  ? NetworkImage(other.photoUrl!)
                  : null,
              child: other.photoUrl == null
                  ? const Icon(Icons.person, color: _pink, size: 20)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              other.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: _pink))
                : _messages.isEmpty
                ? _emptyChat()
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) =>
                        _MessageBubble(message: _messages[i]),
                  ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _emptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💞', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            "You matched with ${widget.match.otherUser.name}!",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Say something nice 👋',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: _pink,
                  shape: BoxShape.circle,
                ),
                child: _sending
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;

  static const _pink = Color(0xFFE84393);

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMine ? _pink : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMine ? 18 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.body,
                    style: TextStyle(
                      color: isMine ? Colors.white : const Color(0xFF1A1A2E),
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.createdAt),
                        style: TextStyle(
                          color: isMine
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey.shade400,
                          fontSize: 10,
                        ),
                      ),
                      if (isMine) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 13,
                          color: message.isRead
                              ? Colors.white
                              : Colors.white.withOpacity(0.6),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final localDt = dt.toLocal();
    final h = localDt.hour.toString().padLeft(2, '0');
    final m = localDt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
