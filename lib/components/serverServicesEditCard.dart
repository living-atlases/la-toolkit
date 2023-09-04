import 'package:flutter/material.dart';
import 'package:la_toolkit/components/renameServerIcon.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/cardConstants.dart';
import 'package:la_toolkit/utils/utils.dart';

class ServerServicesEditCard extends StatefulWidget {
  final LAServer server;
  final List<String> currentServerServices;
  final List<LAService> availableServicesForServer;
  final bool isHub;
  final List<LAService> allServices;
  final Function(List<String>) onAssigned;
  final Function(String) onUnassigned;
  final Function(LAServer) onDeleted;
  final Function(String) onRename;
  final Function() onEditing;

  const ServerServicesEditCard(
      {Key? key,
      required this.server,
      required this.currentServerServices,
      required this.availableServicesForServer,
      required this.isHub,
      required this.allServices,
      required this.onAssigned,
      required this.onUnassigned,
      required this.onDeleted,
      required this.onRename,
      required this.onEditing})
      : super(key: key);

  @override
  State<ServerServicesEditCard> createState() => _ServerServicesEditCardState();
}

class _ServerServicesEditCardState extends State<ServerServicesEditCard> {
  @override
  Widget build(BuildContext context) {
    List<Widget> chips = [];
    for (LAService service in widget.allServices) {
      LAServiceDesc serviceDesc = LAServiceDesc.get(service.nameInt);
      bool isInThisServer =
          widget.currentServerServices.contains(serviceDesc.nameInt);
      if (!LAServiceDesc.subServices.contains(service.nameInt) &&
          (widget.availableServicesForServer.contains(service) ||
              isInThisServer)) {
        chips.add(_ServiceChip(
            service: serviceDesc,
            isSelected: isInThisServer,
            onSelected: () => widget.onAssigned(
                widget.currentServerServices..add(serviceDesc.nameInt)),
            onDeleted: () {
              widget.onUnassigned(serviceDesc.nameInt);
              widget.onAssigned(
                  widget.currentServerServices..remove(serviceDesc.nameInt));
            }));
      }
    }
    return IntrinsicWidth(
        child: Card(
            elevation: CardConstants.defaultElevation,
            // color: Colors.black12,
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(widget.server.name,
                          style: const TextStyle(
                              color: LAColorTheme.inactive, fontSize: 20)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        RenameServerIcon(widget.server, widget.onEditing,
                            (String newName) {
                          widget.onRename(newName);
                        }),
                        Tooltip(
                            message: "Delete this server",
                            child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  widget.onEditing();
                                  UiUtils.showAlertDialog(
                                    context,
                                    () => widget.onDeleted(widget.server),
                                    () => {},
                                    title:
                                        "Deleting server '${widget.server.name}'",
                                  );
                                })),
                      ])),
                  const SizedBox(height: 10),
                  // ignore: sized_box_for_whitespace
                  Container(
                      width: 300,
                      child: Wrap(
                        spacing: 3.0, // spacing between adjacent chips
                        runSpacing: 5.0,
                        children: chips,
                      ))
                ],
              ),
            )));
  }
}

class _ServiceChip extends StatelessWidget {
  final bool isSelected;
  final LAServiceDesc service;
  final VoidCallback onSelected;
  final VoidCallback onDeleted;

  const _ServiceChip(
      {required this.service,
      required this.isSelected,
      required this.onSelected,
      required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return InputChip(
      padding: const EdgeInsets.all(2.0),
      // avatar: isSelected ? null : Icon(icon),
      avatar: Icon(service.icon),
      showCheckmark: false,
      label: Text(
        service.name,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      selected: isSelected,
      selectedColor: LAColorTheme.laPalette,
      onSelected: (bool selected) => selected ? onSelected() : onDeleted(),
      tooltip: service.alias != null ? 'aka ${service.alias!}' : '',
      // Cannot use with onSelected
      // onPressed: () => isSelected ? onSelected() : onDeleted(),
      // deleteButtonTooltipMessage: "Don't use this service in this server",
      // onDeleted: isSelected ? () => onDeleted() : null,
    );
  }
}
