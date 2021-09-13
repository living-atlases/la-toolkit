// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laReleases.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAReleasesCopyWith on LAReleases {
  LAReleases copyWith({
    String? artifact,
    String? latest,
    String? name,
    List<String>? versions,
  }) {
    return LAReleases(
      artifact: artifact ?? this.artifact,
      latest: latest ?? this.latest,
      name: name ?? this.name,
      versions: versions ?? this.versions,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAReleases _$LAReleasesFromJson(Map<String, dynamic> json) {
  return LAReleases(
    name: json['name'] as String,
    artifact: json['artifact'] as String,
    latest: json['latest'] as String?,
    versions:
        (json['versions'] as List<dynamic>).map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$LAReleasesToJson(LAReleases instance) =>
    <String, dynamic>{
      'name': instance.name,
      'artifact': instance.artifact,
      'latest': instance.latest,
      'versions': instance.versions,
    };
