import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';

import 'laVariableDesc.dart';

part 'laVariable.g.dart';

enum LAVariableStatus { deployed, undeployed }

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAVariable {
  String nameInt;
  LAServiceName service;
  Object value;
  LAVariableStatus status;

  LAVariable({this.nameInt, this.service, this.value});

  LAVariable.fromDesc(LAVariableDesc desc)
      : nameInt = desc.nameInt,
        service = desc.service,
        status = LAVariableStatus.undeployed;

  factory LAVariable.fromJson(Map<String, dynamic> json) =>
      _$LAVariableFromJson(json);
  Map<String, dynamic> toJson() => _$LAVariableToJson(this);

  @override
  String toString() =>
      'LAVariable {name: $nameInt, service: $service, value: $value, status: $status';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LAVariable &&
          runtimeType == other.runtimeType &&
          nameInt == other.nameInt &&
          service == other.service &&
          status == other.status &&
          value == other.value;

  @override
  int get hashCode =>
      nameInt.hashCode ^ value.hashCode ^ service.hashCode ^ status.hashCode;
}
