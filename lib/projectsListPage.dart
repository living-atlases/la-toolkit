import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:la_toolkit/components/laProjectTimeline.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/formattedTitle.dart';
import 'components/scrollPanel.dart';
import 'laTheme.dart';

class LAProjectsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectsPageViewModel>(
        distinct: true,
        converter: (store) {
          return _ProjectsPageViewModel(
            state: store.state,
            onCreateProject: () => store.dispatch(CreateProject()),
            onOpenProjectTools: (project) =>
                store.dispatch(OpenProjectTools(project)),
          );
        },
        builder: (BuildContext context, _ProjectsPageViewModel vm) {
          var num = vm.state.projects.length;
          return num > 0
              ? new ScrollPanel(
                  child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                      child: Column(children: <Widget>[
                        ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: num,
                            // itemCount: appStateProv.appState.projects.length,
                            itemBuilder: (BuildContext context, int index) =>
                                ProjectCard(
                                    vm.state.projects[index],
                                    () => vm.onOpenProjectTools(
                                        vm.state.projects[index])))
                      ])))
              : Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                      ButtonTheme(
                          // minWidth: 200.0,
                          height: 60.0,
                          child: ElevatedButton.icon(
                              onPressed: () => vm.onCreateProject(),
                              style: ElevatedButton.styleFrom(
                                  onPrimary: Colors.white,
                                  primary: LAColorTheme.laPalette,
                                  // padding: const EdgeInsets.all(8.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    // side: BorderSide(color: Colors.red)),
                                  )),
                              icon: Icon(Icons.add_circle_outline, size: 30),
                              label: new Text("Create a New LA Project",
                                  style: TextStyle(fontSize: 18))))
                    ]));
        });
  }
}

class ProjectCard extends StatelessWidget {
  final LAProject project;
  final void Function() onOpen;

  ProjectCard(this.project, this.onOpen);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Container(
        child: new Stack(
          children: <Widget>[
            GestureDetector(
                onTap: () => onOpen(),
                child: Card(
                  child: Container(
                    height: 220.0,
                    margin: EdgeInsets.fromLTRB(30, 12, 20, 30),
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
                              trailing: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                icon: Icon(
                                  Icons.settings,
                                  color: Colors.grey,
                                ),
                                onPressed: () => onOpen(),
                              )),
                          Text(
                            // SHORT NAME
                            project.shortName,
                            style: TextStyle(fontSize: 16),
                          ),
                          SelectableLinkify(
                              linkStyle:
                                  TextStyle(color: LAColorTheme.laPalette),
                              options: LinkifyOptions(humanize: false),
                              text:
                                  "${project.useSSL ? 'https://' : 'http://'}${project.domain}",
                              onOpen: (link) async => await launch(link.url)),
                          ButtonBar(
                              alignment: MainAxisAlignment.center,
                              buttonPadding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                              children: <Widget>[
                                Wrap(
                                    direction: Axis.horizontal,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
                                    children: [
                                      LAProjectTimeline(uuid: project.uuid),
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
                )),
            FractionalTranslation(
              translation: Offset(0.0, -0.4),
              child: Align(
                child: CircleAvatar(
                  radius: 25.0,
                  child: project.getVariable("favicon_url").value != null
                      ? ImageIcon(
                          NetworkImage(
                              project.getVariable("favicon_url").value),
                          color: LAColorTheme.laPalette,
                          size: 35)
                      : Text(project.shortName.length > 3
                          ? project.shortName.substring(0, 1)
                          : project.shortName),
                ),
                alignment: FractionalOffset(0.5, 0.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectsPageViewModel {
  final AppState state;
  final void Function(LAProject project) onOpenProjectTools;
  final void Function() onCreateProject;

  _ProjectsPageViewModel(
      {this.state, this.onOpenProjectTools, this.onCreateProject});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ProjectsPageViewModel &&
          runtimeType == other.runtimeType &&
          state.projects == other.state.projects;

  @override
  int get hashCode => state.projects.hashCode;
}
