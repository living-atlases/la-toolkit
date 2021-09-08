// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pipelinesCmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension PipelinesCmdCopyWith on PipelinesCmd {
  PipelinesCmd copyWith({
    bool? allDrs,
    bool? allSteps,
    bool? debug,
    String? drs,
    bool? dryRun,
    Set<String>? steps,
  }) {
    return PipelinesCmd(
      allDrs: allDrs ?? this.allDrs,
      allSteps: allSteps ?? this.allSteps,
      debug: debug ?? this.debug,
      drs: drs ?? this.drs,
      dryRun: dryRun ?? this.dryRun,
      steps: steps ?? this.steps,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PipelinesCmd _$PipelinesCmdFromJson(Map<String, dynamic> json) {
  return PipelinesCmd(
    drs: json['drs'] as String?,
    steps: (json['steps'] as List<dynamic>?)?.map((e) => e as String).toSet(),
    debug: json['debug'] as bool,
    allDrs: json['allDrs'] as bool,
    allSteps: json['allSteps'] as bool,
    dryRun: json['dryRun'] as bool,
  );
}

Map<String, dynamic> _$PipelinesCmdToJson(PipelinesCmd instance) =>
    <String, dynamic>{
      'drs': instance.drs,
      'steps': instance.steps.toList(),
      'allDrs': instance.allDrs,
      'allSteps': instance.allSteps,
      'debug': instance.debug,
      'dryRun': instance.dryRun,
    };
