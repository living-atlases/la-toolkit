import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'commonCmd.dart';

part 'branding_deploy_cmd.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class BrandingDeployCmd extends CommonCmd {

  BrandingDeployCmd({
    this.debug = false,
  });

  factory BrandingDeployCmd.fromJson(Map<String, dynamic> json) =>
      _$BrandingDeployCmdFromJson(json);
  bool debug;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrandingDeployCmd &&
          runtimeType == other.runtimeType &&
          debug == other.debug;

  @override
  int get hashCode => debug.hashCode;

  @override
  String toString() {
    return 'BrandingDeployCmd {debug: $debug}';
  }

  String get desc => 'Branding Deploy';
  Map<String, dynamic> toJson() => _$BrandingDeployCmdToJson(this);

  String getTitle() => 'Branding Deploy Results';
}
