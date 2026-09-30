import 'dart:async';
import 'dart:io' as io;

import 'package:dart_mcp/stdio.dart';
import 'package:http/http.dart' as http;

import 'backend_client.dart';
import 'server.dart';

/// The backend of `--backend <url>`, else `LA_TOOLKIT_BACKEND`, else the
/// production image's port.
Uri backendUri(List<String> args, Map<String, String> env) {
  final int i = args.indexOf('--backend');
  return Uri.parse(
    i >= 0 && i + 1 < args.length
        ? args[i + 1]
        : env['LA_TOOLKIT_BACKEND'] ?? 'http://localhost:2010',
  );
}

/// Where saves leave a backup of the project: `--backup-dir <dir>`, else
/// `LA_TOOLKIT_MCP_BACKUP_DIR`, else null (the server's default under
/// `~/.cache`). The toolkit image points it at its logs volume.
io.Directory? backupDirOf(List<String> args, Map<String, String> env) {
  final int i = args.indexOf('--backup-dir');
  final String? dir = i >= 0 && i + 1 < args.length
      ? args[i + 1]
      : env['LA_TOOLKIT_MCP_BACKUP_DIR'];
  return dir == null || dir.isEmpty ? null : io.Directory(dir);
}

/// Runs the server over a stdio-like pair. [output] is the protocol channel,
/// so every `print` made while serving (the core models log through it) goes
/// to [log] instead: a single stray line there would break the client.
LaToolkitMcpServer serveStdio({
  required Uri backend,
  required Stream<List<int>> input,
  required StreamSink<List<int>> output,
  required StringSink log,
  http.Client? client,
  io.Directory? backupDir,
}) => runZoned(
  () => LaToolkitMcpServer(
    stdioChannel(input: input, output: output),
    backend: BackendClient(backend, client: client),
    backupDir: backupDir,
  ),
  zoneSpecification: ZoneSpecification(
    print: (Zone self, ZoneDelegate parent, Zone zone, String line) =>
        log.writeln(line),
  ),
);

/// `serveStdio` on the process's own stdin, stdout and stderr.
void serveProcessStdio(List<String> args) => serveStdio(
  backend: backendUri(args, io.Platform.environment),
  backupDir: backupDirOf(args, io.Platform.environment),
  input: io.stdin,
  output: io.stdout,
  log: io.stderr,
);
