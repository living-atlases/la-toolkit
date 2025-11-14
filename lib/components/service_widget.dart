import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:url_launcher/url_launcher.dart';

import '../la_theme.dart';
import '../models/app_state.dart';
import '../models/la_project.dart';
import '../models/la_service.dart';
import '../models/la_service_constants.dart';
import '../models/la_service_desc.dart';
import '../redux/actions.dart';
import '../utils/regexp.dart';
import '../utils/string_utils.dart';
import 'generic_text_form_field.dart';
import 'help_icon.dart';

class ServiceWidget extends StatelessWidget {
  const ServiceWidget(
      {super.key,
      required this.serviceName,
      required this.collectoryFocusNode});

  final String serviceName;
  final FocusNode? collectoryFocusNode;

  @override
  Widget build(BuildContext context) {
    final TextStyle domainTextStyle =
        TextStyle(fontSize: 16, color: Theme.of(context).hintColor);
    return StoreConnector<AppState, _LAServiceViewModel>(
        // It seems that the comparison of projects are not working properly
        // distinct: true,
        converter: (Store<AppState> store) {
      return _LAServiceViewModel(
          currentProject: store.state.currentProject,
          onEditService: (LAService service) =>
              store.dispatch(EditService(service)),
          onSaveProject: (LAProject project) =>
              store.dispatch(SaveCurrentProject(project)));
    }, builder: (BuildContext context, _LAServiceViewModel vm) {
      final LAProject currentProject = vm.currentProject;
      final LAService service = vm.currentProject.getService(serviceName);
      final LAServiceDesc serviceDesc = LAServiceDesc.get(serviceName);
      final bool isHub = currentProject.isHub;
      final bool noDependsOrInUse = serviceDesc.depends == null ||
          (isHub ? vm.currentProject.parent! : vm.currentProject)
              .getServiceE(serviceDesc.depends!)
              .use;
      final bool withoutUrl = serviceDesc.withoutUrl;
      final bool visible = noDependsOrInUse &&
          (!withoutUrl || servicesWithoutUrlButShow.contains(serviceName));
      /* (serviceName == biocacheBackend ||
                  serviceName == eventsElasticSearch ||
                  serviceName == pipelines ||
                  serviceName == solrcloud ||
                  serviceName == dockerSwarm ||
                  serviceName == zookeeper) */
      final bool optional = serviceDesc.optional;
      final bool canUseSubdomain = !serviceDesc.forceSubdomain && !withoutUrl;

      final String domain = vm.currentProject.domain;
      final bool usesSubdomain = !withoutUrl && service.usesSubdomain;
      final ValueNotifier<bool> domainSwitchController =
          ValueNotifier<bool>(false);
      domainSwitchController.value = !service.usesSubdomain;
      domainSwitchController.addListener(() {
        if (canUseSubdomain) {
          service.usesSubdomain = !domainSwitchController.value;
          vm.onEditService(service);
        }
      });
      return visible
          ? Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 10.0, 20.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // const DefDivider(),
                        ListTile(
                            // leading: Icon(serviceDesc.icon),
                            contentPadding: EdgeInsets.zero,
                            title: Row(children: <Widget>[
                              Icon(
                                serviceDesc.icon,
                                color: Colors.grey,
                                // color: LAColorTheme.inactive
                              ),
                              const SizedBox(
                                width:
                                    10, // here put the desired space between the icon and the text
                              ),
                              if (optional)
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(children: <Widget>[
                                        Text(
                                            'Use the ${serviceDesc.name} service?'),
                                        Transform.scale(
                                            scale: 0.8,
                                            child: Switch(
                                              value: service.use,
                                              // activeColor: Color(0xFF6200EE),
                                              onChanged: (bool newValue) {
                                                currentProject.serviceInUse(
                                                    serviceName, newValue);
                                                vm.onSaveProject(
                                                    currentProject);
                                              },
                                            ))
                                      ]),
                                      const SizedBox(
                                        height:
                                            0, // here put the desired space between the icon and the text
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                          child: Wrap(children: <Widget>[
                                            Text(
                                                StringUtils.capitalize(
                                                    serviceDesc.desc),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600]))
                                          ])),
                                      const SizedBox(height: 10)
                                    ]),
                              if (!optional)
                                Text(
                                    '${serviceDesc.name}: ${StringUtils.capitalize(serviceDesc.desc)}')
                            ]),
                            trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  if (serviceDesc.repository != null)
                                    Tooltip(
                                        message:
                                            'Code repository of this service',
                                        child: IconButton(
                                            onPressed: () async {
                                              await launchUrl(Uri.parse(
                                                  serviceDesc.repository!));
                                            },
                                            icon: const Icon(Icons.code))),
                                  if (serviceDesc.sample != null &&
                                      serviceDesc.repository != null)
                                    const SizedBox(width: 8),
                                  if (serviceDesc.sample != null)
                                    serviceDesc.name == branding
                                        ? HelpIcon(
                                            wikipage: 'Styling-the-web-app')
                                        : HelpIcon.url(
                                            url: serviceDesc.sample!,
                                            tooltip:
                                                'See a similar service in production')
                                ])),
                        if (!withoutUrl && (!optional || service.use))
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Tooltip(
                                    message: canUseSubdomain
                                        ? 'Use a subdomain for this service?'
                                        : 'This service requires a subdomain',
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 3, 20, 0),
                                      child: AdvancedSwitch(
                                        controller: domainSwitchController,
                                        height: 16.0,
                                        width: 60.0,
                                        activeColor: LAColorTheme.inactive,
                                        inactiveColor: LAColorTheme.laPalette,
                                        // activeColor: Color(0xFF009688),
                                        inactiveChild: const Text('SUBD'),
                                        activeChild: const Text('PATH'),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(4)),
                                      ),
                                    )),
                                /* Switch(
                                value: service.usesSubdomain,
                                activeColor: Color(0xFF009688),
                                onChanged: (bool newValue) {
                                  service.usesSubdomain = newValue;
                                  vm.onEditService(service);
                                },
                              ) */
                                if (!withoutUrl)
                                  Container(
                                      padding: EdgeInsets.fromLTRB(
                                          0, 0, usesSubdomain ? 0 : 0, 0),
                                      child: Text(
                                          "http${vm.currentProject.useSSL ? 's' : ''}://",
                                          style: domainTextStyle)),
                                if (!withoutUrl && usesSubdomain)
                                  _createSubUrlField(service, serviceDesc, vm,
                                      'Invalid subdomain.'),
                                if (!withoutUrl && usesSubdomain)
                                  Text('.$domain/', style: domainTextStyle),
                                if (!withoutUrl &&
                                    usesSubdomain &&
                                    !serviceDesc.forceSubdomain)
                                  _createPathField(service, serviceDesc, vm,
                                      'Invalid path.'),
                                if (!withoutUrl && !usesSubdomain)
                                  Text('$domain/', style: domainTextStyle),
                                if (!withoutUrl && !usesSubdomain)
                                  _createSubUrlField(service, serviceDesc, vm,
                                      'Invalid path.'),
                                if (!withoutUrl && !usesSubdomain)
                                  Text('/', style: domainTextStyle),
                                /* SearchChoices.single(
                              items: searchServerList,
                              // vm.state.currentProject.servers.toList(),
                              // value: service.servers[0] ??
                              //  searchServerList[0].value,
                              hint: "deploy it in",
                              searchHint:
                                  "Select one server to deploy this service:",
                              onChanged: (value) {
                                debugPrint(value);
                                // service.servers[0] = value;
                              },
                              /* dialogBox: false,
                              menuConstraints:
                                  BoxConstraints.tight(Size.fromHeight(350)), */
                              isExpanded: false,
                            ) */
                              ]),
                        const SizedBox(height: 10)
                      ])))
          : Container();
    });
  }

  Widget _wrapField({required Widget child, required bool isSub}) {
    return IntrinsicWidth(
        child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: isSub ? 80.0 : 100,
                      ),
                      child: child)
                ])));
  }

  Widget _createSubUrlField(LAService service, LAServiceDesc serviceDesc,
      _LAServiceViewModel vm, String error) {
    return _wrapField(
        child: GenericTextFormField(
            initialValue: service.suburl,
            focusNode:
                service.nameInt == collectory ? collectoryFocusNode : null,
            isCollapsed: true,
            contentPadding: const EdgeInsets.only(bottom: 4),
            regexp: LARegExp.subdomain,
            error: error,
            onChanged: (String value) {
              service.suburl = value;
              vm.onEditService(service);
            }),
        isSub: true);
  }

  Widget _createPathField(LAService service, LAServiceDesc serviceDesc,
      _LAServiceViewModel vm, String error) {
    return _wrapField(
        child: GenericTextFormField(
            initialValue: service.iniPath,
            focusNode: service.nameInt == collectory && !service.usesSubdomain
                ? collectoryFocusNode
                : null,
            isCollapsed: true,
            contentPadding: const EdgeInsets.only(bottom: 4),
            regexp: LARegExp.subdomain,
            allowEmpty: true,
            error: error,
            onChanged: (String value) {
              service.iniPath = value;
              vm.onEditService(service);
            }),
        isSub: false);
  }
}

class _LAServiceViewModel {
  _LAServiceViewModel(
      {required this.currentProject,
      required this.onEditService,
      required this.onSaveProject});

  final LAProject currentProject;
  final void Function(LAService service) onEditService;
  final void Function(LAProject project) onSaveProject;
}
