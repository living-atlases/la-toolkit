import 'package:flutter/foundation.dart';

/// Another browser that has a project open, as the backend's `presence`
/// event reports it (see `api/libs/presence.js` in la_toolkit_backend).
@immutable
class PresenceSession {
  const PresenceSession({
    required this.id,
    required this.projectId,
    required this.mode,
  });

  factory PresenceSession.fromJson(Map<String, dynamic> json) =>
      PresenceSession(
        id: json['id'] as String,
        projectId: json['projectId'] as String,
        mode: json['mode'] as String,
      );

  /// The socket id of that browser.
  final String id;
  final String projectId;

  /// The page it is on: `view`, `edit`, `servers`, `tune`.
  final String mode;

  bool get isEditing => mode != 'view';

  @override
  bool operator ==(Object other) =>
      other is PresenceSession &&
      other.id == id &&
      other.projectId == projectId &&
      other.mode == mode;

  @override
  int get hashCode => Object.hash(id, projectId, mode);
}
