import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:redux/redux.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/formattedTitle.dart';
import 'components/laProjectTimeline.dart';
import 'components/scrollPanel.dart';
import 'laTheme.dart';
import 'models/appState.dart';
import 'models/la_project.dart';
import 'redux/app_actions.dart';
import 'routes.dart';
import 'utils/utils.dart';

class LAProjectsList extends StatefulWidget {
  const LAProjectsList({super.key});

  @override
  State<LAProjectsList> createState() => _LAProjectsListState();
}

class _LAProjectsListState extends State<LAProjectsList> {
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController!.dispose();
    // context.loaderOverlay.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectsPageViewModel>(
        distinct: true,
        converter: (Store<AppState> store) {
          return _ProjectsPageViewModel(
            state: store.state,
            loading: store.state.loading,
            onCreateProject: () {
              store.dispatch(CreateProject());
              BeamerCond.of(context, LAProjectEditLocation());
            },
            onDeleteProject: (LAProject project) {
              store.dispatch(DelProject(project));
              BeamerCond.of(context, HomeLocation());
              context.loaderOverlay.hide();
              //context.beamToNamed(HomePage.routeName);
            },
            onOpenProjectTools: (LAProject project) {
              store.dispatch(OpenProjectTools(project));
              //context.beamToNamed(LAProjectViewPage.routeName);
              BeamerCond.of(context, LAProjectViewLocation());
            },
          );
        },
        builder: (BuildContext context, _ProjectsPageViewModel vm) {
          final List<LAProject> pjs =
              vm.state.projects.where((LAProject p) => !p.isHub).toList();
          final int num = pjs.length;
          return num > 0
              ? LayoutBuilder(
                  builder:
                      (BuildContext context, BoxConstraints constraints) =>
                          ScrollPanel(
                              child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 80, vertical: 20),
                                  child: Column(children: <Widget>[
                                    AnimationLimiter(
                                        child: ListView.builder(
                                            // scrollDirection: Axis.vertical,
                                            controller: _scrollController,
                                            shrinkWrap: true,
                                            itemCount: num,
                                            // itemCount: appStateProv.appState.projects.length,
                                            itemBuilder: (BuildContext context,
                                                    int index) =>
                                                AnimationConfiguration.staggeredList(
                                                    position: index,
                                                    delay: Duration.zero,
                                                    duration: const Duration(
                                                        milliseconds: 1000),
                                                    child: SlideAnimation(
                                                        verticalOffset: 50.0,
                                                        child: ScaleAnimation(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        750),
                                                            child: ProjectCard(
                                                                pjs[index],
                                                                () => vm.onOpenProjectTools(
                                                                    pjs[index]),
                                                                () => vm.onDeleteProject(
                                                                    pjs[index])))))))
                                  ]))))
              : vm.loading
                  ? Container()
                  : Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                          ButtonTheme(
                              child: ElevatedButton.icon(
                                  onPressed: () => vm.onCreateProject(),
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(100, 50),
                                      // padding: const EdgeInsets.all(8.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                        // side: BorderSide(color: Colors.red)),
                                      )),
                                  icon: const Icon(Icons.add_circle_outline,
                                      size: 30),
                                  label: const Text('Create a New LA Project',
                                      style: TextStyle(fontSize: 18))))
                        ]));
        });
  }
}

class ProjectCard extends StatelessWidget {
  const ProjectCard(this.project, this.onOpen, this.onDelete, {super.key});

  final LAProject project;
  final void Function() onOpen;
  final void Function() onDelete;

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
                          children: <Widget>[
                            ListTile(
                                contentPadding: EdgeInsets.zero,
                                // LONG NAME
                                title: FormattedTitle(
                                    title: project.longName,
                                    fontSize: 22,
                                    color: LAColorTheme.inactive),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Tooltip(
                                          message: 'Delete this project',
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
                                                      () {});
                                                }
                                              })),
                                      const SizedBox(width: 20),
                                      Tooltip(
                                          message: 'Configure this project',
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
                                linkStyle:
                                    TextStyle(color: LAColorTheme.laPalette),
                                options: const LinkifyOptions(humanize: false),
                                text:
                                    "${project.useSSL ? 'https://' : 'http://'}${project.domain}",
                                onOpen: (LinkableElement link) async =>
                                    launchUrl(Uri.parse(link.url))),
                            ButtonBar(
                                alignment: MainAxisAlignment.center,
                                buttonPadding:
                                    const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                children: <Widget>[
                                  Wrap(
                                      //  direction: Axis.horizontal,
                                      // crossAxisAlignment:
                                      //    WrapCrossAlignment.start,
                                      children: <Widget>[
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
              alignment: FractionalOffset.topCenter,
              child: CircleAvatar(
                radius: 25.0,
                child: project.getVariableValue('favicon_url') != null &&
                        !AppUtils.isDemo()
                    ? ImageIcon(
                        NetworkImage(AppUtils.proxyImg(project
                            .getVariableValue('favicon_url')! as String)),
                        color: LAColorTheme.laPalette,
                        size: 35)
                    : Text(project.shortName.length > 3
                        ? project.shortName.substring(0, 1)
                        : project.shortName),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectsPageViewModel {
  _ProjectsPageViewModel(
      {required this.state,
      required this.loading,
      required this.onOpenProjectTools,
      required this.onCreateProject,
      required this.onDeleteProject});

  final AppState state;
  final bool loading;
  final void Function(LAProject project) onOpenProjectTools;
  final void Function(LAProject project) onDeleteProject;
  final void Function() onCreateProject;
}
