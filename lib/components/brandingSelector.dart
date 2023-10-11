import 'package:flutter/material.dart';
import 'package:la_toolkit/components/helpIcon.dart';
import 'package:la_toolkit/components/textWithHelp.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Branding {
  final String name;
  final String desc;

  Branding({
    required this.name,
    required this.desc,
  });
}

class BrandingTile extends StatefulWidget {
  final String initialValue;
  final Function(String) onChange;
  final String portalName;

  const BrandingTile(
      {Key? key,
      required this.initialValue,
      required this.portalName,
      required this.onChange})
      : super(key: key);

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
      ///contentPadding: padding,
      title: Text("${widget.portalName} branding"),
      subtitle: Text(initialValue),
      onTap: () => _showDialog(context),
      leading: const Icon(Icons.format_paint),
      trailing: HelpIcon(wikipage: "Styling-the-web-app"),
    );
  }

  void _showDialog(
    BuildContext context,
    /* _SshKeyViewModel vm */
  ) {
    String theme = initialValue;
    Alert(
        context: context,
        closeIcon: const Icon(Icons.close),
        image: const Icon(
            Icons.format_paint /* , size: 60, color: LAColorTheme.laPalette*/),
        title: "Select your branding theme",
        style: const AlertStyle(
            constraints: BoxConstraints.expand(height: 600, width: 600)),
        content: Column(
          children: <Widget>[
            const TextWithHelp(
                padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
                text:
                    "Scroll to choose a branding for your portal or choose 'custom' if you have developed your own theme:",
                helpPage: "Styling-the-web-app"),
            BrandingSelector(
              initialValue: initialValue,
              onChange: (String newTheme) => theme = newTheme,
            ),
            const SizedBox(
              height: 0,
            ),
          ],
        ),
        buttons: [
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
              "SELECT",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}

class BrandingSelector extends StatefulWidget {
  final String initialValue;
  final Function(String) onChange;

  const BrandingSelector(
      {Key? key, required this.initialValue, required this.onChange})
      : super(key: key);

  @override
  State<BrandingSelector> createState() => _BrandingSelectorState();
}

class _BrandingSelectorState extends State<BrandingSelector> {
  static final List<Branding> _brandings = [
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
    Branding(
        name: 'custom', desc: 'None of them. We\'ll use a self made theme'),
  ];

  final _items = _brandings
      .map((theme) => MultiSelectItem<Branding>(theme, theme.name))
      .toList();

  List<Branding> _selected = [];

  final _multiSelectKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    Branding currentBranding =
        _brandings.firstWhere((b) => b.name == widget.initialValue);
    _selected = [currentBranding];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO add selection to the start
    _brandings.removeWhere((b) => b == _selected[0]);
    _brandings.insert(0, _selected[0]);
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(0),
      child: Column(
        children: <Widget>[
          MultiSelectChipField<Branding>(
            items: _items,
            scrollBar: HorizontalScrollBar(isAlwaysShown: true),
            scroll: true,
            showHeader: false,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.withOpacity(.1),
                width: 10,
              ),
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(.4),
                ),
              ],
              /* border:
                  Border.all(width: 0, color: Theme.of(context).primaryColor),*/
            ),
            title: const Text("Select your branding"),
            initialValue: _selected,
            key: _multiSelectKey,
            height: 330,
            headerColor: Colors.white,
            itemBuilder: (MultiSelectItem<Branding?> item,
                FormFieldState<List<Branding?>> state) {
              // return your custom widget here
              Branding value = item.value ?? _brandings[0];
              return /* Tooltip(
                message: item.value.desc,
                child: */
                  Padding(
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
                                // mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  const SizedBox(height: 10),
                                  value.name != 'custom'
                                      ? Image.asset(
                                          "assets/images/themes/${value.name}.png",
                                          width: 210)
                                      : Container(),
                                  const SizedBox(height: 5),
                                  Column(
                                      // mainAxisSize: MainAxisSize.max,
                                      /*  crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween, */
                                      children: <Widget>[
                                        Text(value.name,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal)),
                                        const SizedBox(height: 5),
                                      ])
                                ])),
                        onTap: () {
                          setState(() {
                            _selected = [value];
                            widget.onChange(value.name);
                          });
                        },
                        // child: Text(item.value.name),
                      ));
            },
          ),
        ],
      ),
    );
  }
}
