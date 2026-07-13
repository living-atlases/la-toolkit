import 'package:flutter/material.dart';

/// A free-form tags input: shows the current tags as deletable chips and lets
/// the user type new ones (Enter/comma to add). Replaces the old fixed-list
/// selector, which was tied to (now outdated) ala-install tag catalogs.
class ManualTagsInput extends StatefulWidget {
  const ManualTagsInput({
    super.key,
    required this.initialValue,
    required this.title,
    required this.icon,
    required this.hint,
    required this.onChange,
  });

  final List<String> initialValue;
  final String title;
  final IconData icon;
  final String hint;
  final Function(List<String>) onChange;

  @override
  State<ManualTagsInput> createState() => _ManualTagsInputState();
}

class _ManualTagsInputState extends State<ManualTagsInput> {
  late final List<String> _tags = List<String>.of(widget.initialValue);
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add(String raw) {
    // Allow adding several comma-separated tags at once.
    final List<String> parts = raw
        .split(',')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty && !_tags.contains(s))
        .toList();
    _controller.clear();
    if (parts.isEmpty) {
      return;
    }
    setState(() => _tags.addAll(parts));
    widget.onChange(_tags);
  }

  void _remove(String tag) {
    setState(() => _tags.remove(tag));
    widget.onChange(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(widget.icon),
              const SizedBox(width: 8),
              Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          if (_tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _tags
                    .map(
                      (String t) => InputChip(
                        label: Text(t),
                        onDeleted: () => _remove(t),
                      ),
                    )
                    .toList(),
              ),
            ),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: widget.hint,
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _add(_controller.text),
              ),
            ),
            onSubmitted: _add,
          ),
        ],
      ),
    );
  }
}
