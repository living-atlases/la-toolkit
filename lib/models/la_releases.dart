import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

part 'laReleases.g.dart';

@immutable
@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAReleases {

  const LAReleases(
      {required this.name,
      required this.artifacts,
      required this.latest,
      required this.versions});

  factory LAReleases.fromJson(Map<String, dynamic> json) =>
      _$LAReleasesFromJson(json);
  final String name;
  final String artifacts;
  final String? latest;
  final List<String> versions;

  Map<String, dynamic> toJson() => _$LAReleasesToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LAReleases &&
          runtimeType == other.runtimeType &&
          artifacts == other.artifacts &&
          name == other.name &&
          latest == other.latest &&
          const ListEquality().equals(versions, other.versions);

  @override
  int get hashCode =>
      name.hashCode ^
      artifacts.hashCode ^
      latest.hashCode ^
      const ListEquality().hash(versions);

  @override
  String toString() {
    return 'LAReleases{name: $name, artifacts: $artifacts, latest: $latest, versions: (${versions.length})}';
  }
}
