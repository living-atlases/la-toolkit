import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:la_toolkit/components/laProjectTimeline.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/routes.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/formattedTitle.dart';
import 'components/scrollPanel.dart';
import 'laTheme.dart';

class LAProjectsList extends StatelessWidget {
  const LAProjectsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectsPageViewModel>(
        distinct: true,
        converter: (store) {
          return _ProjectsPageViewModel(
            state: store.state,
            loading: store.state.loading,
            onCreateProject: () {
              store.dispatch(CreateProject());
              BeamerCond.of(context, LAProjectEditLocation());
            },
            onDeleteProject: (project) {
              store.dispatch(DelProject(project));
              BeamerCond.of(context, HomeLocation());
              context.loaderOverlay.hide();
              //context.beamToNamed(HomePage.routeName);
            },
            onOpenProjectTools: (project) {
              store.dispatch(OpenProjectTools(project));
              //context.beamToNamed(LAProjectViewPage.routeName);
              BeamerCond.of(context, LAProjectViewLocation());
            },
          );
        },
        builder: (BuildContext context, _ProjectsPageViewModel vm) {
          List<LAProject> pjs =
              vm.state.projects.where((p) => !p.isHub).toList();
          int num = pjs.length;
          return num > 0
              ? ScrollPanel(
                  child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 20),
                      child: Column(children: <Widget>[
                        AnimationLimiter(
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: num,
                                // itemCount: appStateProv.appState.projects.length,
                                itemBuilder: (BuildContext context,
                                        int index) =>
                                    AnimationConfiguration.staggeredList(
                                        position: index,
                                        delay: const Duration(milliseconds: 0),
                                        duration:
                                            const Duration(milliseconds: 1000),
                                        child: SlideAnimation(
                                            verticalOffset: 50.0,
                                            child: ScaleAnimation(
                                                duration: const Duration(
                                                    milliseconds: 750),
                                                child: ProjectCard(
                                                    pjs[index],
                                                    () => vm.onOpenProjectTools(
                                                        pjs[index]),
                                                    () => vm.onDeleteProject(
                                                        pjs[index])))))))
                      ])))
              : vm.loading
                  ? Container()
                  : Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                          ButtonTheme(
                              child: ElevatedButton.icon(
                                  onPressed: () => vm.onCreateProject(),
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.white, minimumSize: const Size(100, 50),
                                      // padding: const EdgeInsets.all(8.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                        // side: BorderSide(color: Colors.red)),
                                      )),
                                  icon: const Icon(Icons.add_circle_outline,
                                      size: 30),
                                  label: const Text("Create a New LA Project",
                                      style: TextStyle(fontSize: 18))))
                        ]));
        });
  }
}

class ProjectCard extends StatelessWidget {
  final LAProject project;
  final void Function() onOpen;
  final void Function() onDelete;
  const ProjectCard(this.project, this.onOpen, this.onDelete, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Stack(
        children: <Widget>[
          MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                  onTap: () => onOpen(),
                  child: Card(
                    child: Container(
                      height: 220.0,
                      margin: const EdgeInsets.fromLTRB(30, 12, 20, 30),
                      child: Column(
                          // crossAxisAlignment: CrossAxisAlignment.stretch,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ListTile(
                                contentPadding: EdgeInsets.zero,
                                // LONG NAME
                                title: FormattedTitle(
                                    title: project.longName,
                                    fontSize: 22,
                                    color: LAColorTheme.inactive),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Tooltip(
                                          message: "Delete this project",
                                          child: IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.grey,
                                              ),
                                              onPressed: () {
                                                if (AppUtils.isDev()) {
                                                  context.loaderOverlay.show();
                                                  onDelete();
                                                } else {
                                                  UiUtils.showAlertDialog(
                                                      context,
                                                      () => onDelete(),
                                                      () => {});
                                                }
                                              })),
                                      const SizedBox(width: 20),
                                      Tooltip(
                                          message: "Configure this project",
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(
                                              Icons.settings,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () => onOpen(),
                                          ))
                                    ])),
                            Text(
                              // SHORT NAME
                              project.shortName,
                              style: const TextStyle(fontSize: 16),
                            ),
                            SelectableLinkify(
                                linkStyle: const TextStyle(
                                    color: LAColorTheme.laPalette),
                                options: const LinkifyOptions(humanize: false),
                                text:
                                    "${project.useSSL ? 'https://' : 'http://'}${project.domain}",
                                onOpen: (link) async => await launchUrl(Uri.parse(link.url))),
                            ButtonBar(
                                alignment: MainAxisAlignment.center,
                                buttonPadding:
                                    const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                children: <Widget>[
                                  Wrap(
                                      direction: Axis.horizontal,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.start,
                                      children: [
                                        LAProjectTimeline(project: project),
                                        // Text('Configured: '),
                                        /* LinearPercentIndicator(
                                          width: 300,
                                          // MediaQuery.of(context).size.width - 50,
                                          animation: true,
                                          lineHeight: 25.0,
                                          animationDuration: 1500,
                                          percent: 0.70,
                                          center: Text(
                                              "Basic configuration at 70.0%"),
                                          linearStrokeCap:
                                              LinearStrokeCap.roundAll,
                                          progressColor: LAColorTheme
                                              .laThemeData.primaryColorLight), */
                                      ]),
                                ]),
                          ]),
                    ),
                  ))),
          FractionalTranslation(
            translation: const Offset(0.0, -0.4),
            child: Align(
              child: CircleAvatar(
                radius: 25.0,
                child: project.getVariableValue("favicon_url") != null &&
                        !AppUtils.isDemo()
                    ? ImageIcon(
                        NetworkImage(AppUtils.proxyImg(
                            project.getVariableValue("favicon_url"))),
                        color: LAColorTheme.laPalette,
                        size: 35)
                    : Text(project.shortName.length > 3
                        ? project.shortName.substring(0, 1)
                        : project.shortName),
              ),
              alignment: const FractionalOffset(0.5, 0.0),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectsPageViewModel {
  final AppState state;
  final bool loading;
  final void Function(LAProject project) onOpenProjectTools;
  final void Function(LAProject project) onDeleteProject;
  final void Function() onCreateProject;

  _ProjectsPageViewModel(
      {required this.state,
      required this.loading,
      required this.onOpenProjectTools,
      required this.onCreateProject,
      required this.onDeleteProject});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProjectsPageViewModel &&
          runtimeType == other.runtimeType &&
          state.projects == other.state.projects;

  @override
  int get hashCode => state.projects.hashCode;
}
