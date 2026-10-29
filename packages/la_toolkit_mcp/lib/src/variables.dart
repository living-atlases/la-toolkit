/// The project variables of the Tune page, as la_set_variables changes them.
library;

import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_service_name.dart';
import 'package:la_toolkit_core/models/la_service_desc.dart';
import 'package:la_toolkit_core/models/la_variable_desc.dart';

/// Whether the Tune page offers [d] for [p] (project_tune_page.dart), its
/// advanced variables included: a hub only gets those of hub-capable
/// services, and a variable of a service that is not in use is hidden.
bool tunable(LAProject p, LAVariableDesc d) {
  if (!d.inTunePage || !d.enabled || d.forced) return false;
  if (d.onlyHub && !p.isHub) return false;
  final LAServiceName? dep = d.depends;
  if (dep != null) {
    if (p.isHub && !LAServiceDesc.getE(dep).hubCapable) return false;
    if (!p.getService(dep.toS()).use) return false;
  }
  if (dep == LAServiceName.pipelines && !p.isPipelinesOnVM) return false;
  return d.isVisible == null || d.isVisible!(p);
}

/// [raw] as a value of [d], or a [FormatException] saying why not.
Object parseVariableValue(LAVariableDesc d, Object? raw) {
  switch (d.type) {
    case LAVariableType.bool:
      if (raw is bool) return raw;
      throw FormatException('`${d.nameInt}` takes true or false.');
    case LAVariableType.int:
      if (raw is int) return raw;
      throw FormatException('`${d.nameInt}` takes an integer.');
    case LAVariableType.double:
      if (raw is num) return raw.toDouble();
      throw FormatException('`${d.nameInt}` takes a number.');
    case LAVariableType.String:
    case LAVariableType.select:
      if (raw is! String) {
        throw FormatException('`${d.nameInt}` takes a string.');
      }
      if (raw.isEmpty && !d.allowEmpty) {
        throw FormatException('`${d.nameInt}` cannot be empty.');
      }
      if (raw.isNotEmpty && d.regExp != null && !d.regExp!.hasMatch(raw)) {
        throw FormatException(
          '`${d.nameInt}` "${d.protected ? '(hidden)' : raw}" is not valid'
          '${d.error != null ? ': ${d.error}' : ''}.',
        );
      }
      return raw;
  }
}
