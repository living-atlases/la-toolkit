// Vendored from living-atlas-kb (https://github.com/living-atlases/kb),
// dart/lib/src/kb_chat_widget.dart. Keep in sync with upstream.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen_ai_chat_ui/flutter_gen_ai_chat_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'kb_client.dart';
import 'kb_config.dart';

/// Starter questions shown in the empty chat state.
const _kStarterQuestions = [
  'How do I deploy a Living Atlas with la-toolkit?',
  'How does ala-install configure the collectory MySQL database and user?',
  'How do I set up SSL/TLS in my portal?',
  'How do I add a new species list to species-lists?',
  'What pipelines steps run during occurrence indexing?',
];

/// Maximum number of prior messages (user+assistant) sent as history.
const int _kMaxHistoryMessages = 12;

/// Ready-to-use chat widget that connects to the Living Atlas KB.
///
/// Displays a full-screen chat UI powered by [flutter_gen_ai_chat_ui].
/// Streams answers from the KB `/api/chat` endpoint via SSE.
///
/// Example:
/// ```dart
/// KbChatWidget(config: KbConfig(baseUrl: 'https://kb.l-a.site'))
/// ```
class KbChatWidget extends StatefulWidget {
  final KbConfig config;

  /// Optional custom title for the app bar / header.
  final String title;

  const KbChatWidget({
    super.key,
    required this.config,
    this.title = 'Living Atlas KB',
  });

  @override
  State<KbChatWidget> createState() => _KbChatWidgetState();
}

class _KbChatWidgetState extends State<KbChatWidget> {
  late final KbClient _client;
  late final ChatMessagesController _controller;
  late final ChatUser _userMe;
  late final ChatUser _userBot;
  late final TextEditingController _inputController;
  bool _isLoading = false;
  StreamSubscription<String>? _streamSub;

  @override
  void initState() {
    super.initState();
    _client = KbClient(config: widget.config);
    _userMe = const ChatUser(id: 'user', name: 'You');
    _userBot = const ChatUser(id: 'bot', name: 'LA Knowledge Base');
    _controller = ChatMessagesController();
    _inputController = TextEditingController();
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _client.dispose();
    _controller.dispose();
    _inputController.dispose();
    super.dispose();
  }

  /// Build conversation history from messages already in the controller.
  ///
  /// Excludes the user message just added (current turn). Keeps only the
  /// last [_kMaxHistoryMessages] entries to bound prompt size.
  List<Map<String, String>> _buildHistory(ChatMessage currentUserMessage) {
    final history = <Map<String, String>>[];
    for (final m in _controller.messages) {
      if (identical(m, currentUserMessage)) continue;
      if (m.user.id == _userMe.id) {
        history.add({'role': 'user', 'content': m.text});
      } else if (m.user.id == _userBot.id) {
        if (m.text.trim().isEmpty) continue;
        history.add({'role': 'assistant', 'content': m.text});
      }
    }
    if (history.length > _kMaxHistoryMessages) {
      return history.sublist(history.length - _kMaxHistoryMessages);
    }
    return history;
  }

  /// Send the current text in [_inputController] as a chat message.
  void _sendFromInput() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    final msg = ChatMessage(
      text: text,
      user: _userMe,
      createdAt: DateTime.now(),
    );
    _inputController.clear();
    _handleSend(msg);
  }

  Future<void> _handleSend(ChatMessage userMessage) async {
    _controller.addMessage(userMessage);

    // Snapshot history BEFORE adding the placeholder bot message.
    final history = _buildHistory(userMessage);

    setState(() => _isLoading = true);

    final botMsgId = 'bot_${DateTime.now().millisecondsSinceEpoch}';
    final botMsg = ChatMessage(
      text: '',
      user: _userBot,
      createdAt: DateTime.now(),
      isMarkdown: true,
      customProperties: {'id': botMsgId},
    );

    // Defer adding the bot bubble until the first token arrives so the user
    // never sees an empty assistant message. The loading spinner (isLoading)
    // provides feedback in the meantime.
    bool botAdded = false;

    final buffer = StringBuffer();
    final completer = Completer<void>();

    void updateBot(String text) {
      if (!botAdded) {
        _controller.addStreamingMessage(botMsg);
        botAdded = true;
      }
      _controller.updateMessage(botMsg.copyWith(text: text));
    }

    _streamSub = _client.chat(userMessage.text, history: history).listen(
      (token) {
        buffer.write(token);
        updateBot(buffer.toString());
      },
      onError: (e) {
        if (e is KbException) {
          updateBot('_Error: ${e.message}_');
        } else {
          updateBot('_Unexpected error: ${e}_');
        }
        if (!completer.isCompleted) completer.complete();
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete();
      },
      cancelOnError: true,
    );

    try {
      await completer.future;
    } finally {
      _streamSub = null;
      if (botAdded) _controller.stopStreamingMessage(botMsgId);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleStop() {
    final sub = _streamSub;
    if (sub == null) return;
    sub.cancel();
    _streamSub = null;
    // Append "(stopped)" marker to the most recent bot message.
    for (final m in _controller.messages.reversed) {
      if (m.user.id == _userBot.id) {
        _controller.updateMessage(
          m.copyWith(text: '${m.text}\n\n_(stopped)_'),
        );
        final stoppedId = m.customProperties?['id'] as String?;
        if (stoppedId != null) {
          _controller.stopStreamingMessage(stoppedId);
        }
        break;
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        // Ctrl+Enter (Linux/Windows) and Cmd+Enter (macOS/web) → send.
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.enter,
        ): _sendFromInput,
        LogicalKeySet(
          LogicalKeyboardKey.meta,
          LogicalKeyboardKey.enter,
        ): _sendFromInput,
      },
      child: Stack(
        children: [
          AiChatWidget(
            currentUser: _userMe,
            aiUser: _userBot,
            controller: _controller,
            onSendMessage: _handleSend,
            loadingConfig: LoadingConfig(isLoading: _isLoading),
            aiName: widget.title,
            enableAnimation: true,
            exampleQuestions: _kStarterQuestions
                .map((q) => ExampleQuestion(question: q))
                .toList(),
            inputOptions: InputOptions(
              textController: _inputController,
              decoration: const InputDecoration(
                hintText: 'Ask about LA services, ala-install, biocache…',
              ),
            ),
            messageOptions: MessageOptions(
              showCopyButton: true,
              onCopy: (text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              onTapLink: (text, href, title) async {
                if (href == null) return;
                final uri = Uri.tryParse(href);
                if (uri != null && await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ),
          if (_isLoading)
            Positioned(
              right: 16,
              bottom: 80,
              child: FloatingActionButton.small(
                heroTag: 'kb_stop_btn',
                tooltip: 'Stop',
                onPressed: _handleStop,
                child: const Icon(Icons.stop),
              ),
            ),
        ],
      ),
    );
  }
}
