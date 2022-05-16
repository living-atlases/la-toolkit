import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/commonCmd.dart';
import 'package:la_toolkit/models/pipelinesStepName.dart';
import 'package:la_toolkit/utils/StringUtils.dart';

part 'pipelinesCmd.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class PipelinesCmd extends CommonCmd {
  String? drs;
  Set<String> steps;
  String master;
  bool allDrs;
  bool allSteps;
  bool debug;
  bool dryRun;
  int mode; // 0,1,2 for local/embedded/cluster

  PipelinesCmd(
      {this.drs,
      Set<String>? steps,
      required this.master,
      this.debug = false,
      this.allDrs = false,
      this.allSteps = false,
      this.dryRun = false,
      this.mode = 1})
      : steps = steps ?? {};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PipelinesCmd &&
          runtimeType == other.runtimeType &&
          const SetEquality().equals(steps, other.steps) &&
          debug == other.debug &&
          drs == other.drs &&
          allDrs == other.allDrs &&
          allSteps == other.allSteps &&
          master == other.master &&
          mode == other.mode &&
          dryRun == other.dryRun;

  @override
  int get hashCode =>
      const SetEquality().hash(steps) ^
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
      String drsList = drs!.replaceAll('[ ]+', ', ');
      stepsDesc += ' $drsList';
    }

    var stepsLength = steps.length;
    if (allSteps) {
      // nothing more
      stepsDesc += '';
    } else if (stepsLength <= 7) {
      steps.toList().asMap().forEach((i, value) => stepsDesc += i == 0
          ? ' (' + value
          : i < stepsLength - 1
              ? ', ' + value
              : ' and ' + value);
      String plural = stepsLength > 1 ? 's' : '';
      stepsDesc += '' + (stepsLength >= 1 && !allSteps ? ' step$plural)' : '');
    } else {
      stepsDesc += ' (some steps)';
    }

    String result = StringUtils.capitalize(stepsDesc);
    result = dryRun ? 'Dry run of ' + result : result;
    return result;
  }

  factory PipelinesCmd.fromJson(Map<String, dynamic> json) =>
      _$PipelinesCmdFromJson(json);
  Map<String, dynamic> toJson() => _$PipelinesCmdToJson(this);

  String getTitle() => "Pipelines Data Processing Results";

  bool get isACmdForAll => steps
      .where((String step) => [
            archiveList,
            datasetList,
            pruneDatasets,
            validationReport,
            // commenting as we have to use "all"
            // jackknife,
            // clustering
          ].contains(step))
      .toList()
      .isNotEmpty;

  @override
  String toString() {
    return 'PipelinesCmd{drs: $drs, steps: $steps, master: $master, allDrs: $allDrs, allSteps: $allSteps, debug: $debug, dryRun: $dryRun, mode: $mode}';
  }
}
