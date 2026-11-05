import 'projects.dart';

/// The Ansible Extras of a project: the free-form inventory text the Tune page
/// calls "Other variables", stored base64 in `additionalVariables`. It holds
/// everything the forms do not offer (`docker_config_files`,
/// `menu_config_json`, per-service overrides), in `[<group>:vars]` sections,
/// `[<group>-<hub>:vars]` for a hub.

/// The section headers the text declares, in the order they appear. A header
/// the Tune page left commented out counts: a service that is not in use gets
/// its section written as a comment, and uncommenting it is how it is enabled.
List<String> extrasSections(String text) {
  // A commented-out header carries the Tune page's "uncomment this line…"
  // note after it, so anything from a `#` on is not part of the name.
  final RegExp header = RegExp(r'^\s*(#\s*)?\[([^\]]+)\]\s*(#.*)?$');
  return <String>[
    for (final String line in text.split('\n'))
      if (header.firstMatch(line) case final RegExpMatch m)
        '${m.group(1) != null ? '# ' : ''}[${m.group(2)}]',
  ];
}

/// What changes from [before] to [after], line by line, for a preview. Blank
/// lines and the rules and titles the Tune page draws (`####...`) are left
/// out: what a reader needs is which variable and section lines come and go,
/// not that a decoration moved.
Json extrasDiff(String before, String after) {
  final List<String> removed = _missingFrom(before, after);
  final List<String> added = _missingFrom(after, before);
  return <String, dynamic>{
    'removed': removed,
    'added': added,
    'sections': <String, dynamic>{
      'before': extrasSections(before),
      'after': extrasSections(after),
    },
  };
}

/// The meaningful lines of [text] that [other] does not have as many of, in
/// their order in [text]. Counting repeats keeps a duplicated variable line
/// from hiding one of its copies.
List<String> _missingFrom(String text, String other) {
  final Map<String, int> spare = <String, int>{};
  for (final String line in _meaningful(other)) {
    spare[line] = (spare[line] ?? 0) + 1;
  }
  final List<String> out = <String>[];
  for (final String line in _meaningful(text)) {
    final int left = spare[line] ?? 0;
    if (left > 0) {
      spare[line] = left - 1;
    } else {
      out.add(line);
    }
  }
  return out;
}

/// [text] without blank lines and without the Tune page's decoration: a line
/// of nothing but `#` and spaces, which is how it draws its rules and titles.
Iterable<String> _meaningful(String text) sync* {
  for (final String line in text.split('\n')) {
    final String trimmed = line.trim();
    if (trimmed.isEmpty) continue;
    if (RegExp(r'^[#\s]+$').hasMatch(trimmed)) continue;
    if (RegExp(r'^#{5,}.*#{5,}$').hasMatch(trimmed)) continue;
    yield trimmed;
  }
}
