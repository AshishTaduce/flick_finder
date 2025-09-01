import 'package:json_annotation/json_annotation.dart';
import 'cast_model.dart';

part 'credits_response_model.g.dart';

@JsonSerializable()
class CreditsResponseModel {
  final int id;
  final List<CastModel> cast;

  const CreditsResponseModel({
    required this.id,
    required this.cast,
  });

  factory CreditsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CreditsResponseModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$CreditsResponseModelToJson(this);
}