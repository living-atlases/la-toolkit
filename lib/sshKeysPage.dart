import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'components/appSnackBar.dart';
import 'components/genericTextFormField.dart';
import 'components/laAppBar.dart';
import 'components/scrollPanel.dart';
import 'components/textWithHelp.dart';
import 'laTheme.dart';
import 'notInDemo.dart';

class SshKeyPage extends StatelessWidget {
  SshKeyPage({Key? key}) : super(key: key);

  static const routeName = "ssh-keys";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _SshKeyViewModel>(
      // Fails the switch distinct: true,
      converter: (store) {
        return _SshKeyViewModel(
            state: store.state,
            onAddKey: (name) => store.dispatch(OnAddSshKey(name)),
            onImportKey: (name, publicKey, privateKey) =>
                store.dispatch(OnImportSshKey(name, publicKey, privateKey)),
            onScanKeys: () => store
                .dispatch(OnSshKeysScan(() => context.loaderOverlay.hide())));
      },
      builder: (BuildContext context, _SshKeyViewModel vm) {
        return Scaffold(
            key: _scaffoldKey,
            appBar: LAAppBar(
                context: context,
                titleIcon: MdiIcons.key,
                title: "SSH KEYS",
                showLaIcon: false,
                showBack: true,
                actions: [
                  TextButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      onPressed: () => _generateKeyDialog(context, vm),
                      label: const Text("GENERATE A NEW KEY")),
                  TextButton.icon(
                      icon: const Icon(Icons.upload_rounded),
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      onPressed: () => _importKeysDialog(context, vm),
                      label: const Text("UPLOAD KEYS")),
                  TextButton.icon(
                      icon: const Icon(MdiIcons.refresh),
                      style: TextButton.styleFrom(foregroundColor: Colors.white),
                      onPressed: () {
                        context.loaderOverlay.show();
                        vm.onScanKeys();
                      },
                      label: const Text("SCAN YOUR KEYS")),
                ]),
            body: AppSnackBar(ScrollPanel(
                withPadding: true,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1, // 10%
                      child: Container(),
                    ),
                    Expanded(
                        flex: 8, // 80%,
                        child: AppUtils.isDemo()
                            ? const NotInTheDemoPanel()
                            : SshKeysTable(vm: vm)),
                    Expanded(
                      flex: 1, // 10%
                      child: Container(),
                    )
                  ],
                ))));
      },
    );
  }

  void _generateKeyDialog(BuildContext context, _SshKeyViewModel vm) {
    String? name;
    Alert(
        context: context,
        closeIcon: const Icon(Icons.close),
        image: const Icon(MdiIcons.key, size: 60, color: LAColorTheme.inactive),
        title: "SSH Key Generation",
        style: const AlertStyle(
            constraints: BoxConstraints.expand(height: 600, width: 600)),
        content: Column(
          children: <Widget>[
            const TextWithHelp(
                text: "Type a name for you new ssh key:",
                helpPage: "SSH-for-Beginners#ssh-key-generation"),
            GenericTextFormField(
                initialValue: "",
                regexp: LARegExp.hostnameRegexp,
                error: "This is not a valid file name",
                keyboardType: TextInputType.multiline,
                // filled: true,
                minLines:
                    1, // any number you need (It works as the rows for the textarea)
                maxLines: null,
                hint: "Something like: gbif-wakanda-key-2020",
                onChanged: (value) {
                  name = value;
                }),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
        buttons: [
          DialogButton(
            width: 500,
            onPressed: () {
              if (name != null && LARegExp.hostnameRegexp.hasMatch(name!)) {
                vm.onAddKey(name!);
                Navigator.pop(context);
              }
            },
            child: const Text(
              "GENERATE",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  void _importKeysDialog(BuildContext context, _SshKeyViewModel vm) {
    String? name;
    String? publicKey;
    String? privateKey;
    Alert(
        context: context,
        closeIcon: const Icon(Icons.close),
        image: const Icon(MdiIcons.key, size: 60, color: LAColorTheme.inactive),
        title: "SSH Key Import",
        style: const AlertStyle(
            constraints: BoxConstraints.expand(height: 600, width: 600)),
        content: Column(
          children: <Widget>[
            // TODO: Add a subsection for this help
            const TextWithHelp(
                text: "Type a name for you ssh key:",
                helpPage: "SSH-for-Beginners"),
            GenericTextFormField(
                initialValue: "",
                regexp: LARegExp.hostnameRegexp,
                error: "This is not a valid file name",
                keyboardType: TextInputType.multiline,
                // filled: true,
                minLines:
                    1, // any number you need (It works as the rows for the textarea)
                maxLines: null,
                hint: "Something like: gbif-wakanda-key-2020",
                onChanged: (value) {
                  name = value;
                }),
            const SizedBox(
              height: 20,
            ),
            GenericTextFormField(
                initialValue: "",
                label: "Public ssh key",
                regexp: LARegExp.sshPubKey,
                error: "This is not a valid ssh public key",
                keyboardType: TextInputType.multiline,
                // filled: true,
                minLines:
                    3, // any number you need (It works as the rows for the textarea)
                maxLines: null,
                hint:
                    "Something like: ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9(...)",
                onChanged: (value) {
                  publicKey = value;
                }),
            const SizedBox(
              height: 20,
            ),
            GenericTextFormField(
                initialValue: "",
                label: "Private ssh key",
                regexp: LARegExp.anything,
                error: "This is not a valid ssh private key",
                keyboardType: TextInputType.multiline,
                // filled: true,
                minLines:
                    3, // any number you need (It works as the rows for the textarea)
                maxLines: null,
                onChanged: (value) {
                  privateKey = value;
                }),
          ],
        ),
        buttons: [
          DialogButton(
            width: 500,
            onPressed: () {
              if (name != null && publicKey != null && privateKey != null) {
                if (LARegExp.hostnameRegexp.hasMatch(name!) &&
                    LARegExp.sshPubKey.hasMatch(publicKey!) &&
                    LARegExp.anything.hasMatch(privateKey!)) {
                  vm.onImportKey(name!, publicKey!, privateKey!);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text(
              "IMPORT",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}

class SshKeysTable extends StatelessWidget {
  final _SshKeyViewModel vm;
  const SshKeysTable({Key? key, required this.vm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DataTable(
        dataRowHeight: 65,
        // sortAscending: sort,
        // sortColumnIndex: 0,
        showCheckboxColumn: false,
        columns: const [
          DataColumn(
            label: Text("NAME"),
            numeric: false,
            tooltip: "This is the key name",
          ),
          DataColumn(
            label: Text("DESCRIPTION"),
            numeric: false,
            tooltip: "",
          ),
          DataColumn(
            label: Text("PROTECTED?"),
            numeric: false,
            tooltip:
                "If the key is passphrase protected (for now we only support passwordless keys)",
          ),
          DataColumn(
            label: Text("PUBLIC KEY"),
            numeric: false,
            tooltip: "SSH Public key, press the icon to copy",
          ),
        ],
        rows: vm.state.sshKeys
            .map((sshKey) => DataRow(cells: [
                  DataCell(Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(sshKey.name),
                  )),
                  DataCell(Text(sshKey.desc)),
                  DataCell(Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: sshKey.encrypted
                          ? const Tooltip(
                              message:
                                  "SSH Key password encrypted, no supported right now",
                              child: Icon(MdiIcons.lockOutline))
                          : const Tooltip(
                              message: "SSH Key without password",
                              child: Icon(MdiIcons.lockOpenVariantOutline,
                                  color: Colors.grey)))),
                  DataCell(Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Tooltip(
                          message: "Press to copy the SSH public key",
                          child: IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () => FlutterClipboard.copy(
                                    sshKey.publicKey)
                                .then((value) => ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        content: Text(
                                            "SSH Key copied to clipboard")))),
                          )))),
                ]))
            .toList());
  }
}

class _SshKeyViewModel {
  final AppState state;
  final void Function(String) onAddKey;
  final void Function() onScanKeys;
  final void Function(String, String, String) onImportKey;

  _SshKeyViewModel(
      {required this.state,
      required this.onAddKey,
      required this.onScanKeys,
      required this.onImportKey});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SshKeyViewModel &&
          runtimeType == other.runtimeType &&
          state.sshKeys == other.state.sshKeys;

  @override
  int get hashCode => state.sshKeys.hashCode;
}
