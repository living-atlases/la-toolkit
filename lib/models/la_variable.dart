import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectid/objectid.dart';
import './is_json_serializable.dart';
import './la_service_name.dart';
import './la_variable_desc.dart';

part 'la_variable.g.dart';

enum LAVariableStatus { deployed, undeployed }

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAVariable implements IsJsonSerializable<LAVariable> {
  LAVariable({String? id, required this.nameInt, required this.service, this.value, required this.projectId})
      : id = id ?? ObjectId().toString();

  LAVariable.fromDesc(LAVariableDesc desc, this.projectId)
      : id = ObjectId().toString(),
        nameInt = desc.nameInt,
        service = desc.service,
        status = LAVariableStatus.undeployed;

  factory LAVariable.fromJson(Map<String, dynamic> json) => _$LAVariableFromJson(json);
  // Basic
  String id;
  String nameInt;
  LAServiceName service;
  Object? value;
  String projectId;

  // Status
  LAVariableStatus status = LAVariableStatus.undeployed;
  static const String varInvPrefix = 'LA_variable_';
  @override
  Map<String, dynamic> toJson() => _$LAVariableToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LAVariable &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nameInt == other.nameInt &&
          service == other.service &&
          value == other.value &&
          projectId == other.projectId &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^ nameInt.hashCode ^ service.hashCode ^ value.hashCode ^ projectId.hashCode ^ status.hashCode;

  @override
  String toString() => 'LAVariable {name: $nameInt, service: $service, value: $value, status: $status';

  @override
  LAVariable fromJson(Map<String, dynamic> json) => LAVariable.fromJson(json);
}
