// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'la_releases..dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LAReleasesCWProxy {
  LAReleases name(String name);

  LAReleases artifacts(String artifacts);

  LAReleases latest(String? latest);

  LAReleases versions(List<String> versions);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `LAReleases(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// LAReleases(...).copyWith(id: 12, name: "My name")
  /// ```
  LAReleases call({
    String name,
    String artifacts,
    String? latest,
    List<String> versions,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfLAReleases.copyWith(...)` or call `instanceOfLAReleases.copyWith.fieldName(value)` for a single field.
class _$LAReleasesCWProxyImpl implements _$LAReleasesCWProxy {
  const _$LAReleasesCWProxyImpl(this._value);

  final LAReleases _value;

  @override
  LAReleases name(String name) => call(name: name);

  @override
  LAReleases artifacts(String artifacts) => call(artifacts: artifacts);

  @override
  LAReleases latest(String? latest) => call(latest: latest);

  @override
  LAReleases versions(List<String> versions) => call(versions: versions);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `LAReleases(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// LAReleases(...).copyWith(id: 12, name: "My name")
  /// ```
  LAReleases call({
    Object? name = const $CopyWithPlaceholder(),
    Object? artifacts = const $CopyWithPlaceholder(),
    Object? latest = const $CopyWithPlaceholder(),
    Object? versions = const $CopyWithPlaceholder(),
  }) {
    return LAReleases(
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      artifacts: artifacts == const $CopyWithPlaceholder() || artifacts == null
          ? _value.artifacts
          // ignore: cast_nullable_to_non_nullable
          : artifacts as String,
      latest: latest == const $CopyWithPlaceholder()
          ? _value.latest
          // ignore: cast_nullable_to_non_nullable
          : latest as String?,
      versions: versions == const $CopyWithPlaceholder() || versions == null
          ? _value.versions
          // ignore: cast_nullable_to_non_nullable
          : versions as List<String>,
    );
  }
}

extension $LAReleasesCopyWith on LAReleases {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfLAReleases.copyWith(...)` or `instanceOfLAReleases.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LAReleasesCWProxy get copyWith => _$LAReleasesCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAReleases _$LAReleasesFromJson(Map<String, dynamic> json) => LAReleases(
      name: json['name'] as String,
      artifacts: json['artifacts'] as String,
      latest: json['latest'] as String?,
      versions:
          (json['versions'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$LAReleasesToJson(LAReleases instance) =>
    <String, dynamic>{
      'name': instance.name,
      'artifacts': instance.artifacts,
      'latest': instance.latest,
      'versions': instance.versions,
    };
