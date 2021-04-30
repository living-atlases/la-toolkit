import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class BrandingSelector extends StatefulWidget {
  BrandingSelector({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _BrandingSelectorState createState() => _BrandingSelectorState();
}

class Branding {
  final String name;
  final String desc;

  Branding({
    required this.name,
    required this.desc,
  });
}

class _BrandingSelectorState extends State<BrandingSelector> {
  static List<Branding> _brandings = [
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
  //List<Branding> _selectedBrandings = [];
  List<Branding> _selectedBrandings2 = [];
  List<Branding> _selectedBrandings3 = [];
  //List<Branding> _selectedBrandings4 = [];
  List<Branding> _selectedBrandings5 = [];
  final _multiSelectKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    _selectedBrandings5 = _brandings;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          SizedBox(height: 40),
          //################################################################################################
          // Rounded blue MultiSelectDialogField
          //################################################################################################
          MultiSelectDialogField(
            items: _items,
            title: Text("Brandings 1"),
            selectedColor: Colors.blue,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.all(Radius.circular(40)),
              border: Border.all(
                color: Colors.blue,
                width: 2,
              ),
            ),
            buttonIcon: Icon(
              Icons.pets,
              color: Colors.blue,
            ),
            buttonText: Text(
              "Favorite Brandings",
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 16,
              ),
            ),
            onConfirm: (results) {
              //_selectedBrandings = results;
            },
          ),
          SizedBox(height: 50),
          //################################################################################################
          // This MultiSelectBottomSheetField has no decoration, but is instead wrapped in a Container that has
          // decoration applied. This allows the ChipDisplay to render inside the same Container.
          //################################################################################################
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(.4),
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            child: Column(
              children: <Widget>[
                MultiSelectBottomSheetField<Branding>(
                  initialChildSize: 0.4,
                  listType: MultiSelectListType.CHIP,
                  searchable: true,
                  buttonText: Text("Brandings 2"),
                  title: Text("Brandings"),
                  items: _items,
                  onConfirm: (values) {
                    _selectedBrandings2 = values;
                  },
                  chipDisplay: MultiSelectChipDisplay(
                    onTap: (value) {
                      setState(() {
                        _selectedBrandings2.remove(value);
                      });
                    },
                  ),
                ),
                _selectedBrandings2.isEmpty
                    ? Container(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "None selected",
                          style: TextStyle(color: Colors.black54),
                        ))
                    : Container(),
              ],
            ),
          ),
          SizedBox(height: 40),
          //################################################################################################
          // MultiSelectBottomSheetField with validators
          //################################################################################################
          MultiSelectBottomSheetField<Branding>(
            key: _multiSelectKey,
            initialChildSize: 0.7,
            maxChildSize: 0.95,
            title: Text("Brandings 3"),
            buttonText: Text("Favorite Brandings"),
            items: _items,
            searchable: true,
            validator: (values) {
              if (values == null || values.isEmpty) {
                return "Required";
              }
              List<String> names = values.map((e) => e.name).toList();
              if (names.contains("Frog")) {
                return "Frogs are weird!";
              }
              return null;
            },
            onConfirm: (values) {
              setState(() {
                _selectedBrandings3 = values;
              });
              //_multiSelectKey.currentState.validate();
            },
            chipDisplay: MultiSelectChipDisplay(
              onTap: (item) {
                setState(() {
                  _selectedBrandings3.remove(item);
                });
                //  _multiSelectKey.currentState.validate();
              },
            ),
          ),
          SizedBox(height: 40),
          //################################################################################################
          // MultiSelectChipField
          //################################################################################################
          MultiSelectChipField<Branding>(
            items: _items,
            initialValue: [_brandings[4], _brandings[7], _brandings[9]],
            title: Text("Brandings 4"),
            headerColor: Colors.blue.withOpacity(0.5),
            decoration: BoxDecoration(
                //  border: Border.all(color: Colors.blue[700], width: 1.8),
                ),
            selectedChipColor: Colors.blue.withOpacity(0.5),
            selectedTextStyle: TextStyle(color: Colors.blue[800]),
            onTap: (values) {
              //_selectedBrandings4 = values;
            },
          ),
          SizedBox(height: 40),
          //################################################################################################
          // MultiSelectDialogField with initial values
          //################################################################################################
          MultiSelectDialogField<Branding>(
            onConfirm: (val) {
              _selectedBrandings5 = val;
            },
            items: _items,
            initialValue:
                _selectedBrandings5, // setting the value of this in initState() to pre-select values.
          ),
        ],
      ),
    );
  }
}
