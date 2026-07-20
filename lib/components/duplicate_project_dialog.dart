import 'package:flutter/material.dart';

import '../models/la_project.dart';
import '../utils/regexp.dart';

/// Dialog to collect the new names for a project duplicate. On confirm it
/// invokes [onDuplicate] with the new shortName, longName, domain and dirName.
///
/// The duplicate may reuse the original shortName, longName and domain (they
/// are what shows up in the portal); projects are told apart by their [dirName]
/// (the internal directory where inventories/config are generated), which must
/// be unique.
class DuplicateProjectDialog extends StatefulWidget {
  const DuplicateProjectDialog({
    required this.sourceProject,
    required this.existingDirNames,
    required this.onDuplicate,
    super.key,
  });

  final LAProject sourceProject;
  final Set<String> existingDirNames;
  final void Function(
    String shortName,
    String longName,
    String domain,
    String dirName,
  )
  onDuplicate;

  static Future<void> show(
    BuildContext context, {
    required LAProject sourceProject,
    required Set<String> existingDirNames,
    required void Function(
      String shortName,
      String longName,
      String domain,
      String dirName,
    )
    onDuplicate,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => DuplicateProjectDialog(
        sourceProject: sourceProject,
        existingDirNames: existingDirNames,
        onDuplicate: onDuplicate,
      ),
    );
  }

  @override
  State<DuplicateProjectDialog> createState() => _DuplicateProjectDialogState();
}

class _DuplicateProjectDialogState extends State<DuplicateProjectDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _shortNameController;
  late final TextEditingController _longNameController;
  late final TextEditingController _domainController;
  late final TextEditingController _dirNameController;

  @override
  void initState() {
    super.initState();
    final LAProject source = widget.sourceProject;
    _shortNameController = TextEditingController(text: source.shortName);
    _longNameController = TextEditingController(text: source.longName);
    _domainController = TextEditingController(text: source.domain);
    _dirNameController = TextEditingController(
      text: '${source.dirName ?? source.suggestDirName()}_copy',
    );
  }

  @override
  void dispose() {
    _shortNameController.dispose();
    _longNameController.dispose();
    _domainController.dispose();
    _dirNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Duplicate "${widget.sourceProject.shortName}"'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'This will create a full independent copy of this project '
                '(servers, services, configuration). You can keep the same '
                'short name, long name and domain: projects are told apart by '
                'their directory name. Servers will be renamed with a suffix '
                'derived from the directory name to avoid ssh conflicts, '
                'keeping their IPs, so remember to update them if the copy '
                'points to other machines. Passwords and local customizations '
                '(local-extras, branding) are preserved from the original.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dirNameController,
                decoration: const InputDecoration(
                  labelText: 'Directory name',
                  hintText: "e.g. 'gbif_es_copy'",
                ),
                autofocus: true,
                validator: (String? value) {
                  final String v = value?.trim() ?? '';
                  if (v.isEmpty ||
                      !LARegExp.ansibleDirnameRegexpPermissive.hasMatch(v)) {
                    return 'Invalid directory name (lowercase letters, '
                        'numbers, hyphens and underscores)';
                  }
                  if (v == widget.sourceProject.dirName) {
                    return 'Should be different from the original directory name';
                  }
                  if (widget.existingDirNames.contains(v)) {
                    return 'That directory name is already in use';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _shortNameController,
                decoration: const InputDecoration(
                  labelText: 'Short name',
                  hintText: 'Short name of the new portal',
                ),
                validator: (String? value) =>
                    value == null ||
                        value.trim().isEmpty ||
                        !LARegExp.shortNameRegexp.hasMatch(value.trim())
                    ? 'Invalid short name'
                    : null,
              ),
              TextFormField(
                controller: _longNameController,
                decoration: const InputDecoration(
                  labelText: 'Long name',
                  hintText: 'Long name of the new portal',
                ),
                validator: (String? value) =>
                    value == null ||
                        value.trim().isEmpty ||
                        !LARegExp.projectNameRegexp.hasMatch(value.trim())
                    ? 'Invalid project name'
                    : null,
              ),
              TextFormField(
                controller: _domainController,
                decoration: const InputDecoration(
                  labelText: 'Domain',
                  hintText: 'e.g. l-a.site',
                ),
                validator: (String? value) =>
                    value == null ||
                        !LARegExp.domainRegexp.hasMatch(value.trim())
                    ? 'Invalid domain'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.copy),
          label: const Text('DUPLICATE'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop();
              widget.onDuplicate(
                _shortNameController.text.trim(),
                _longNameController.text.trim(),
                _domainController.text.trim(),
                _dirNameController.text.trim(),
              );
            }
          },
        ),
      ],
    );
  }
}
