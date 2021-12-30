// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laReleases.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfLAReleases.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfLAReleases.copyWith.fieldName(...)`
class _LAReleasesCWProxy {
  final LAReleases _value;

  const _LAReleasesCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `LAReleases(...).copyWithNull(...)` to set certain fields to `null`. Prefer `LAReleases(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAReleases(...).copyWith(id: 12, name: "My name")
  /// ````
  LAReleases call({
    String? artifact,
    String? latest,
    String? name,
    List<String>? versions,
  }) {
    return LAReleases(
      artifact: artifact ?? _value.artifact,
      latest: latest ?? _value.latest,
      name: name ?? _value.name,
      versions: versions ?? _value.versions,
    );
  }

  LAReleases latest(String? latest) => latest == null
      ? _value._copyWithNull(latest: true)
      : this(latest: latest);

  LAReleases artifact(String artifact) => this(artifact: artifact);

  LAReleases name(String name) => this(name: name);

  LAReleases versions(List<String> versions) => this(versions: versions);
}

extension LAReleasesCopyWith on LAReleases {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass LAReleases.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass LAReleases.name.copyWith.fieldName(...)`
  _LAReleasesCWProxy get copyWith => _LAReleasesCWProxy(this);

  LAReleases _copyWithNull({
    bool latest = false,
  }) {
    return LAReleases(
      artifact: artifact,
      latest: latest == true ? null : this.latest,
      name: name,
      versions: versions,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAReleases _$LAReleasesFromJson(Map<String, dynamic> json) => LAReleases(
      name: json['name'] as String,
      artifact: json['artifact'] as String,
      latest: json['latest'] as String?,
      versions:
          (json['versions'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$LAReleasesToJson(LAReleases instance) =>
    <String, dynamic>{
      'name': instance.name,
      'artifact': instance.artifact,
      'latest': instance.latest,
      'versions': instance.versions,
    };
