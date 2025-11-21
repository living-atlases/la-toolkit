import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../la_theme.dart';
import 'help_icon.dart';
import 'text_with_help.dart';

class Branding {
  Branding({required this.name, required this.desc});

  final String name;
  final String desc;
}

class BrandingTile extends StatefulWidget {
  const BrandingTile({
    super.key,
    required this.initialValue,
    required this.portalName,
    required this.onChange,
  });

  final String initialValue;
  final Function(String) onChange;
  final String portalName;

  @override
  State<BrandingTile> createState() => _BrandingTileState();
}

class _BrandingTileState extends State<BrandingTile> {
  late String initialValue;

  @override
  void initState() {
    initialValue = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('${widget.portalName} branding'),
      subtitle: Text(initialValue),
      onTap: () => _showDialog(context),
      leading: const Icon(Icons.format_paint),
      trailing: HelpIcon(wikipage: 'Styling-the-web-app'),
    );
  }

  void _showDialog(BuildContext context) {
    String theme = initialValue;
    Alert(
      context: context,
      closeIcon: const Icon(Icons.close),
      image: const Icon(Icons.format_paint),
      title: 'Select your branding theme',
      style: const AlertStyle(
        constraints: BoxConstraints.expand(height: 700, width: 600),
      ),
      content: Column(
        children: <Widget>[
          const TextWithHelp(
            padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
            text:
                "Scroll to choose a branding for your portal or choose 'custom' if you have developed your own theme:",
            helpPage: 'Styling-the-web-app',
          ),
          BrandingSelector(
            initialValue: initialValue,
            onChange: (String newTheme) => theme = newTheme,
          ),
          const SizedBox(height: 0),
        ],
      ),
      buttons: <DialogButton>[
        DialogButton(
          width: 450,
          onPressed: () {
            widget.onChange(theme);
            setState(() {
              initialValue = theme;
            });
            Navigator.pop(context);
          },
          child: const Text(
            'SELECT',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    ).show();
  }
}

class BrandingSelector extends StatefulWidget {
  const BrandingSelector({
    super.key,
    required this.initialValue,
    required this.onChange,
  });

  final String initialValue;
  final Function(String) onChange;

  @override
  State<BrandingSelector> createState() => _BrandingSelectorState();
}

class _BrandingSelectorState extends State<BrandingSelector> {
  static final List<Branding> _brandings = <Branding>[
    Branding(name: 'clean', desc: 'Clean Bootstrap compatible theme'),
    Branding(name: 'cosmo', desc: ''),
    Branding(name: 'darkly', desc: 'Flatly night mode theme'),
    Branding(name: 'flatly', desc: 'Flat and modern theme'),
    Branding(name: 'material', desc: 'Material-Bootstrap experimental theme'),
    Branding(name: 'paper', desc: 'Material inspired theme'),
    Branding(name: 'sandstone', desc: ''),
    Branding(name: 'simplex', desc: 'Minimalist theme that works great'),
    Branding(name: 'slate', desc: ''),
    Branding(name: 'superhero', desc: ''),
    Branding(name: 'yeti', desc: ''),
    Branding(name: 'custom', desc: "None of them. We'll use a self made theme"),
  ];

  final List<MultiSelectItem<Branding>> _items = _brandings
      .map((Branding theme) => MultiSelectItem<Branding>(theme, theme.name))
      .toList();

  List<Branding> _selected = <Branding>[];

  final GlobalKey<FormFieldState<dynamic>> _multiSelectKey =
      GlobalKey<FormFieldState<dynamic>>();

  @override
  void initState() {
    final Branding currentBranding = _brandings.firstWhere(
      (Branding b) => b.name == widget.initialValue,
    );
    _selected = <Branding>[currentBranding];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO(vjrj): Add selection to the start
    _brandings.removeWhere((Branding b) => b == _selected[0]);
    _brandings.insert(0, _selected[0]);
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          MultiSelectChipField<Branding>(
            items: _items,
            scrollBar: HorizontalScrollBar(isAlwaysShown: true),
            showHeader: false,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withValues(alpha: .1),
                width: 10,
              ),
              borderRadius: BorderRadius.circular(5),
              boxShadow: <BoxShadow>[
                BoxShadow(color: Colors.grey.withValues(alpha: .4)),
              ],
            ),
            title: const Text('Select your branding'),
            initialValue: _selected,
            key: _multiSelectKey,
            height: 330,
            headerColor: Colors.white,
            itemBuilder:
                (
                  MultiSelectItem<Branding?> item,
                  FormFieldState<List<Branding?>> state,
                ) {
                  // return your custom widget here
                  final Branding value = item.value ?? _brandings[0];
                  return /* Tooltip(
                message: item.value.desc,
                child: */ Padding(
                    // Scroll padding
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: InkWell(
                      child: Container(
                        height: 80,
                        width: 200,
                        color: _selected.contains(value)
                            ? LAColorTheme.laPalette
                            : Colors.black54,
                        margin: const EdgeInsets.fromLTRB(5, 0, 5, 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            const SizedBox(height: 10),
                            if (value.name != 'custom')
                              Image.asset(
                                'assets/images/themes/${value.name}.png',
                                width: 210,
                              )
                            else
                              Container(),
                            const SizedBox(height: 5),
                            Column(
                              // mainAxisSize: MainAxisSize.max,
                              /*  crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween, */
                              children: <Widget>[
                                Text(
                                  value.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selected = <Branding>[value];
                          widget.onChange(value.name);
                        });
                      },
                      // child: Text(item.value.name),
                    ),
                  );
                },
          ),
        ],
      ),
    );
  }
}
