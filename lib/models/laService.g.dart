// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laService.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAServiceCopyWith on LAService {
  LAService copyWith({
    String? iniPath,
    String? nameInt,
    String? suburl,
    bool? use,
    bool? usesSubdomain,
  }) {
    return LAService(
      iniPath: iniPath ?? this.iniPath,
      nameInt: nameInt ?? this.nameInt,
      suburl: suburl ?? this.suburl,
      use: use ?? this.use,
      usesSubdomain: usesSubdomain ?? this.usesSubdomain,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAService _$LAServiceFromJson(Map<String, dynamic> json) {
  return LAService(
    nameInt: json['nameInt'] as String,
    iniPath: json['iniPath'] as String,
    use: json['use'] as bool,
    usesSubdomain: json['usesSubdomain'] as bool,
    suburl: json['suburl'] as String,
  );
}

Map<String, dynamic> _$LAServiceToJson(LAService instance) => <String, dynamic>{
      'nameInt': instance.nameInt,
      'iniPath': instance.iniPath,
      'use': instance.use,
      'usesSubdomain': instance.usesSubdomain,
      'suburl': instance.suburl,
    };
