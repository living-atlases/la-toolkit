import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../models/app_state.dart';
import '../models/la_project.dart';
import 'software_selector.dart';

class DockerComposeSelector extends StatefulWidget {
  const DockerComposeSelector({super.key, required this.onChange});

  final Function(String?) onChange;

  @override
  State<DockerComposeSelector> createState() => _DockerComposeSelectorState();
}

class _DockerComposeSelectorState extends State<DockerComposeSelector> {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _DockerComposeSelectorViewModel>(
      converter: (Store<AppState> store) {
        return _DockerComposeSelectorViewModel(state: store.state);
      },
      builder: (BuildContext context, _DockerComposeSelectorViewModel vm) {
        final LAProject currentProject = vm.state.currentProject;
        return SoftwareSelector(
          label: 'la-docker-compose release:',
          initialValue: currentProject.dockerComposeRelease,
          versions: vm.state.dockerComposeReleases,
          roundStyle: false,
          onChange: widget.onChange,
        );
      },
    );
  }
}

class _DockerComposeSelectorViewModel {
  _DockerComposeSelectorViewModel({required this.state});

  final AppState state;
}
