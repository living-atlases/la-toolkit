import 'package:flutter/material.dart';

import 'utils/ai_service.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  static const String routeName = 'ai-assistant';

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage> {
  late List<ChatMessage> _messages;
  late TextEditingController _messageController;
  bool _isLoading = false;
  bool _aiAvailable = false;

  @override
  void initState() {
    super.initState();
    _messages = <ChatMessage>[];
    _messageController = TextEditingController();
    _initializeAi();
  }

  Future<void> _initializeAi() async {
    final bool available = await AiService.isAvailable();
    setState(() {
      _aiAvailable = available;
    });

    if (available) {
      _addWelcomeMessage();
    } else {
      _addErrorMessage(
        'AI Assistant is not available. '
        'Please ensure the backend is running and ChromaDB is connected.',
      );
    }
  }

  void _addWelcomeMessage() {
    _messages.add(
      ChatMessage(
        id: 'welcome',
        role: ChatRole.assistant,
        content: '''
# Welcome to LA Toolkit AI Assistant 👋

I can help you with:
- **Installation and configuration guidance** for Living Atlas
- **Troubleshooting** deployment issues
- **Service-specific questions** (collectory, biocache, spatial, etc.)
- **Best practices** for Living Atlas setups

## Example questions:
- "How do I configure collectory permissions?"
- "What are the requirements for biocache installation?"
- "How do I troubleshoot spatial service errors?"
- "What services should I enable for a minimal setup?"

Type your question below and I'll search the LA Toolkit knowledge base for you.''',
      ),
    );
    setState(() {});
  }

  void _addErrorMessage(String message) {
    _messages.add(
      ChatMessage(
        id: DateTime.now().toString(),
        role: ChatRole.assistant,
        content: '⚠️ **Error**: $message',
        isError: true,
      ),
    );
    setState(() {});
  }

  Future<void> _handleSubmit() async {
    final String question = _messageController.text.trim();
    if (question.isEmpty) {
      return;
    }

    // Add user message
    _messages.add(
      ChatMessage(
        id: DateTime.now().toString(),
        role: ChatRole.user,
        content: question,
      ),
    );

    _messageController.clear();
    setState(() => _isLoading = true);

    try {
      // Query AI (projectId would be passed from Redux context in future)
      final Object response = await AiService.query(question: question);

      // Add assistant response
      final Map<String, dynamic> responseMap =
          response as Map<String, dynamic>? ?? <String, dynamic>{};
      _messages.add(
        ChatMessage(
          id: DateTime.now().toString(),
          role: ChatRole.assistant,
          content: (responseMap['answer'] as String?) ?? 'No answer available',
          sources: _extractSources(responseMap['sources']),
          context: responseMap['contextUsed'] as Map<String, dynamic>?,
        ),
      );
    } catch (e) {
      _messages.add(
        ChatMessage(
          id: DateTime.now().toString(),
          role: ChatRole.assistant,
          content:
              '❌ **Error**: ${e.toString().replaceFirst('Exception: ', '')}',
          isError: true,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<ChatSource>? _extractSources(dynamic sources) {
    if (sources is! List) {
      return null;
    }

    return sources.map<ChatSource>((dynamic source) {
      final Map<String, dynamic> sourceMap =
          source as Map<String, dynamic>? ?? <String, dynamic>{};
      return ChatSource(
        title: (sourceMap['file'] as String?) ?? 'Unknown',
        description: (sourceMap['snippet'] as String?) ?? '',
        url: sourceMap['file'] as String?,
        relevance: (sourceMap['relevance'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        backgroundColor: _aiAvailable ? null : Colors.orange,
      ),
      body: Column(
        children: <Widget>[
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text('Start chatting with the AI Assistant'),
                  )
                : ListView.builder(
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final ChatMessage message =
                          _messages[_messages.length - 1 - index];
                      return _buildMessageWidget(context, message);
                    },
                  ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask a question about LA Toolkit...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    enabled: _aiAvailable && !_isLoading,
                    onSubmitted: (String _) =>
                        _aiAvailable && !_isLoading ? _handleSubmit() : null,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _aiAvailable && !_isLoading ? _handleSubmit : null,
                  mini: true,
                  tooltip: 'Send message',
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                          ),
                        )
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageWidget(BuildContext context, ChatMessage message) {
    final bool isUser = message.role == ChatRole.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!isUser) ...<Widget>[
            const CircleAvatar(child: Icon(Icons.smart_toy)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Main message content
                  _buildMessageContent(context, message.content),

                  // Sources if available
                  if (message.sources != null &&
                      message.sources!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    _buildSourcesSection(context, message.sources!),
                  ],

                  // Context if available
                  if (message.context != null) ...<Widget>[
                    const SizedBox(height: 8),
                    _buildContextSection(context, message.context),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...<Widget>[
            const SizedBox(width: 8),
            const CircleAvatar(child: Icon(Icons.person)),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, String content) {
    // Simple markdown rendering
    if (content.contains('#') || content.contains('**')) {
      return SelectableText.rich(TextSpan(children: _parseMarkdown(content)));
    }

    return SelectableText(
      content,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  List<InlineSpan> _parseMarkdown(String text) {
    final List<InlineSpan> spans = <InlineSpan>[];
    final List<String> lines = text.split('\n');

    for (final String line in lines) {
      if (line.startsWith('# ')) {
        spans.add(
          TextSpan(
            text: '${line.substring(2)}\n',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
      } else if (line.startsWith('## ')) {
        spans.add(
          TextSpan(
            text: '${line.substring(3)}\n',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        );
      } else if (line.contains('**')) {
        // Bold text
        final RegExp boldRegex = RegExp(r'\*\*(.+?)\*\*');
        int current = 0;
        for (final RegExpMatch match in boldRegex.allMatches(line)) {
          spans.add(TextSpan(text: line.substring(current, match.start)));
          spans.add(
            TextSpan(
              text: match.group(1),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
          current = match.end;
        }
        if (current < line.length) {
          spans.add(TextSpan(text: '${line.substring(current)}\n'));
        }
      } else {
        spans.add(TextSpan(text: '$line\n'));
      }
    }

    return spans;
  }

  Widget _buildSourcesSection(BuildContext context, List<ChatSource> sources) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          '📚 Sources (${sources.length})',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        children: sources.map<Widget>((ChatSource source) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  source.title,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (source.description.isNotEmpty)
                  Text(
                    source.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: Colors.grey),
                  ),
                if (source.relevance != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: <Widget>[
                        const Text('Relevance: '),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: source.relevance,
                            minHeight: 4,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '${((source.relevance ?? 0.0) * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContextSection(BuildContext context, dynamic contextData) {
    if (contextData is! Map) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '🎯 Context Used',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...contextData.entries.map<Widget>((MapEntry<dynamic, dynamic> e) {
            final String value = e.value is List
                ? (e.value as List<dynamic>).join(', ')
                : e.value.toString();
            return Text(
              '${e.key}: $value',
              style: Theme.of(context).textTheme.labelSmall,
            );
          }),
        ],
      ),
    );
  }
}

// Models for chat messages
enum ChatRole { user, assistant }

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.sources,
    this.context,
    this.isError = false,
  });
  final String id;
  final ChatRole role;
  final String content;
  final List<ChatSource>? sources;
  final Map<String, dynamic>? context;
  final bool? isError;
}

class ChatSource {
  ChatSource({
    required this.title,
    required this.description,
    this.url,
    this.relevance,
  });
  final String title;
  final String description;
  final String? url;
  final double? relevance;
}
