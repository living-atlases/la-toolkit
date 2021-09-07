import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/commonCmd.dart';
import 'package:la_toolkit/utils/StringUtils.dart';

part 'pipelinesCmd.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class PipelinesCmd extends CommonCmd {
  String? drs;
  List<String> steps;
  bool allDrs;
  bool debug;
  bool dryRun;

  PipelinesCmd({
    this.drs,
    List<String>? steps,
    this.debug = false,
    this.allDrs = false,
    this.dryRun = false,
  }) : steps = steps ?? [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PipelinesCmd &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(steps, other.steps) &&
          debug == other.debug &&
          drs == other.drs &&
          allDrs == other.allDrs &&
          dryRun == other.dryRun;

  @override
  int get hashCode =>
      const ListEquality().hash(steps) ^
      debug.hashCode ^
      dryRun.hashCode ^
      drs.hashCode ^
      allDrs.hashCode;

  String get desc {
    String stepsDesc = 'pipelines data processing of';

    bool allSteps = const ListEquality().equals(steps, ['all']);
    if (allDrs) {
      stepsDesc += ' all drs';
    } else {
      String drsList = drs!.replaceAll('[ ]+', ', ');
      stepsDesc += ' $drsList';
    }

    var stepsLength = steps.length;
    if (allSteps) {
      // nothing more
      stepsDesc += '';
    } else if (stepsLength <= 7) {
      steps.asMap().forEach((i, value) => stepsDesc += i == 0
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
}
