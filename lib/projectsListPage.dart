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
    return StoreConnector<AppState, _ProjectsPageViewModel>(converter: (store) {
      return _ProjectsPageViewModel(
        state: store.state,
        onCreateProject: () => store.dispatch(CreateProject()),
        onOpenProject: (project) => store.dispatch(OpenProject(project)),
      );
    }, builder: (BuildContext context, _ProjectsPageViewModel vm) {
      var num = vm.state.projects.length;
      return num > 0
          ? new ScrollPanel(
              child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                  child: Column(children: <Widget>[
                    ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: num,
                        // itemCount: appStateProv.appState.projects.length,
                        itemBuilder: (BuildContext context, int index) =>
                            ProjectCard(
                                vm.state.projects[index],
                                () =>
                                    vm.onOpenProject(vm.state.projects[index])))
                  ])))
          : Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                  RaisedButton(
                      onPressed: () => vm.onCreateProject(),
                      textColor: Colors.white,
                      color: LAColorTheme.laPalette,
                      // padding: const EdgeInsets.all(8.0),
                      child: new Text(
                        "Create a New LA Project",
                      ))
                ]));
    });
  }
}

class ProjectCard extends StatelessWidget {
  final LAProject project;
  final void Function() onEdit;

  ProjectCard(this.project, this.onEdit);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Container(
        child: new Stack(
          children: <Widget>[
            GestureDetector(
                onTap: () => onEdit(),
                child: Card(
                  child: Container(
                    height: 200.0,
                    margin: EdgeInsets.fromLTRB(30, 30, 20, 30),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ListTile(
                              contentPadding: EdgeInsets.zero,
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
                                // label: Text("Settings"),
                                onPressed: () => onEdit(),
                              )),
                          Text(project.shortName),
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
                                      LAProjectTimeline(),
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
                          /* ButtonBar(
                              alignment: MainAxisAlignment.end,
                              children: <Widget>[
                                FlatButton.icon(
                                  icon: Icon(
                                    Icons.remove_red_eye_rounded,
                                    // color: LaColorTheme.laPalette,
                                  ),
                                  label: Text('VIEW'),
                                  // color: Color.fromRGBO(68, 153, 213, 1.0),
                                  // shape: CircleBorder(),
                                  onPressed: () {},
                                ),
                                FlatButton.icon(
                                  icon: Icon(
                                    Icons.edit,
                                    // color: Colors.white,
                                  ),
                                  label: Text('EDIT'),
                                  // color: Color.fromRGBO(68, 153, 213, 1.0),
                                  // shape: CircleBorder(),
                                  onPressed: () {},
                                ),
                                FlatButton.icon(
                                  // color: Color.fromRGBO(161, 108, 164, 1.0),
                                  icon: Icon(Icons.delete),
                                  label: Text('ARCHIVE'),
                                  /* shape: new RoundedRectangleBorder(
                                          borderRadius:
                                              new BorderRadius.circular(30.0)), */
                                  // textColor: Colors.white,
                                  onPressed: () {},
                                ),
                              ]) */
                        ]),
                  ),
                )),
            FractionalTranslation(
              translation: Offset(0.0, -0.4),
              child: Align(
                child: CircleAvatar(
                  radius: 25.0,
                  child: Text(project.shortName.length > 3
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
  final void Function(LAProject project) onOpenProject;
  final void Function() onCreateProject;

  _ProjectsPageViewModel(
      {this.state, this.onOpenProject, this.onCreateProject});
}
