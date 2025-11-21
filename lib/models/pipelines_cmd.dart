import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/string_utils.dart';
import './common_cmd.dart';
import './pipelines_step_name.dart';

part 'pipelines_cmd.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class PipelinesCmd extends CommonCmd {
  // 0,1,2 for local/embedded/cluster

  PipelinesCmd({
    this.drs,
    Set<String>? steps,
    required this.master,
    this.debug = false,
    this.allDrs = false,
    this.allSteps = false,
    this.dryRun = false,
    this.mode = 1,
  }) : steps = steps ?? <String>{};

  factory PipelinesCmd.fromJson(Map<String, dynamic> json) =>
      _$PipelinesCmdFromJson(json);
  String? drs;
  Set<String> steps;
  String master;
  bool allDrs;
  bool allSteps;
  bool debug;
  bool dryRun;
  int mode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PipelinesCmd &&
          runtimeType == other.runtimeType &&
          const SetEquality<String>().equals(steps, other.steps) &&
          debug == other.debug &&
          drs == other.drs &&
          allDrs == other.allDrs &&
          allSteps == other.allSteps &&
          master == other.master &&
          mode == other.mode &&
          dryRun == other.dryRun;

  @override
  int get hashCode =>
      const SetEquality<String>().hash(steps) ^
      debug.hashCode ^
      dryRun.hashCode ^
      drs.hashCode ^
      allSteps.hashCode ^
      master.hashCode ^
      mode.hashCode ^
      allDrs.hashCode;

  String get desc {
    String stepsDesc = 'pipelines data processing';

    if (allDrs) {
      stepsDesc += ' of all drs';
    } else if (isACmdForAll) {
      // nothing to add
    } else {
      stepsDesc += ' of ';
      final String drsList = drs!.replaceAll('[ ]+', ', ');
      stepsDesc += ' $drsList';
    }

    final int stepsLength = steps.length;
    if (allSteps) {
      // nothing more
      stepsDesc += '';
    } else if (stepsLength <= 7) {
      steps.toList().asMap().forEach(
        (int i, String value) => stepsDesc += i == 0
            ? ' ($value'
            : i < stepsLength - 1
            ? ', $value'
            : ' and $value',
      );
      final String plural = stepsLength > 1 ? 's' : '';
      stepsDesc += stepsLength >= 1 && !allSteps ? ' step$plural)' : '';
    } else {
      stepsDesc += ' (some steps)';
    }

    String result = StringUtils.capitalize(stepsDesc);
    result = dryRun ? 'Dry run of $result' : result;
    return result;
  }

  Map<String, dynamic> toJson() => _$PipelinesCmdToJson(this);

  String getTitle() => 'Pipelines Data Processing Results';

  bool get isACmdForAll => steps
      .where(
        (String step) => <String>[
          archiveList,
          datasetList,
          pruneDatasets,
          validationReport,
          // commenting as we have to use "all"
          // jackknife,
          // clustering
        ].contains(step),
      )
      .toList()
      .isNotEmpty;

  @override
  String toString() {
    return 'PipelinesCmd{drs: $drs, steps: $steps, master: $master, allDrs: $allDrs, allSteps: $allSteps, debug: $debug, dryRun: $dryRun, mode: $mode}';
  }
}
