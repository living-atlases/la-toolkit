// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laReleases.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LAReleasesCWProxy {
  LAReleases name(String name);

  LAReleases artifacts(String artifacts);

  LAReleases latest(String? latest);

  LAReleases versions(List<String> versions);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LAReleases(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAReleases(...).copyWith(id: 12, name: "My name")
  /// ````
  LAReleases call({
    String name,
    String artifacts,
    String? latest,
    List<String> versions,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLAReleases.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLAReleases.copyWith.fieldName(...)`
class _$LAReleasesCWProxyImpl implements _$LAReleasesCWProxy {
  const _$LAReleasesCWProxyImpl(this._value);

  final LAReleases _value;

  @override
  LAReleases name(String name) => this(name: name);

  @override
  LAReleases artifacts(String artifacts) => this(artifacts: artifacts);

  @override
  LAReleases latest(String? latest) => this(latest: latest);

  @override
  LAReleases versions(List<String> versions) => this(versions: versions);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LAReleases(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAReleases(...).copyWith(id: 12, name: "My name")
  /// ````
  LAReleases call({
    Object? name = const $CopyWithPlaceholder(),
    Object? artifacts = const $CopyWithPlaceholder(),
    Object? latest = const $CopyWithPlaceholder(),
    Object? versions = const $CopyWithPlaceholder(),
  }) {
    return LAReleases(
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      artifacts: artifacts == const $CopyWithPlaceholder()
          ? _value.artifacts
          // ignore: cast_nullable_to_non_nullable
          : artifacts as String,
      latest: latest == const $CopyWithPlaceholder()
          ? _value.latest
          // ignore: cast_nullable_to_non_nullable
          : latest as String?,
      versions: versions == const $CopyWithPlaceholder()
          ? _value.versions
          // ignore: cast_nullable_to_non_nullable
          : versions as List<String>,
    );
  }
}

extension $LAReleasesCopyWith on LAReleases {
  /// Returns a callable class that can be used as follows: `instanceOfLAReleases.copyWith(...)` or like so:`instanceOfLAReleases.copyWith.fieldName(...)`.
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
