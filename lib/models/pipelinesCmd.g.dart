// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pipelinesCmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PipelinesCmdCWProxy {
  PipelinesCmd drs(String? drs);

  PipelinesCmd steps(Set<String>? steps);

  PipelinesCmd master(String master);

  PipelinesCmd debug(bool debug);

  PipelinesCmd allDrs(bool allDrs);

  PipelinesCmd allSteps(bool allSteps);

  PipelinesCmd dryRun(bool dryRun);

  PipelinesCmd mode(int mode);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `PipelinesCmd(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PipelinesCmd(...).copyWith(id: 12, name: "My name")
  /// ```
  PipelinesCmd call({
    String? drs,
    Set<String>? steps,
    String master,
    bool debug,
    bool allDrs,
    bool allSteps,
    bool dryRun,
    int mode,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfPipelinesCmd.copyWith(...)` or call `instanceOfPipelinesCmd.copyWith.fieldName(value)` for a single field.
class _$PipelinesCmdCWProxyImpl implements _$PipelinesCmdCWProxy {
  const _$PipelinesCmdCWProxyImpl(this._value);

  final PipelinesCmd _value;

  @override
  PipelinesCmd drs(String? drs) => call(drs: drs);

  @override
  PipelinesCmd steps(Set<String>? steps) => call(steps: steps);

  @override
  PipelinesCmd master(String master) => call(master: master);

  @override
  PipelinesCmd debug(bool debug) => call(debug: debug);

  @override
  PipelinesCmd allDrs(bool allDrs) => call(allDrs: allDrs);

  @override
  PipelinesCmd allSteps(bool allSteps) => call(allSteps: allSteps);

  @override
  PipelinesCmd dryRun(bool dryRun) => call(dryRun: dryRun);

  @override
  PipelinesCmd mode(int mode) => call(mode: mode);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `PipelinesCmd(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// PipelinesCmd(...).copyWith(id: 12, name: "My name")
  /// ```
  PipelinesCmd call({
    Object? drs = const $CopyWithPlaceholder(),
    Object? steps = const $CopyWithPlaceholder(),
    Object? master = const $CopyWithPlaceholder(),
    Object? debug = const $CopyWithPlaceholder(),
    Object? allDrs = const $CopyWithPlaceholder(),
    Object? allSteps = const $CopyWithPlaceholder(),
    Object? dryRun = const $CopyWithPlaceholder(),
    Object? mode = const $CopyWithPlaceholder(),
  }) {
    return PipelinesCmd(
      drs: drs == const $CopyWithPlaceholder()
          ? _value.drs
          // ignore: cast_nullable_to_non_nullable
          : drs as String?,
      steps: steps == const $CopyWithPlaceholder()
          ? _value.steps
          // ignore: cast_nullable_to_non_nullable
          : steps as Set<String>?,
      master: master == const $CopyWithPlaceholder() || master == null
          ? _value.master
          // ignore: cast_nullable_to_non_nullable
          : master as String,
      debug: debug == const $CopyWithPlaceholder() || debug == null
          ? _value.debug
          // ignore: cast_nullable_to_non_nullable
          : debug as bool,
      allDrs: allDrs == const $CopyWithPlaceholder() || allDrs == null
          ? _value.allDrs
          // ignore: cast_nullable_to_non_nullable
          : allDrs as bool,
      allSteps: allSteps == const $CopyWithPlaceholder() || allSteps == null
          ? _value.allSteps
          // ignore: cast_nullable_to_non_nullable
          : allSteps as bool,
      dryRun: dryRun == const $CopyWithPlaceholder() || dryRun == null
          ? _value.dryRun
          // ignore: cast_nullable_to_non_nullable
          : dryRun as bool,
      mode: mode == const $CopyWithPlaceholder() || mode == null
          ? _value.mode
          // ignore: cast_nullable_to_non_nullable
          : mode as int,
    );
  }
}

extension $PipelinesCmdCopyWith on PipelinesCmd {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfPipelinesCmd.copyWith(...)` or `instanceOfPipelinesCmd.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PipelinesCmdCWProxy get copyWith => _$PipelinesCmdCWProxyImpl(this);
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
      mode: (json['mode'] as num?)?.toInt() ?? 1,
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
