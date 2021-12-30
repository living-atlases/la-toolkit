// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pipelinesCmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfPipelinesCmd.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfPipelinesCmd.copyWith.fieldName(...)`
class _PipelinesCmdCWProxy {
  final PipelinesCmd _value;

  const _PipelinesCmdCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `PipelinesCmd(...).copyWithNull(...)` to set certain fields to `null`. Prefer `PipelinesCmd(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PipelinesCmd(...).copyWith(id: 12, name: "My name")
  /// ````
  PipelinesCmd call({
    bool? allDrs,
    bool? allSteps,
    bool? debug,
    String? drs,
    bool? dryRun,
    String? master,
    int? mode,
    Set<String>? steps,
  }) {
    return PipelinesCmd(
      allDrs: allDrs ?? _value.allDrs,
      allSteps: allSteps ?? _value.allSteps,
      debug: debug ?? _value.debug,
      drs: drs ?? _value.drs,
      dryRun: dryRun ?? _value.dryRun,
      master: master ?? _value.master,
      mode: mode ?? _value.mode,
      steps: steps ?? _value.steps,
    );
  }

  PipelinesCmd drs(String? drs) =>
      drs == null ? _value._copyWithNull(drs: true) : this(drs: drs);

  PipelinesCmd steps(Set<String>? steps) =>
      steps == null ? _value._copyWithNull(steps: true) : this(steps: steps);

  PipelinesCmd allDrs(bool allDrs) => this(allDrs: allDrs);

  PipelinesCmd allSteps(bool allSteps) => this(allSteps: allSteps);

  PipelinesCmd debug(bool debug) => this(debug: debug);

  PipelinesCmd dryRun(bool dryRun) => this(dryRun: dryRun);

  PipelinesCmd master(String master) => this(master: master);

  PipelinesCmd mode(int mode) => this(mode: mode);
}

extension PipelinesCmdCopyWith on PipelinesCmd {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass PipelinesCmd extends CommonCmd.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass PipelinesCmd extends CommonCmd.name.copyWith.fieldName(...)`
  _PipelinesCmdCWProxy get copyWith => _PipelinesCmdCWProxy(this);

  PipelinesCmd _copyWithNull({
    bool drs = false,
    bool steps = false,
  }) {
    return PipelinesCmd(
      allDrs: allDrs,
      allSteps: allSteps,
      debug: debug,
      drs: drs == true ? null : this.drs,
      dryRun: dryRun,
      master: master,
      mode: mode,
      steps: steps == true ? null : this.steps,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PipelinesCmd _$PipelinesCmdFromJson(Map<String, dynamic> json) => PipelinesCmd(
      drs: json['drs'] as String?,
      steps: (json['steps'] as List<dynamic>?)?.map((e) => e as String).toSet(),
      master: json['master'] as String,
      debug: json['debug'] as bool? ?? false,
      allDrs: json['allDrs'] as bool? ?? false,
      allSteps: json['allSteps'] as bool? ?? false,
      dryRun: json['dryRun'] as bool? ?? false,
      mode: json['mode'] as int? ?? 1,
    );

Map<String, dynamic> _$PipelinesCmdToJson(PipelinesCmd instance) =>
    <String, dynamic>{
      'drs': instance.drs,
      'steps': instance.steps.toList(),
      'master': instance.master,
      'allDrs': instance.allDrs,
      'allSteps': instance.allSteps,
      'debug': instance.debug,
      'dryRun': instance.dryRun,
      'mode': instance.mode,
    };
