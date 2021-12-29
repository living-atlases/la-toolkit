import 'package:flutter/material.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/cardConstants.dart';

class ServerServicesEditCard extends StatelessWidget {
  final LAServer server;
  final List<String> currentServerServices;
  final List<LAService> availableServicesForServer;
  final bool isHub;
  final List<LAService> allServices;
  final Function(List<String>) onAssigned;

  const ServerServicesEditCard(
      {Key? key,
      required this.server,
      required this.currentServerServices,
      required this.availableServicesForServer,
      required this.isHub,
      required this.allServices,
      required this.onAssigned})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> chips = [];
    for (LAService service in allServices) {
      LAServiceDesc serviceDesc = LAServiceDesc.get(service.nameInt);
      bool isInThisServer = currentServerServices.contains(serviceDesc.nameInt);
      if (!LAServiceDesc.subServices.contains(service.nameInt) &&
          (availableServicesForServer.contains(service) || isInThisServer)) {
        chips.add(_ServiceChip(
            service: serviceDesc,
            isSelected: isInThisServer,
            onSelected: () =>
                onAssigned(currentServerServices..add(serviceDesc.nameInt)),
            onDeleted: () => onAssigned(
                currentServerServices..remove(serviceDesc.nameInt))));
      }
    }
    return IntrinsicWidth(
        child: Card(
            elevation: CardConstants.defaultElevation,
            // color: Colors.black12,
            margin: const EdgeInsets.all(10),
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(server.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 10),
                      // ignore: sized_box_for_whitespace
                      Container(
                          width: 300,
                          child: Wrap(
                            children: chips,
                            spacing: 3.0, // spacing between adjacent chips
                            runSpacing: 5.0,
                          ))
                      /*  ServicesChipPanel(
                        services: services.map((s) => s.nameInt).toList(),
                        initialValue: [],
                        onChange: (list) => {},
                        isHub: isHub,
                      ) */
                    ],
                  ),
                ]))));
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
      tooltip: service.alias != null ? 'aka ' + service.alias! : '',
      // Cannot use with onSelected
      // onPressed: () => isSelected ? onSelected() : onDeleted(),
      // deleteButtonTooltipMessage: "Don't use this service in this server",
      // onDeleted: isSelected ? () => onDeleted() : null,
    );
  }
}
