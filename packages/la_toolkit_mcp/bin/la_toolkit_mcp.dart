import 'dart:io' as io;

import 'package:dart_mcp/stdio.dart';
import 'package:la_toolkit_mcp/la_toolkit_mcp.dart';

/// Runs the server over stdio. The backend is taken from `--backend <url>` or
/// `LA_TOOLKIT_BACKEND`, defaulting to the production image's port.
///
/// stdio only on purpose: the backend API has no authentication, so this
/// server must run next to the toolkit, never behind a public HTTP endpoint.
void main(List<String> args) {
  final int i = args.indexOf('--backend');
  final String url = i >= 0 && i + 1 < args.length
      ? args[i + 1]
      : io.Platform.environment['LA_TOOLKIT_BACKEND'] ?? 'http://localhost:2010';
  LaToolkitMcpServer(
    stdioChannel(input: io.stdin, output: io.stdout),
    backend: BackendClient(Uri.parse(url)),
  );
}
