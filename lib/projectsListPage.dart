import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:url_launcher/url_launcher.dart';

import 'laTheme.dart';

class LAProjectsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ProjectsPageViewModel>(converter: (store) {
      return _ProjectsPageViewModel(
        state: store.state,
        onAddProject: () => store.dispatch(AddProject()),
        onEditProject: (project) => store.dispatch(EditProject(project)),
      );
    }, builder: (BuildContext context, _ProjectsPageViewModel vm) {
      var num = vm.state.projects.length;
      return num > 0
          ? new Container(
              constraints: new BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.9),
              child: new Scrollbar(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 160, vertical: 20),
                          child: Column(children: <Widget>[
                            ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: num,
                                // itemCount: appStateProv.appState.projects.length,
                                itemBuilder:
                                    (BuildContext context, int index) =>
                                        ProjectCard(
                                            vm.state.projects[index],
                                            () => vm.onEditProject(
                                                vm.state.projects[index])))
                          ])))))
          : Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                  RaisedButton(
                      onPressed: () => vm.onAddProject(),
                      textColor: Colors.white,
                      color: LaColorTheme.laPalette,
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
      padding: const EdgeInsets.only(top: 30.0),
      child: Container(
        child: new Stack(
          children: <Widget>[
            GestureDetector(
                onTap: () => {print("Click")},
                child: Card(
                  child: Container(
                    height: 100.0,
                    margin: EdgeInsets.fromLTRB(30, 30, 0, 0),
                    child:
                        Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                          Text(project.longName,
                              style: GoogleFonts.signika(
                                  textStyle: TextStyle(
                                      // color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300))),
                          Text(project.shortName),
                          SelectableLinkify(
                              linkStyle:
                                  TextStyle(color: LaColorTheme.laPalette),
                              options: LinkifyOptions(humanize: false),
                              text:
                                  "${project.useSSL ? 'https://' : 'http://'}${project.domain}",
                              onOpen: (link) async => await launch(link.url)),
                          ButtonBar(
                              alignment: MainAxisAlignment.end,
                              children: <Widget>[
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                  icon: Icon(
                                    Icons.settings,
                                    color: Colors.grey,
                                  ),
                                  // label: Text("Settings"),
                                  onPressed: () => onEdit(),
                                ),
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
  final void Function(LAProject project) onEditProject;
  final void Function() onAddProject;

  _ProjectsPageViewModel({this.state, this.onEditProject, this.onAddProject});
}
