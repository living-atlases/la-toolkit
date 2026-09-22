import 'package:la_toolkit_mcp/la_toolkit_mcp.dart';

/// Runs the server over stdio. The backend is taken from `--backend <url>` or
/// `LA_TOOLKIT_BACKEND`, defaulting to the production image's port.
///
/// stdio only on purpose: the backend API has no authentication, so this
/// server must run next to the toolkit, never behind a public HTTP endpoint.
void main(List<String> args) => serveProcessStdio(args);
