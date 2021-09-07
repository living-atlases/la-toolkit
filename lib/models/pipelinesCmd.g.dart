// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pipelinesCmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension PipelinesCmdCopyWith on PipelinesCmd {
  PipelinesCmd copyWith({
    bool? debug,
    bool? dryRun,
    List<String>? steps,
  }) {
    return PipelinesCmd(
      debug: debug ?? this.debug,
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
    steps: (json['steps'] as List<dynamic>?)?.map((e) => e as String).toList(),
    debug: json['debug'] as bool,
    dryRun: json['dryRun'] as bool,
  );
}

Map<String, dynamic> _$PipelinesCmdToJson(PipelinesCmd instance) =>
    <String, dynamic>{
      'steps': instance.steps,
      'debug': instance.debug,
      'dryRun': instance.dryRun,
    };
