import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../la_theme.dart';
import '../models/deployment_type.dart';
import '../models/la_cluster.dart';
import '../models/la_server.dart';
import '../models/la_service.dart';
import '../models/la_service_constants.dart';
import '../models/la_service_desc.dart';
import '../utils/card_constants.dart';
import '../utils/utils.dart';
import 'rename_server_icon.dart';

class ServerServicesEditCard extends StatefulWidget {
  const ServerServicesEditCard({
    super.key,
    this.server,
    this.cluster,
    required this.type,
    required this.currentServerServices,
    required this.availableServicesForServer,
    required this.isHub,
    required this.allServices,
    required this.onAssigned,
    required this.onUnassigned,
    required this.onDeleted,
    required this.onDeletedCluster,
    required this.onRename,
    required this.onEditing,
    required this.onToggleExpand,
  });

  final LAServer? server;
  final LACluster? cluster;
  final List<String> currentServerServices;
  final List<LAService> availableServicesForServer;
  final bool isHub;
  final List<LAService> allServices;
  final Function(List<String>) onAssigned;
  final Function(String) onUnassigned;
  final Function(LAServer) onDeleted;
  final Function(LACluster) onDeletedCluster;
  final Function(String) onRename;
  final Function() onEditing;
  final VoidCallback onToggleExpand;
  final DeploymentType type;

  @override
  State<ServerServicesEditCard> createState() => _ServerServicesEditCardState();
}

class _ServerServicesEditCardState extends State<ServerServicesEditCard> {
  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = <Widget>[];
    for (final LAService service in widget.allServices) {
      final LAServiceDesc serviceDesc = LAServiceDesc.get(service.nameInt);
      final bool isInThisServer = widget.currentServerServices.contains(
        serviceDesc.nameInt,
      );
      if (!LAServiceDesc.subServices.contains(service.nameInt) &&
          (widget.availableServicesForServer.contains(service) ||
              isInThisServer)) {
        chips.add(
          _ServiceChip(
            service: serviceDesc,
            isSelected: isInThisServer,
            onSelected: () {
              setState(() {
                widget.onAssigned(
                  widget.currentServerServices..add(serviceDesc.nameInt),
                );
              });
            },
            onDeleted: () {
              setState(() {
                widget.onUnassigned(serviceDesc.nameInt);
                widget.onAssigned(
                  widget.currentServerServices..remove(serviceDesc.nameInt),
                );
              });
            },
          ),
        );
      }
    }
    final bool isAServer = widget.server != null;
    final bool isDockerSwarm =
        !isAServer && widget.type == DeploymentType.dockerSwarm;
    final ShapeBorder cardShape = widget.type == DeploymentType.vm
        ? CardConstants.defaultShape
        : isDockerSwarm
        ? CardConstants.deprecatedClusterShape
        : CardConstants.defaultClusterShape;

    return IntrinsicWidth(
      child: Card(
        elevation: CardConstants.defaultElevation,
        shape: cardShape,
        // color: Colors.black12,
        margin: const EdgeInsets.all(10),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      children: [
                        Icon(
                          isAServer ? Icons.dns : MdiIcons.docker,
                          color: LAColorTheme.inactive,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: isDockerSwarm
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      widget.cluster?.name ??
                                          'Docker swarm cluster',
                                      style: const TextStyle(
                                        color: LAColorTheme.inactive,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const Text(
                                      'deprecated',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  isAServer
                                      ? widget.server!.name
                                      : widget.cluster?.name ??
                                            'Docker compose',
                                  style: const TextStyle(
                                    color: LAColorTheme.inactive,
                                    fontSize: 20,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.expand_less),
                          onPressed: widget.onToggleExpand,
                          tooltip: 'Collapse',
                        ),
                        if (isAServer)
                          RenameServerIcon(widget.server!, widget.onEditing, (
                            String newName,
                          ) {
                            widget.onRename(newName);
                          }),
                        if (isAServer)
                          Tooltip(
                            message: 'Delete this server',
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                final LAServer? s = widget.server;
                                if (s == null) return;
                                widget.onEditing();
                                UiUtils.showAlertDialog(
                                  context,
                                  () => widget.onDeleted(s),
                                  () {},
                                  title: "Deleting server '${s.name}'",
                                );
                              },
                            ),
                          ),
                        if (!isAServer)
                          Tooltip(
                            message: 'Delete this',
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                final LACluster? c = widget.cluster;
                                if (c == null) return;
                                widget.onEditing();
                                UiUtils.showAlertDialog(
                                  context,
                                  () => widget.onDeletedCluster(c),
                                  () {},
                                  title: "Deleting cluster '${c.name}'",
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // ignore: sized_box_for_whitespace
                  Container(
                    width: 300,
                    child: Wrap(
                      spacing: 3.0, // spacing between adjacent chips
                      runSpacing: 5.0,
                      children: chips,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({
    required this.service,
    required this.isSelected,
    required this.onSelected,
    required this.onDeleted,
  });

  final bool isSelected;
  final LAServiceDesc service;
  final VoidCallback onSelected;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      padding: const EdgeInsets.all(2.0),
      // avatar: isSelected ? null : Icon(icon),
      avatar: Icon(service.icon),
      showCheckmark: false,
      label: Text(
        service.nameInt == dockerSwarm
            ? '${service.name} (deprecated)'
            : service.name,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          decoration: service.nameInt == dockerSwarm
              ? TextDecoration.lineThrough
              : null,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      selected: isSelected,
      selectedColor: LAColorTheme.laPalette,
      onSelected: (bool selected) => selected ? onSelected() : onDeleted(),
      // Very slow:
      //   tooltip: service.alias != null ? 'aka ${service.alias!}' : '',
      // Cannot use with onSelected
      // onPressed: () => isSelected ? onSelected() : onDeleted(),
      // deleteButtonTooltipMessage: "Don't use this service in this server",
      // onDeleted: isSelected ? () => onDeleted() : null,
    );
  }
}
