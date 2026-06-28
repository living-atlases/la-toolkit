import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ai/kb_chat_widget.dart';
import 'ai/kb_config.dart';

/// AI Assistant page: a RAG chat backed by the Living Atlas Knowledge Base
/// (https://kb.l-a.site). The endpoint is configurable via the `KB_URL` env
/// var so it can also point at a self-hosted KB instance.
class AiAssistantPage extends StatelessWidget {
  const AiAssistantPage({super.key});

  static const String routeName = 'ai-assistant';

  static const String _defaultKbUrl = 'https://kb.l-a.site';

  @override
  Widget build(BuildContext context) {
    final String baseUrl = dotenv.env['KB_URL'] ?? _defaultKbUrl;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Close',
          onPressed: () => Beamer.of(context).beamToNamed('/'),
        ),
        title: const Text('AI Assistant (beta)'),
      ),
      body: KbChatWidget(
        config: KbConfig(baseUrl: baseUrl),
        title: 'LA Knowledge Base',
      ),
    );
  }
}
