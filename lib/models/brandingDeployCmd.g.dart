// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brandingDeployCmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension BrandingDeployCmdCopyWith on BrandingDeployCmd {
  BrandingDeployCmd copyWith({
    bool? debug,
  }) {
    return BrandingDeployCmd(
      debug: debug ?? this.debug,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrandingDeployCmd _$BrandingDeployCmdFromJson(Map<String, dynamic> json) {
  return BrandingDeployCmd(
    debug: json['debug'] as bool,
  );
}

Map<String, dynamic> _$BrandingDeployCmdToJson(BrandingDeployCmd instance) =>
    <String, dynamic>{
      'debug': instance.debug,
    };
