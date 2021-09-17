import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

part 'laReleases.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAReleases {
  final String name;
  final String artifact;
  final String? latest;
  final List<String> versions;

  const LAReleases(
      {required this.name,
      required this.artifact,
      required this.latest,
      required this.versions});

  factory LAReleases.fromJson(Map<String, dynamic> json) =>
      _$LAReleasesFromJson(json);

  Map<String, dynamic> toJson() => _$LAReleasesToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LAReleases &&
          runtimeType == other.runtimeType &&
          artifact == other.artifact &&
          name == other.name &&
          latest == other.latest &&
          const ListEquality().equals(versions, other.versions);

  @override
  int get hashCode =>
      name.hashCode ^
      artifact.hashCode ^
      latest.hashCode ^
      const ListEquality().hash(versions);

  @override
  String toString() {
    return 'LAReleases{name: $name, artifact: $artifact, latest: $latest, versions: (${versions.length})}';
  }
}
